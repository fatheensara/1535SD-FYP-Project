Write-Host "=== FINAL FIX FOR KOTLIN DSL ===" -ForegroundColor Cyan

# 1. Fix the root build.gradle.kts
Write-Host "Updating android/build.gradle.kts..." -ForegroundColor Yellow
$rootBuildKts = @'
buildscript {
    val kotlinVersion by extra("1.9.0")

    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1")
        classpath("com.google.gms:google-services:4.3.14")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:`$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
'@

$rootBuildKts | Out-File -FilePath "android/build.gradle.kts" -Encoding UTF8
Write-Host "✓ Fixed android/build.gradle.kts"

# 2. Ensure app/build.gradle.kts has correct kotlin-android plugin
Write-Host "Checking android/app/build.gradle.kts..." -ForegroundColor Yellow
$appBuildKts = Get-Content -Path "android/app/build.gradle.kts" -Raw
if ($appBuildKts -notmatch 'id\("kotlin-android"\)') {
    Write-Host "Updating kotlin-android plugin..." -ForegroundColor Yellow
    $appBuildKts = $appBuildKts -replace 'id\("kotlin-android"\)', 'id("org.jetbrains.kotlin.android")'
    $appBuildKts | Out-File -FilePath "android/app/build.gradle.kts" -Encoding UTF8
}
Write-Host "✓ android/app/build.gradle.kts is OK"

# 3. Check gradle-wrapper.properties
Write-Host "Checking gradle wrapper..." -ForegroundColor Yellow
$gradleWrapper = @'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
'@

$gradleWrapper | Out-File -FilePath "android/gradle/wrapper/gradle-wrapper.properties" -Encoding UTF8
Write-Host "✓ Updated gradle-wrapper.properties"

# 4. Clean everything
Write-Host "`nCleaning project..." -ForegroundColor Yellow
flutter clean

# Remove build directories
$dirs = @("build", ".gradle", ".flutter-plugins", ".flutter-plugins-dependencies")
foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
    }
}

if (Test-Path "android") {
    Remove-Item -Recurse -Force android/.gradle, android/build, android/app/build -ErrorAction SilentlyContinue
}

# 5. Create/update local.properties
Write-Host "Checking local.properties..." -ForegroundColor Yellow
if (-Not (Test-Path "android/local.properties")) {
    $sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
    $flutterPath = (flutter doctor -v | Select-String "Flutter.*at" | Select-Object -First 1) -replace ".*Flutter.*at ", "" -replace " \(.*\)", ""
    "sdk.dir=$sdkPath`nflutter.sdk=$flutterPath" | Out-File -FilePath "android/local.properties" -Encoding UTF8
    Write-Host "✓ Created local.properties"
}

# 6. Get packages
Write-Host "Getting packages..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n=== BUILD FIXED ===" -ForegroundColor Green
Write-Host "Now run these commands:" -ForegroundColor Cyan
Write-Host "1. cd android" -ForegroundColor White
Write-Host "2. .\gradlew.bat clean" -ForegroundColor White
Write-Host "3. cd .." -ForegroundColor White
Write-Host "4. flutter run" -ForegroundColor White
import 'dart:ui'; // Required for blur
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import pages
import 'student_signin.dart';
import 'student_signup.dart';
import 'fade_page_route.dart';

class StudentHelloPage extends StatelessWidget {
  const StudentHelloPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND (The nice gradient with blobs)
          _buildBackground(context),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // --- HERO SECTION ---
                _buildHeroIcon(),
                const SizedBox(height: 30),

                // Title Text (Updated to your App Name)
                Text(
                  "AttenDID",
                  style: GoogleFonts.poppins(
                    fontSize: 42, // Slightly larger for the brand name
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Smart Attendance System",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),

                const Spacer(flex: 2),

                // --- BOTTOM GLASS CARD ---
                _buildBottomGlassCard(context),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildBackground(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E3192), // Deep Blue
            Colors.purple.shade900, // Purple accent
            Colors.purple.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background Overlay to darken it slightly
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.3)),

          // Blob 1 (Top Left)
          Positioned(
            top: -100,
            left: -50,
            child: _buildBlob(Colors.blueAccent, 300),
          ),
          // Blob 2 (Center Right)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -100,
            child: _buildBlob(Colors.purpleAccent, 250),
          ),
          // Blob 3 (Bottom Left)
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlob(Colors.cyanAccent, 200),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // ignore: deprecated_member_use
        color: color.withOpacity(0.4),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.4),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            // ignore: deprecated_member_use
            Colors.white.withOpacity(0.4),
            // ignore: deprecated_member_use
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGlassCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SIGN IN BUTTON
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadePageRoute(page: const StudentSignInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E3192), // Deep Blue Text
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Login to Portal",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SIGN UP BUTTON (Outlined Style)
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadePageRoute(page: const StudentSignUpPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

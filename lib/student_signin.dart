import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Your existing imports
import 'student_forgot_password_page.dart';
import 'student_home_page.dart';
import 'student_hello.dart';
import 'fade_page_route.dart';
import 'screens/student_setup_screen.dart';

class StudentSignInPage extends StatefulWidget {
  const StudentSignInPage({super.key});

  @override
  State<StudentSignInPage> createState() => _StudentSignInPageState();
}

class _StudentSignInPageState extends State<StudentSignInPage> {
  // --- LOGIC STATE ---
  bool _isLogin = true; // Toggle: Login vs Register
  bool _isLoading = false;
  
  // --- UI STATE ---
  bool _rememberMe = false;
  bool _isPasswordObscured = true; // Added for Eye Icon

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ---------------------------------------------------------
  // 1. AUTH LOGIC HANDLERS
  // ---------------------------------------------------------
  void _submitAuth() {
    if (_isLogin) {
      _handleLogin();
    } else {
      _handleSignUp();
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.user != null && mounted) {
        await _checkStudentProfile(result.user!);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password to register');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.user != null && mounted) {
        // Success! New users go to Setup
        Navigator.pushReplacement(
          context,
          FadePageRoute(page: const StudentSetupScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);

      if (result.user != null && mounted) {
        await _checkStudentProfile(result.user!);
      }
    } catch (e) {
      _showError("Google Sign-In Failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkStudentProfile(User user) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking profile...')),
    );

    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (!mounted) return;

      if (studentDoc.docs.isNotEmpty) {
        // User Found -> Go Home
        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(page: const StudentHomePage()),
          (route) => false,
        );
      } else {
        // User Not Found -> Go Setup
        Navigator.push(
          context,
          FadePageRoute(
            page: const StudentSetupScreen(isFromGoogle: true), // <--- Pass true here
          ),
        );
      }
    } catch (e) {
      _showError('Error checking profile: $e');
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String msg = 'Authentication failed.';
    if (e.code == 'user-not-found') msg = 'No user found with this email.';
    else if (e.code == 'wrong-password') msg = 'Incorrect password.';
    else if (e.code == 'email-already-in-use') msg = 'Email is already registered.';
    else if (e.code == 'weak-password') msg = 'Password is too weak.';
    else if (e.code == 'invalid-email') msg = 'Invalid email address.';
    _showError(msg);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ));
  }

  // ---------------------------------------------------------
  // 2. UI BUILD
  // ---------------------------------------------------------
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
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            FadePageRoute(page: const StudentHelloPage()),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND (Copied from File 2)
          _buildBackground(),

          // 2. CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO ---
                    Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // --- TITLE (With Shadows from File 2) ---
                    Text(
                      _isLogin ? "Welcome Back" : "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _isLogin ? "Sign in to access your classes" : "Register to start attendance",
                      style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 30),

                    // --- GLASS FORM ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildGlassTextField(
                                hint: "Email Address",
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                action: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),
                              
                              // PASSWORD FIELD (With Visibility Toggle)
                              _buildGlassTextField(
                                hint: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                controller: _passwordController,
                                action: TextInputAction.done,
                              ),
                              const SizedBox(height: 15),

                              if (_isLogin)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 24, width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (val) => setState(() => _rememberMe = val!),
                                              activeColor: Colors.white,
                                              checkColor: Colors.purple.shade900,
                                              side: const BorderSide(color: Colors.white70, width: 1.5),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Remember", style: GoogleFonts.lato(color: Colors.white, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        FadePageRoute(page: const StudentForgotPasswordPage()),
                                      ),
                                      child: Text(
                                        "Forgot Password?",
                                        style: GoogleFonts.lato(
                                          color: Colors.blue.shade100,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 30),

                              // --- MAIN BUTTON ---
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.purple.shade900,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20, width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(
                                          _isLogin ? "LOG IN" : "SIGN UP",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- GOOGLE BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _handleGoogleLogin,
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: Text(
                          _isLogin ? "Sign in with Google" : "Sign up with Google",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          // ignore: deprecated_member_use
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- TOGGLE SWITCH (Login <-> Register) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: GoogleFonts.lato(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _emailController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: Text(
                            _isLogin ? "Register" : "Login",
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            const Color(0xFF6A0572), // Deep Purple
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Blob 1 Top Left
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.purple.shade600.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.purple.shade600.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // Blob 2 Bottom Right
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.blue.shade600.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.blue.shade600.withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputAction? action, // Parameter definition is correct here
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isPasswordObscured : false,
        
        // ✅ FIX: Assign the parameter to the property
        textInputAction: action, 
        
        style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(color: Colors.white60, fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.white70),
          
          // Eye Icon Logic
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                )
              : null,
          
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          isDense: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

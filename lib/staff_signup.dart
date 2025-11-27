import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fyp/staff_signin.dart';
import 'package:fyp/staff_hello.dart'; // <--- Added for navigation
import 'package:fyp/fade_page_route.dart';

class StaffSignUpPage extends StatefulWidget {
  const StaffSignUpPage({super.key});

  @override
  State<StaffSignUpPage> createState() => _StaffSignUpPageState();
}

class _StaffSignUpPageState extends State<StaffSignUpPage> {
  bool _isPasswordObscured = true;

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
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            // *** NAVIGATION UPDATE ***
            Navigator.pushReplacement(
              context,
              FadePageRoute(page: const StaffHelloPage()),
            );
          },
        ),
        title: Text(
          "Staff Registration",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. DARK BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. FORM CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  Text(
                    "New Account",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Register to access staff dashboard",
                    style: GoogleFonts.lato(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(25),
                          // ignore: deprecated_member_use
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildGlassTextField(
                              hint: "Full Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              hint: "Department",
                              icon: Icons.school_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              hint: "Staff Email",
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              hint: "Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Simplified Success Dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Registration Successful! Please Login.",
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    FadePageRoute(
                                      page: const StaffSignInPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0F0C29),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  "REGISTER",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        FadePageRoute(page: const StaffSignInPage()),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Already a staff member? ",
                        style: GoogleFonts.lato(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Login",
                            style: GoogleFonts.lato(
                              color: Colors.purple.shade200,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        obscureText: isPassword ? _isPasswordObscured : false,
        style: GoogleFonts.lato(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white54, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white38,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

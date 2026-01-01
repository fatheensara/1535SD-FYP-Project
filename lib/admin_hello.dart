import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_signin.dart';
import 'admin_signup.dart';
import 'fade_page_route.dart';
// import 'home_screen.dart'; // Unused in this snippet, kept if needed

class AdminHelloPage extends StatelessWidget {
  const AdminHelloPage({super.key});

  void _navigateToAdminSignIn(BuildContext context) {
    Navigator.push(context, FadePageRoute(page: const AdminSignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ADMIN PORTAL",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // 1. SHARED BACKGROUND (Dark Teal Theme)
          _buildBackground(),

          // 2. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // -- GLASS ICON --
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.teal.shade900.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: Colors.tealAccent.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 60,
                        color: Colors.tealAccent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // -- WELCOME TEXT --
                  Text(
                    "Hello! Welcome back to",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "AttenDID!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // -- SIGN IN BUTTON --
                  // Styled to match the "Authenticate" button in signin.dart
                  ElevatedButton(
                    onPressed: () => _navigateToAdminSignIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent, // Teal bg
                      foregroundColor: Colors.black, // Black text
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      // ignore: deprecated_member_use
                      shadowColor: Colors.tealAccent.withOpacity(0.4),
                    ),
                    child: Text(
                      "SIGN IN",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -- SIGN UP LINK --
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        FadePageRoute(page: const AdminSignUpPage()),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Don't have an account yet? ",
                        style: GoogleFonts.lato(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Sign Up",
                            style: GoogleFonts.lato(
                              color: Colors.tealAccent, // Matches theme
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.tealAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method: Same background as admin_signin.dart
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50, // Moved to left for variation from signin page
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.tealAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.tealAccent.withOpacity(0.1),
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
}

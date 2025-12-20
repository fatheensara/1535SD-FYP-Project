import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'staff_signin.dart';
import 'staff_signup.dart';
import 'fade_page_route.dart';

class StaffHelloPage extends StatelessWidget {
  const StaffHelloPage({super.key});

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
              color: Colors.white.withOpacity(0.2), // Increased visibility
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
          // 1. DYNAMIC BACKGROUND (SYNCED WITH STUDENT THEME)
          _buildBackground(context),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // HERO ICON
                _buildHeroIcon(),
                const SizedBox(height: 40),

                // Title Text
                Text(
                  "Staff Portal",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2), // Softer shadow
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Manage classes & monitor attendance",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white70, // Lighter text color
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(flex: 2),

                // BOTTOM GLASS CARD
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // STUDENT THEME GRADIENT (Royal Purple/Blue)
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Blob 1 (Lighter Accent)
          Positioned(
            top: -100,
            left: -50,
            child: _buildBlob(const Color(0xFFA155E8), 300),
          ),
          // Blob 2 (Darker Accent for Depth)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -100,
            child: _buildBlob(const Color(0xFF2B008A), 250),
          ),
          // Blob 3
          Positioned(
            bottom: -50,
            left: -50,
            // ignore: deprecated_member_use
            child: _buildBlob(Colors.white.withOpacity(0.1), 200),
          ),

          // Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.transparent),
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
        color: color.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.5),
            blurRadius: 90,
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
            Colors.white.withOpacity(0.2),
            // ignore: deprecated_member_use
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.2),
          width: 1,
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
          child: const Icon(Icons.badge_rounded, size: 60, color: Colors.white),
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
              color: Colors.white.withOpacity(0.1), // Lighter, cleaner glass
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
                // LOGIN BUTTON
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadePageRoute(page: const StaffSignInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(
                      0xFF4A00E0,
                    ), // Matching Purple Text
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Staff Login",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // REGISTER BUTTON
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadePageRoute(page: const StaffSignUpPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Register Staff",
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

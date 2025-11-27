import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_signin.dart';
import 'admin_signup.dart';
import 'fade_page_route.dart';

class AdminHelloPage extends StatelessWidget {
  const AdminHelloPage({super.key});

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
          // 1. DYNAMIC BACKGROUND (Dark Tech Theme)
          _buildBackground(context),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // HERO SECTION
                _buildHeroIcon(),
                const SizedBox(height: 40),

                // Title Text
                Text(
                  "Admin Console",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  "System control & User management",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.blueGrey.shade100,
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
          colors: [
            Color(0xFF0F2027), // Night Blue
            Color(0xFF203A43),
            Color(0xFF2C5364), // Teal-ish
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Overlay
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.3)),

          // Blob 1 (Teal)
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlob(Colors.tealAccent, 300),
          ),
          // Blob 2 (Amber/Orange for Warning/Control)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: -80,
            child: _buildBlob(Colors.amberAccent, 250),
          ),
          // Blob 3 (Cyan)
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlob(Colors.cyan, 200),
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
        color: color.withOpacity(0.3), // Lower opacity for dark theme
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.3),
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
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.tealAccent.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.4),
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
            color: Colors.teal.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded, // Admin Shield Icon
            size: 60,
            color: Colors.tealAccent,
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
              color: Colors.black.withOpacity(0.4), // Darker glass for admin
              borderRadius: BorderRadius.circular(30),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.3),
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
                      FadePageRoute(page: const AdminSignInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black, // Dark text on bright button
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Admin Access",
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
                      FadePageRoute(page: const AdminSignUpPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.tealAccent,
                    side: const BorderSide(
                      color: Colors.tealAccent,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Register Admin",
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

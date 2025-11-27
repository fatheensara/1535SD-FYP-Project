import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'student_hello.dart';
import 'staff_hello.dart';
import 'admin_hello.dart';
import 'fade_page_route.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND
          _buildBackground(),

          // 2. GLASS CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo / Hero Section
                  _buildHeroLogo(),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    "AttenDID",
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
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
                  Text(
                    "Smart NFC Attendance",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ROLE SELECTION CARDS
                  _buildGlassRoleButton(
                    context,
                    title: "Student Portal",
                    subtitle: "Check attendance & scan",
                    icon: Icons.school_rounded,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        FadePageRoute(page: const StudentHelloPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildGlassRoleButton(
                    context,
                    title: "Staff Portal",
                    subtitle: "Manage classes & reports",
                    icon: Icons.badge_rounded,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        FadePageRoute(page: const StaffHelloPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildGlassRoleButton(
                    context,
                    title: "Administrator",
                    subtitle: "System settings",
                    icon: Icons.admin_panel_settings_rounded,
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        FadePageRoute(page: const AdminHelloPage()),
                      );
                    },
                  ),

                  const Spacer(flex: 3),

                  // Footer
                  Text(
                    "International Islamic University Malaysia",
                    style: GoogleFonts.lato(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E3192), // Deep Blue
            Colors.purple.shade900,
            const Color(0xFF1BFFFF), // Cyan accent
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Overlay
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.2)),

          // Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlob(Colors.purpleAccent, 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBlob(Colors.blueAccent, 250),
          ),
          Positioned(
            top: 300,
            left: -80,
            child: _buildBlob(Colors.cyanAccent, 150),
          ),

          // Global Blur
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
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroLogo() {
    return Container(
      width: 120,
      height: 120,
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
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        // *** CHANGED ICON HERE ***
        child: Icon(
          Icons.nfc_rounded, // Replaced Fingerprint with NFC
          size: 60,
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildGlassRoleButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            // ignore: deprecated_member_use
            highlightColor: color.withOpacity(0.1),
            // ignore: deprecated_member_use
            splashColor: color.withOpacity(0.2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 20),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

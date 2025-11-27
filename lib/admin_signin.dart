import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_forgot_password_page.dart';
import 'admin_home.dart';
import 'admin_hello.dart'; // <--- Added for navigation
import 'fade_page_route.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({super.key});

  @override
  State<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
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
              FadePageRoute(page: const AdminHelloPage()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // 1. ADMIN DARK THEME (Teal/Night Blue)
          _buildBackground(),

          // 2. GLASS CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.teal.shade900.withOpacity(0.3),
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
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
                      size: 50,
                      color: Colors.tealAccent,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Admin Console",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Secure System Access",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.tealAccent.shade100,
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
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(25),
                          // ignore: deprecated_member_use
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: Colors.tealAccent.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildGlassTextField(
                              hint: "Admin ID",
                              icon: Icons.shield_outlined,
                            ),
                            const SizedBox(height: 20),
                            _buildGlassTextField(
                              hint: "Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    FadePageRoute(
                                      page: const AdminForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Reset Credentials?",
                                  style: GoogleFonts.lato(
                                    color: Colors.tealAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    FadePageRoute(page: const AdminHomePage()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.tealAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  "AUTHENTICATE",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            right: -50,
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
        style: GoogleFonts.sourceCodePro(
          color: Colors.white,
        ), // Mono font for admin
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.sourceCodePro(color: Colors.white38),
          prefixIcon: Icon(
            icon,
            // ignore: deprecated_member_use
            color: Colors.tealAccent.withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () => setState(
                    () => _isPasswordObscured = !_isPasswordObscured,
                  ),
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

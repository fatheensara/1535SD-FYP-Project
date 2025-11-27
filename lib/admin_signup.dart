import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fyp/admin_signin.dart';
import 'package:fyp/admin_hello.dart'; // <--- Added for navigation
import 'package:fyp/fade_page_route.dart';

class AdminSignUpPage extends StatefulWidget {
  const AdminSignUpPage({super.key});

  @override
  State<AdminSignUpPage> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
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
        title: Text(
          "Admin Setup",
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  Text(
                    "Register Admin",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Initialize new administrative user",
                    style: GoogleFonts.lato(
                      color: Colors.tealAccent.shade100,
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
                              hint: "Admin Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              hint: "System Key",
                              icon: Icons.vpn_key_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              hint: "Official Email",
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Admin Key Verified. Account Created.",
                                      ),
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    FadePageRoute(
                                      page: const AdminSignInPage(),
                                    ),
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
                                  "INITIALIZE",
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
                        FadePageRoute(page: const AdminSignInPage()),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Have credentials? ",
                        style: GoogleFonts.lato(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Access Console",
                            style: GoogleFonts.lato(
                              color: Colors.tealAccent,
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
        style: GoogleFonts.sourceCodePro(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.sourceCodePro(color: Colors.white38),
          // ignore: deprecated_member_use
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

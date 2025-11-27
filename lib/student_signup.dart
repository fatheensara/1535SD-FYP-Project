import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fyp/student_signin.dart';
import 'package:fyp/fade_page_route.dart';

class StudentSignUpPage extends StatefulWidget {
  const StudentSignUpPage({super.key});

  @override
  State<StudentSignUpPage> createState() => _StudentSignUpPageState();
}

class _StudentSignUpPageState extends State<StudentSignUpPage> {
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.purple.shade600,
                  Colors.purple.shade900,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  // Go back to Sign In page
                  Navigator.pushReplacement(
                    context,
                    FadePageRoute(page: const StudentSignInPage()),
                  );
                },
              ),
              title: Text(
                "Student Sign Up",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    Text(
                      "SIGN UP",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    TextFormField(
                      decoration: _buildInputDecoration(
                        hint: "Full Name",
                        icon: Icons.person_outline,
                      ),
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: _buildInputDecoration(
                        hint: "Email",
                        icon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      obscureText: _isPasswordObscured,
                      decoration: _buildInputDecoration(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () {
                        // Show the success dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext dialogContext) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              // ignore: deprecated_member_use
                              backgroundColor: Colors.black.withOpacity(0.85),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 60,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Your MATRIC NUMBER has been sent to your email.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade800,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                        Navigator.pushReplacement(
                                          context,
                                          FadePageRoute(
                                            page: const StudentSignInPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "OK",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text("REGISTER"),
                    ),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          FadePageRoute(page: const StudentSignInPage()),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: GoogleFonts.lato(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Sign In",
                              style: GoogleFonts.lato(
                                color: Colors.lightBlue.shade200,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      // ignore: deprecated_member_use
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffixIcon,
      filled: true,
      // ignore: deprecated_member_use
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
    );
  }
}

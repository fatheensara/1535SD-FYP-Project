import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'student_forgot_password_page.dart';
import 'student_home_page.dart';
import 'fade_page_route.dart';
import 'welcome.dart';

class StudentSignInPage extends StatefulWidget {
  const StudentSignInPage({super.key});

  @override
  State<StudentSignInPage> createState() => _StudentSignInPageState();
}

class _StudentSignInPageState extends State<StudentSignInPage> {
  // State for the "Remember Me" checkbox
  bool _rememberMe = false;

  // State for password visibility
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    // This checks if there is a page to pop.
    // This is correct: after logout, there's no page, so canGoBack = false.
    // After coming from the "Hello" page, canGoBack = true.
    final bool canGoBack = Navigator.canPop(context);

    return Scaffold(
      // We use a Stack to layer the gradient and the content
      body: Stack(
        children: [
          // 1. The Gradient Background (No Change)
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

          // 2. The AppBar (Transparent) - UPDATED
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,

              // Conditionally show the back button
              leading: canGoBack
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // *** YOUR REQUESTED CHANGE ***
                        // This button now goes to the WelcomeScreen
                        Navigator.pushAndRemoveUntil(
                          context,
                          FadePageRoute(page: const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                    )
                  : null, // Hidden after logout

              title: Text(
                "Student Sign In",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
          ),

          // 3. The Sign-In Form Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the form
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2), // Add space at the top
                  // "SIGN IN" Title
                  Text(
                    "SIGN IN",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Matric Number Text Field
                  TextFormField(
                    decoration: _buildInputDecoration(
                      hint: "Matric Number",
                      icon: Icons.person_outline,
                    ),
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 16),

                  // Password Text Field
                  TextFormField(
                    obscureText: _isPasswordObscured, // Hide the password
                    decoration: _buildInputDecoration(
                      hint: "Password",
                      icon: Icons.lock_outline,
                      // Add a "show/hide" password icon
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

                  const SizedBox(height: 16),

                  // "Remember Me" and "Forgot Password" Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me Checkbox
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              checkColor:
                                  Colors.purple.shade900, // Color of the check
                              activeColor: Colors.white, // Color of the box
                              side: const BorderSide(color: Colors.white),
                            ),
                            Text(
                              "Remember Me",
                              style: GoogleFonts.lato(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          // Navigate using our fade transition
                          Navigator.push(
                            context,
                            FadePageRoute(
                              page: const StudentForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.lato(
                            color: Colors.lightBlue.shade200,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // LOG IN Button
                  ElevatedButton(
                    onPressed: () {
                      // Login logic remains the same
                      Navigator.pushAndRemoveUntil(
                        context,
                        FadePageRoute(page: const StudentHomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // ... all your existing styles ...
                    ),
                    child: const Text("LOG IN"),
                  ),

                  const Spacer(flex: 3), // Add space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A helper method to build the InputDecoration for the text fields
  // This avoids code repetition and keeps the styling consistent.
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      // ignore: deprecated_member_use
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),

      // Icon on the left
      prefixIcon: Icon(icon, color: Colors.white),

      // Show/hide icon on the right
      suffixIcon: suffixIcon,

      // Background color
      filled: true,
      // ignore: deprecated_member_use
      fillColor: Colors.white.withOpacity(0.1), // Translucent white
      // Border styles
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No visible border by default
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

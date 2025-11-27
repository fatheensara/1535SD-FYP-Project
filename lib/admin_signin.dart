import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import all necessary pages
import 'admin_forgot_password_page.dart'; // <-- Create this
import 'admin_home.dart'; // <-- Create this
import 'welcome.dart'; // <-- Import
import 'fade_page_route.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({super.key});

  @override
  State<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  bool _rememberMe = false;
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.canPop(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient
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

          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: canGoBack
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // *** YOUR REQUESTED CHANGE ***
                        Navigator.pushAndRemoveUntil(
                          context,
                          FadePageRoute(page: const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                    )
                  : null,

              title: Text(
                "Admin Sign In", // <-- Changed
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
          ),

          // Form Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Text("SIGN IN" /* ... */),
                  const SizedBox(height: 32),
                  TextFormField(
                    decoration: _buildInputDecoration(
                      hint: "Staff Number", // <-- Changed
                      icon: Icons.person_outline,
                    ),
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
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // "Remember Me" Checkbox
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
                              checkColor: Colors.purple.shade900,
                              activeColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            Text(
                              "Remember Me",
                              style: GoogleFonts.lato(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      // "Forgot Password" Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            FadePageRoute(
                              page: const AdminForgotPasswordPage(),
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        FadePageRoute(
                          page: const AdminHomePage(),
                        ), // <-- Changed
                        (route) => false,
                      );
                    },
                    child: const Text("LOG IN"),
                    // ... style
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    // ...
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

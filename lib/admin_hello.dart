import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_signin.dart';
import 'admin_signup.dart';
import 'fade_page_route.dart';
import 'home_screen.dart';

const _purpleGradient = LinearGradient(
  colors: [
    Colors.blue,
    Colors.purple,
    Colors.deepPurple,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AdminHelloPage extends StatelessWidget {
  const AdminHelloPage({super.key});
  
  void _navigateToAdminSignIn(BuildContext context) {
  Navigator.push(
    context,
    FadePageRoute(page: AdminSignInPage()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "ADMIN", // <-- Changed
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                Text(
                  "Hello! Welcome back to",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                Text(
                  "AttenDID!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(flex: 3),

                // SIGN IN Button
                ElevatedButton(
                  onPressed: () => _navigateToAdminSignIn(context),
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
                    elevation: 5,
                  ),
                  child: const Text("SIGN IN"),
                ),

                const SizedBox(height: 24),

                // "Don't have an account yet? Sign Up"
                GestureDetector(
                  onTap: () {
                    // Navigate to the AdminSignUpPage
                    Navigator.push(
                      context,
                      FadePageRoute(
                        page: AdminSignUpPage(),
                      ), // <-- Changed
                    );
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Don't have an account yet? ",
                      style: GoogleFonts.lato(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign Up",
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

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

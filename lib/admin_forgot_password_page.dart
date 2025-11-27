import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminForgotPasswordPage extends StatelessWidget {
  const AdminForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password", style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Admin Forgot Password Page - Under Construction",
          style: GoogleFonts.lato(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayAttendancePage extends StatelessWidget {
  const TodayAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Details", style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Detailed list of today's attendance...",
          style: GoogleFonts.lato(fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance History", style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Full attendance history/calendar...",
          style: GoogleFonts.lato(fontSize: 20),
        ),
      ),
    );
  }
}

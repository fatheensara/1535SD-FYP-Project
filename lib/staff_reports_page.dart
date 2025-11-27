import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffReportsPage extends StatelessWidget {
  const StaffReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Analytics & Insights",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Hide back button (handled by navbar)
      ),
      body: Stack(
        children: [
          // 1. DARK BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- OVERALL PERFORMANCE CARD ---
                  _buildGlassCard(
                    child: Row(
                      children: [
                        // Radial Indicator
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: 0.92,
                                strokeWidth: 8,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.cyanAccent,
                                ),
                              ),
                            ),
                            Text(
                              "92%",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Overall Attendance",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Excellent engagement across all 3 active classes.",
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- WEEKLY TRENDS HEADER ---
                  Text(
                    "Weekly Activity",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- CUSTOM BAR CHART ---
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar("Mon", 0.7, Colors.purpleAccent),
                            _buildBar("Tue", 0.85, Colors.pinkAccent),
                            _buildBar("Wed", 0.6, Colors.orangeAccent),
                            _buildBar("Thu", 0.9, Colors.cyanAccent),
                            _buildBar("Fri", 0.5, Colors.blueAccent),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // ignore: deprecated_member_use
                        Divider(color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Students: 142",
                              style: GoogleFonts.lato(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Avg: 85%",
                              style: GoogleFonts.lato(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- RECENT REPORTS HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Reports",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.filter_list, color: Colors.white54, size: 20),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- REPORTS LIST ---
                  _buildReportTile(
                    "CSCI 4333 - Attendance_Nov.pdf",
                    "2 mins ago",
                    Icons.picture_as_pdf,
                    Colors.redAccent,
                  ),
                  _buildReportTile(
                    "Semester_Summary_2024.csv",
                    "Yesterday",
                    Icons.table_chart,
                    Colors.greenAccent,
                  ),
                  _buildReportTile(
                    "Student_Absence_List.pdf",
                    "Oct 28",
                    Icons.picture_as_pdf,
                    Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Push up above nav bar
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.download),
          label: Text(
            "Export All",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBar(String label, double heightPct, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 100 * heightPct,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.lato(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildReportTile(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          time,
          style: GoogleFonts.lato(color: Colors.white38, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white38),
          onPressed: () {},
        ),
      ),
    );
  }
}

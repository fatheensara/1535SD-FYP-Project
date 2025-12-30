import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_page_route.dart';

// Import specific report pages (ensure these exist or create placeholders)
import 'staff_reports_pits_sect1.dart';
import 'staff_reports_pits_sect2.dart';
import 'staff_reports_netsec_sect1.dart';
import 'staff_reports_def_sect2.dart';

class StaffReportsPage extends StatelessWidget {
  const StaffReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- MOCK DATA FOR CLASSES ---
    final List<Map<String, dynamic>> classList = [
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 45,
        "section": "Section 1",
        "attendance": 0.92, // 92%
      },
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 40,
        "section": "Section 2",
        "attendance": 0.88, // 88%
      },
      {
        "code": "CSCI 4336",
        "name": "Network Security",
        "students": 38,
        "section": "Section 1",
        "attendance": 0.85, // 85%
      },
      {
        "code": "CSCI 4332",
        "name": "Digital Evidence Forensics",
        "students": 42,
        "section": "Section 2",
        "attendance": 0.95, // 95%
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Analytics & Reports",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A0038), // Deep Midnight Purple
                  Color(0xFF4A00E0), // Royal Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
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
                  // --- SUMMARY CARD (From File 1) ---
                  _buildSummaryCard(),

                  const SizedBox(height: 30),

                  Text(
                    "Subject Reports",
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- LIST OF SUBJECTS (From File 2) ---
                  ...classList.map((data) => _buildSubjectCard(context, data)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 1: SUMMARY GRAPH ---
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: 0.90, // Overall Average
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.cyanAccent,
                      ),
                    ),
                  ),
                  Text(
                    "90%",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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
                      "Weekly Overview",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Attendance is stable. No major drops detected this week.",
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mini Bar Chart
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
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightPct, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 60 * heightPct,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.lato(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  // --- WIDGET 2: SUBJECT LIST CARD ---
  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> data) {
    double attendance = data['attendance'];
    Color barColor = attendance > 0.9
        ? Colors.green
        : (attendance > 0.8 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // *** NAVIGATION LOGIC ***
            if (data['code'] == "CSCI 2303" && data['section'] == "Section 1") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffReportsPitsSect1Page()),
              );
            } else if (data['code'] == "CSCI 2303" &&
                data['section'] == "Section 2") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffReportsPitsSect2Page()),
              );
            } else if (data['code'] == "CSCI 4336" &&
                data['section'] == "Section 1") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffReportsNetsecSect1Page()),
              );
            } else if (data['code'] == "CSCI 4332" &&
                data['section'] == "Section 2") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffReportsDefSect2Page()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: const Color(0xFF4A00E0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              data['code'],
                              style: GoogleFonts.sourceCodePro(
                                color: const Color(0xFF4A00E0),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data['section'],
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: attendance,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation(barColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${(attendance * 100).toInt()}%",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: barColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

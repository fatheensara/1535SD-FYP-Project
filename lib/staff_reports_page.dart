import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_page_route.dart';

// Import specific report pages
import 'staff_reports_pits_sect1.dart';
import 'staff_reports_pits_sect2.dart';
import 'staff_reports_netsec_sect1.dart';
import 'staff_reports_def_sect2.dart';

class StaffReportsPage extends StatelessWidget {
  const StaffReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- UPDATE THESE VALUES TO MATCH YOUR OTHER FILES ---
    final List<Map<String, dynamic>> classList = [
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 45,
        "section": "Section 1",
        "attendance": 0.800, // 80.0%
      },
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 40,
        "section": "Section 2",
        "attendance": 0.798, // 79.8%
      },
      {
        "code": "CSCI 4336",
        "name": "Network Security",
        "students": 38,
        "section": "Section 1",
        "attendance": 0.804, // 80.4%
      },
      {
        "code": "CSCI 4332",
        "name": "Digital Evidence Forensics",
        "students": 42,
        "section": "Section 2",
        "attendance": 0.803, // 80.3%
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Subject Reports",
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
            height: 150, // Reduced height for simple header
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
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // 2. CONTENT LIST
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              itemCount: classList.length,
              itemBuilder: (context, index) {
                return _buildSubjectCard(context, classList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: SUBJECT LIST CARD ---
  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> data) {
    double attendance = data['attendance'];

    // Determine color based on threshold
    Color barColor = attendance >= 0.80
        ? Colors.green
        : (attendance > 0.70 ? Colors.orange : Colors.red);

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
                          // CHANGED: Formatted to 1 decimal place (e.g. 79.8%)
                          Text(
                            "${(attendance * 100).toStringAsFixed(1)}%",
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

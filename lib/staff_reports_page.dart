import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_page_route.dart';
import 'staff_reports_pits_sect1.dart';
import 'staff_reports_pits_sect2.dart';
import 'staff_reports_netsec_sect1.dart';
import 'staff_reports_def_sect2.dart'; // <--- New Import

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
      },
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 40,
        "section": "Section 2",
      },
      {
        "code": "CSCI 4336",
        "name": "Network Security",
        "students": 38,
        "section": "Section 1",
      },
      {
        "code": "CSCI 4332",
        "name": "Digital Evidence Forensics",
        "students": 42,
        "section": "Section 2", // <--- Triggers new page
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
            height: 220,
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
                  Text(
                    "Subject Overview",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Semester 1, 2025/2026",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- LIST OF SUBJECT CARDS ---
                  ...classList.map((data) => _buildSubjectCard(context, data)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> data) {
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
              // Navigate to Digital Evidence Forensics Page
              Navigator.push(
                context,
                FadePageRoute(page: const StaffReportsDefSect2Page()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Opening details for ${data['code']} ${data['section']}",
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${data['students']} Students Registered",
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Color(0xFF4A00E0),
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

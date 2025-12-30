import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_page_route.dart';
import 'staff_live_attendance_pits_sect1.dart'; // PITS Sect 1
import 'staff_live_attendance_pits_sect2.dart'; // PITS Sect 2
import 'staff_live_attendance_netsec_sect1.dart'; // NetSec Sect 1
import 'staff_live_attendance_def_sect2.dart'; // DEF Sect 2

class StaffAttendanceMonitorPage extends StatelessWidget {
  const StaffAttendanceMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- MOCK DATA FOR CLASSES ---
    final List<Map<String, dynamic>> classList = [
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 45,
        "section": "Section 1",
        "time": "08:30 AM - 10:00 AM",
      },
      {
        "code": "CSCI 2303",
        "name": "Principles of IT Security",
        "students": 40,
        "section": "Section 2",
        "time": "10:00 AM - 11:30 AM",
      },
      {
        "code": "CSCI 4336",
        "name": "Network Security",
        "students": 38,
        "section": "Section 1",
        "time": "02:00 PM - 03:30 PM",
      },
      {
        "code": "CSCI 4332",
        "name": "Digital Evidence Forensics",
        "students": 42,
        "section": "Section 2",
        "time": "11:30 AM - 01:00 PM",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Attendance Monitor",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0038), Color(0xFF4A00E0)],
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
                    "Select Class",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Start Live Monitoring",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- LIST OF CLASSES ---
                  ...classList.map((data) => _buildClassCard(context, data)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildClassCard(BuildContext context, Map<String, dynamic> data) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
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
                FadePageRoute(page: const StaffLiveAttendancePitsSect1Page()),
              );
            } else if (data['code'] == "CSCI 2303" &&
                data['section'] == "Section 2") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffLiveAttendancePitsSect2Page()),
              );
            } else if (data['code'] == "CSCI 4336" &&
                data['section'] == "Section 1") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffLiveAttendanceNetsecSect1Page()),
              );
            } else if (data['code'] == "CSCI 4332" &&
                data['section'] == "Section 2") {
              Navigator.push(
                context,
                FadePageRoute(page: const StaffLiveAttendanceDefSect2Page()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Class setup incomplete.")),
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
                      // ROW 1: Code + Subject Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A00E0)
                                        .withOpacity(0.1),
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
                                Flexible(
                                  child: Text(
                                    data['name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ROW 2: Section (Bold)
                      Text(
                        data['section'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 5),

                      // ROW 3: Time Only
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            data['time'],
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
                    Icons.qr_code_scanner_rounded,
                    size: 24,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffReportsPitsSect2Page extends StatelessWidget {
  const StaffReportsPitsSect2Page({super.key});

  @override
  Widget build(BuildContext context) {
    // --- MOCK DATA: 40 STUDENTS ---
    // Logic:
    // - w1_7 < 80 -> Warning (Orange)
    // - w1_14 < 80 -> Barred (Red)
    final List<Map<String, dynamic>> students = [
      {"name": "Ahmad A.", "w1_7": 92.0, "w1_14": 90.0},
      {"name": "Siti N.", "w1_7": 85.0, "w1_14": 88.0},
      {
        "name": "Chong W.",
        "w1_7": 75.0,
        "w1_14": 82.0,
      }, // Warning previously, recovered
      {"name": "Muthu K.", "w1_7": 60.0, "w1_14": 55.0}, // Barred
      {"name": "Alice T.", "w1_7": 100.0, "w1_14": 96.0},
      {
        "name": "Brendan",
        "w1_7": 78.0,
        "w1_14": 79.0,
      }, // Warning -> Barred Risk
      {"name": "Catherine", "w1_7": 92.0, "w1_14": 93.0},
      {"name": "Daniel L.", "w1_7": 40.0, "w1_14": 30.0}, // Barred
      {"name": "Elaine K.", "w1_7": 88.0, "w1_14": 85.0},
      {"name": "Farid R.", "w1_7": 70.0, "w1_14": 72.0}, // Barred (Red)
      {"name": "Gita P.", "w1_7": 95.0, "w1_14": 94.0},
      {"name": "Harris M.", "w1_7": 82.0, "w1_14": 80.0},
      {"name": "Izzat H.", "w1_7": 65.0, "w1_14": 68.0}, // Barred
      {"name": "Jenny L.", "w1_7": 90.0, "w1_14": 91.0},
      {"name": "Kevin T.", "w1_7": 50.0, "w1_14": 45.0}, // Barred
      {
        "name": "Liyana Z.",
        "w1_7": 79.0,
        "w1_14": 85.0,
      }, // Warning issued, recovered
      {"name": "Marcus", "w1_7": 88.0, "w1_14": 87.0},
      {"name": "Nadia S.", "w1_7": 93.0, "w1_14": 92.0},
      {"name": "Omar F.", "w1_7": 74.0, "w1_14": 70.0}, // Barred
      {"name": "Patricia", "w1_7": 85.0, "w1_14": 86.0},
      {"name": "Qistina", "w1_7": 100.0, "w1_14": 98.0},
      {"name": "Ravi J.", "w1_7": 68.0, "w1_14": 75.0}, // Barred
      {"name": "Sarah W.", "w1_7": 91.0, "w1_14": 90.0},
      {
        "name": "Tan Y.S.",
        "w1_7": 76.0,
        "w1_14": 81.0,
      }, // Warning issued, recovered
      {"name": "Umar K.", "w1_7": 84.0, "w1_14": 83.0},
      {"name": "Vivian", "w1_7": 55.0, "w1_14": 50.0}, // Barred
      {"name": "Wan A.", "w1_7": 96.0, "w1_14": 95.0},
      {"name": "Xavier", "w1_7": 80.0, "w1_14": 82.0},
      {"name": "Yusof I.", "w1_7": 72.0, "w1_14": 65.0}, // Barred
      {"name": "Zara B.", "w1_7": 89.0, "w1_14": 91.0},
      {
        "name": "Adam F.",
        "w1_7": 78.0,
        "w1_14": 80.0,
      }, // Warning issued, on edge
      {"name": "Bella C.", "w1_7": 94.0, "w1_14": 93.0},
      {"name": "Carl J.", "w1_7": 60.0, "w1_14": 58.0}, // Barred
      {"name": "Diana", "w1_7": 85.0, "w1_14": 88.0},
      {"name": "Eric L.", "w1_7": 90.0, "w1_14": 92.0},
      {"name": "Fatin N.", "w1_7": 75.0, "w1_14": 74.0}, // Barred
      {"name": "Gary H.", "w1_7": 82.0, "w1_14": 84.0},
      {"name": "Hana R.", "w1_7": 95.0, "w1_14": 96.0},
      {"name": "Imran", "w1_7": 65.0, "w1_14": 60.0}, // Barred
      {"name": "Jessica", "w1_7": 88.0, "w1_14": 89.0},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "CSCI 2303 - Sect 2",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
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
          // Header Background
          Container(
            height: 250,
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

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Title
                Text(
                  "Attendance Record",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Principles of IT Security (40 Students)",
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                // STUDENT LIST
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: students.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 20, color: Colors.black12),
                      itemBuilder: (context, index) {
                        return _buildStudentRow(students[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student) {
    double midSem = student['w1_7'];
    double overall = student['w1_14'];

    // LOGIC:
    // 1. Overall < 80 => RED (Barred)
    // 2. MidSem < 80 => ORANGE (Warning)
    // 3. Else => GREEN (Good)

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (overall < 80) {
      statusColor = Colors.red;
      statusText = "Barred";
      statusIcon = Icons.block;
    } else if (midSem < 80) {
      statusColor = Colors.orange;
      statusText = "Warning";
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = Colors.green;
      statusText = "Good";
      statusIcon = Icons.check_circle_outline;
    }

    return Row(
      children: [
        // 1. Avatar & Name
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade100,
          child: Text(
            student['name'][0],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A00E0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student['name'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                statusText.toUpperCase(),
                style: GoogleFonts.lato(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 2. Stats Column (Mid Sem)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "W1-7",
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey),
            ),
            Text(
              "${midSem.toInt()}%",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: midSem < 80 ? Colors.orange : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(width: 15),

        // 3. Stats Column (Overall)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "W1-14",
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey),
            ),
            Text(
              "${overall.toInt()}%",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: overall < 80 ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(width: 10),

        // 4. Action Icon
        Icon(statusIcon, color: statusColor, size: 20),
      ],
    );
  }
}

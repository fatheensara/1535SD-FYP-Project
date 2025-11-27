import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentScanActivityPage extends StatelessWidget {
  const StudentScanActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data: I have expanded your uploaded data to include "Subject" & "Location"
    // so the timeline design looks complete.
    final List<Map<String, dynamic>> logs = [
      {
        "subject": "CSCI 4300", // Added for context
        "name": "Computation & Complexity", // Added for context
        "device": "Lecturer Device (Dr. Nurul)", // From your file
        "time": DateTime.now().subtract(const Duration(minutes: 5)),
        "status": "Success",
        "location": "Lab 3", // Added for context
      },
      {
        "subject": "CSCI 4332",
        "name": "Digital Evidence Forensics",
        "device": "Lecturer Device (Dr. Andi)",
        "time": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        "status": "Success",
        "location": "Lecture Hall 2",
      },
      {
        "subject": "CSCI 4333",
        "name": "Cryptography",
        "device": "Main Hall Attendance", // From your file
        "time": DateTime.now().subtract(const Duration(days: 3)),
        "status": "Failed", // Changed one to failed to show design variety
        "location": "Main Hall",
      },
      {
        "subject": "CSCI 4300",
        "name": "Computation & Complexity",
        "device": "Lecturer Device (Dr. Nurul)",
        "time": DateTime.now().subtract(const Duration(days: 7)),
        "status": "Success",
        "location": "Lab 3",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Scan Activity",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: Column(
        children: [
          // --- 1. STREAK SUMMARY HEADER (Added for "Interesting" Design) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_edu,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Activity",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "You have ${logs.length} scan records this week.",
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. TIMELINE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                bool isLast = index == logs.length - 1;
                return _buildTimelineItem(log, isLast);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> log, bool isLast) {
    bool isSuccess = log['status'] == 'Success';
    Color statusColor = isSuccess ? Colors.green : Colors.red;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. LEFT: TIME COLUMN
          SizedBox(
            width: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('d MMM').format(log['time']),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
                Text(
                  DateFormat('h:mm a').format(log['time']),
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // B. MIDDLE: TIMELINE LINE
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // The Dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // The Line
                Expanded(
                  child: isLast
                      ? Container()
                      : Container(width: 2, color: Colors.grey.shade300),
                ),
              ],
            ),
          ),

          // C. RIGHT: THE CARD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isSuccess
                      ? Border.all(color: Colors.transparent)
                      : Border.all(color: Colors.red.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Subject Code & Status Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log['subject'],
                              style: GoogleFonts.sourceCodePro(
                                color: Colors.purple.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSuccess ? Icons.check_circle : Icons.error,
                                  color: statusColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSuccess ? "Verified" : "Failed",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Class Name
                      Text(
                        log['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 12),

                      // Device Info Row
                      Row(
                        children: [
                          Icon(
                            Icons.nfc_rounded,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log['device'],
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location Row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            log['location'],
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                      // Error Message if failed
                      if (!isSuccess)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Connection interrupted. Please try scanning again manually.",
                                  style: GoogleFonts.lato(
                                    color: Colors.red.shade800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentScanActivityPage extends StatefulWidget {
  const StudentScanActivityPage({super.key});

  @override
  State<StudentScanActivityPage> createState() =>
      _StudentScanActivityPageState();
}

class _StudentScanActivityPageState extends State<StudentScanActivityPage> {
  // State for Dropdown
  String _selectedFilter = "Current Week";

  // --- MOCK DATA: CURRENT WEEK (Synced with Alerts & History) ---
  final List<Map<String, dynamic>> _currentWeekLogs = [
    {
      "subject": "CSCI 4332",
      "code": "DEF",
      "name": "Digital Evidence Forensics",
      "action": "MC Submission", // New Action Type
      "device": "Student App Upload",
      "time": DateTime.now().subtract(
        const Duration(minutes: 2),
      ), // Matches Alert
      "status": "Pending", // Status reflected in Alerts
      "location": "Online",
      "type": "submission", // submission vs scan
    },
    {
      "subject": "CSCI 4402",
      "code": "FYP2",
      "name": "Final Year Project II",
      "action": "Class Attendance",
      "device": "Lecturer Device (Dr. Ahmad Anwar bin Zainuddin)",
      "time": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      "status": "Success",
      "location": "MPH KICT",
      "type": "scan",
    },
    {
      "subject": "CSCI 4336",
      "code": "NETSEC",
      "name": "Network Security",
      "action": "Class Attendance",
      "device": "Lecturer Device (Dr. Andi Fitriah binti Abdul Kadir)",
      "time": DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      "status": "Success",
      "location": "Computer Lab 2",
      "type": "scan",
    },
  ];

  // --- MOCK DATA: PAST ACTIVITY ---
  final List<Map<String, dynamic>> _pastLogs = [
    {
      "subject": "CSCI 4333",
      "code": "CRYPTO",
      "name": "Cryptography",
      "action": "Class Attendance",
      "device": "Main Hall Attendance",
      "time": DateTime.now().subtract(const Duration(days: 8)),
      "status": "Failed", // Example of failure
      "location": "Main Hall",
      "type": "scan",
    },
    {
      "subject": "CSCI 4300",
      "code": "COMP",
      "name": "Computation & Complexity",
      "action": "Class Attendance",
      "device": "Lecturer Device (Dr. Nurul)",
      "time": DateTime.now().subtract(const Duration(days: 9)),
      "status": "Success",
      "location": "Lecture Hall 1",
      "type": "scan",
    },
    {
      "subject": "CSCI 4332",
      "code": "DEF",
      "name": "Digital Evidence Forensics",
      "action": "Class Attendance",
      "device": "Lab 3 NFC Reader",
      "time": DateTime.now().subtract(const Duration(days: 10)),
      "status": "Success",
      "location": "Computer Lab 3",
      "type": "scan",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Select data source based on dropdown
    final List<Map<String, dynamic>> logs = _selectedFilter == "Current Week"
        ? _currentWeekLogs
        : _pastLogs;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Activity Log",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. FILTER HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_toggle_off,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "View Activity",
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // DROPDOWN BUTTON
                        DropdownButton<String>(
                          value: _selectedFilter,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          isDense: true,
                          underline: const SizedBox(), // Remove underline
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFilter = newValue!;
                            });
                          },
                          items: <String>['Current Week', 'Past Activity']
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                              .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. TIMELINE LIST ---
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      "No records found.",
                      style: GoogleFonts.lato(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 30,
                    ),
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
    bool isPending = log['status'] == 'Pending';

    // Color Logic
    Color statusColor;
    if (isPending) {
      statusColor = Colors.orange;
    } else if (isSuccess) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    // Icon Logic
    IconData actionIcon;
    if (log['type'] == 'submission') {
      actionIcon = Icons.upload_file;
    } else {
      actionIcon = Icons.nfc;
    }

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
                      // ignore: deprecated_member_use
                      : Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Subject Code & Status Badge
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
                                  isSuccess
                                      ? Icons.check_circle
                                      : (isPending
                                            ? Icons.hourglass_top
                                            : Icons.error),
                                  color: statusColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  log['status'],
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

                      // Activity Name (Scan or Submission)
                      Row(
                        children: [
                          Icon(actionIcon, size: 18, color: Colors.black87),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log['action'], // "Class Attendance" or "MC Submission"
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        log['name'], // Subject Name
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 12),

                      // Device/Source Info
                      Row(
                        children: [
                          Icon(
                            Icons.devices,
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

                      // Specific Error Message
                      if (!isSuccess && !isPending)
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

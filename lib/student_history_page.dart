import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// =========================================================
// PAGE 1: HYBRID HISTORY PAGE (REAL + MOCK FALLBACK)
// =========================================================
class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({super.key});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  // --- 1. REAL DATA CALCULATOR ---
  Map<String, dynamic> _calculateRealStats(List<QueryDocumentSnapshot> docs) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    // Group by Subject
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      String subject = data['courseName'] ?? "Unknown Subject";

      if (!groupedData.containsKey(subject)) {
        groupedData[subject] = [];
      }

      groupedData[subject]!.add({
        'date': (data['timestamp'] as Timestamp).toDate(),
        'status': data['status'] ?? 'Absent',
        'week': _calculateWeek((data['timestamp'] as Timestamp).toDate()),
        'time': DateFormat(
          'h:mm a',
        ).format((data['timestamp'] as Timestamp).toDate()), // Add Time
      });
    }

    return _processGroupedData(groupedData);
  }

  // --- 2. MOCK DATA GENERATOR (FALLBACK) ---
  Map<String, dynamic> _generateMockStats() {
    DateTime semStart = DateTime(2025, 10, 6);
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    // Helper to generate dates
    List<Map<String, dynamic>> generateClassDates(
      String title,
      String time,
      int d1,
      int d2,
      List<bool> pattern,
    ) {
      List<Map<String, dynamic>> classes = [];
      int pIndex = 0;
      for (int week = 0; week < 14; week++) {
        DateTime weekStart = semStart.add(Duration(days: week * 7));

        // Day 1
        if (pIndex < pattern.length) {
          classes.add({
            "date": weekStart.add(Duration(days: d1 - 1)),
            "status": pattern[pIndex] ? "Present" : "Absent",
            "week": week + 1,
            "time": time,
          });
          pIndex++;
        }
        // Day 2
        if (d2 != -1 && pIndex < pattern.length) {
          classes.add({
            "date": weekStart.add(Duration(days: d2 - 1)),
            "status": pattern[pIndex] ? "Present" : "Absent",
            "week": week + 1,
            "time": time,
          });
          pIndex++;
        }
      }
      // Sort descending (newest first)
      classes.sort((a, b) => b['date'].compareTo(a['date']));
      return classes;
    }

    // Mock Scenario: Warning Letter
    final List<bool> patternWarning = List.filled(28, true);
    patternWarning[2] = false;
    patternWarning[5] = false;
    patternWarning[8] = false; // 3 Absences
    groupedData["CSCI 4300 - Computation"] = generateClassDates(
      "CSCI 4300",
      "10:00 AM",
      1,
      3,
      patternWarning,
    );

    // Mock Scenario: Perfect Attendance
    groupedData["CSCI 4402 - Final Year Project II"] = generateClassDates(
      "CSCI 4402",
      "11:30 AM",
      1,
      -1,
      List.filled(14, true),
    );

    // Mock Scenario: Barred
    final List<bool> patternBarred = List.filled(28, true);
    for (int i = 0; i < 8; i++) patternBarred[i * 3] = false; // Many absences
    groupedData["CSCI 4336 - Network Security"] = generateClassDates(
      "CSCI 4336",
      "02:00 PM",
      2,
      4,
      patternBarred,
    );

    return _processGroupedData(groupedData);
  }

  // --- 3. SHARED PROCESSOR (CALCULATES %) ---
  Map<String, dynamic> _processGroupedData(
    Map<String, List<Map<String, dynamic>>> groupedData,
  ) {
    Map<String, Map<String, dynamic>> finalStats = {};

    groupedData.forEach((subject, records) {
      int total = records.length;
      int attended = records
          .where((e) => e['status'] == 'Present' || e['status'] == 'Late')
          .length;
      double percent = total == 0 ? 0 : (attended / total) * 100;

      String statusText = "GOOD";
      Color statusColor = Colors.green;
      String letterAction = "";

      if (percent < 80) {
        if (percent < 60) {
          statusText = "BARRED";
          statusColor = Colors.red;
          letterAction = "Barred Letter Issued";
        } else {
          statusText = "WARNING";
          statusColor = Colors.orange;
          letterAction = "Warning Letter Issued";
        }
      }

      finalStats[subject] = {
        'percent': percent,
        'status': statusText,
        'color': statusColor,
        'letterAction': letterAction,
        'total': total,
        'attended': attended,
        'history': records, // The list of dates
      };
    });

    return finalStats;
  }

  int _calculateWeek(DateTime date) {
    DateTime semStart = DateTime(2025, 10, 1);
    int daysDiff = date.difference(semStart).inDays;
    return (daysDiff / 7).ceil().clamp(1, 14);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                // ignore: deprecated_member_use
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF4A00E0).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Attendance Summary",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Sem 1, 2025/2026",
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart, color: Colors.white),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (user != null)
                  ? FirebaseFirestore.instance
                        .collection('attendance_records')
                        .where('studentUid', isEqualTo: user.uid)
                        .snapshots()
                  : null,
              builder: (context, snapshot) {
                // 1. DECIDE: REAL OR MOCK?
                Map<String, dynamic> stats;
                bool isUsingMock = false;

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // NO REAL DATA -> SHOW MOCK
                  stats = _generateMockStats();
                  isUsingMock = true;
                } else {
                  // HAS REAL DATA -> SHOW REAL
                  stats = _calculateRealStats(snapshot.data!.docs);
                }

                return Column(
                  children: [
                    // Mode Indicator (Optional, remove if you want it hidden)
                    if (isUsingMock)
                      Container(
                        width: double.infinity,
                        color: Colors.amber.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Demo Mode: Scanning a class will switch to Real Data",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: Colors.brown,
                          ),
                        ),
                      ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          String subject = stats.keys.elementAt(index);
                          var data = stats[subject]!;
                          return _buildSubjectSummaryCard(subject, data);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSummaryCard(String title, Map<String, dynamic> data) {
    // Clean up title (remove code if needed)
    String displayTitle = title;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailPage(
              subjectTitle: title,
              historyData: data['history'], // Pass specific history
              stats: data,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // ignore: deprecated_member_use
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${data['attended']} / ${data['total']} Classes Attended",
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: data['percent'] / 100,
                      backgroundColor: Colors.grey.shade100,
                      color: data['color'],
                      strokeWidth: 6,
                    ),
                    Text(
                      "${data['percent'].toInt()}%",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: data['color'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildMiniStat("Status", data['status'], data['color']),
              ],
            ),
            if (data['letterAction'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data['letterAction'],
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.lato(fontSize: 10, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// PAGE 2: DETAIL HISTORY PAGE (Reused)
// =========================================================
class SubjectDetailPage extends StatefulWidget {
  final String subjectTitle;
  final List<Map<String, dynamic>> historyData;
  final Map<String, dynamic> stats;

  const SubjectDetailPage({
    super.key,
    required this.subjectTitle,
    required this.historyData,
    required this.stats,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text("Take Photo"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text("Choose from Gallery"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = widget.stats['color'];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Class History",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [themeColor, themeColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(24),
              // ignore: deprecated_member_use
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: themeColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.subjectTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  // ignore: deprecated_member_use
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${widget.stats['attended']} / ${widget.stats['total']} Attended",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: widget.historyData.length,
              itemBuilder: (context, index) {
                final record = widget.historyData[index];
                bool isAbsent = record['status'] == 'Absent';
                String dateStr = DateFormat('MMM d, y').format(record['date']);
                String weekStr = "Week ${record['week']}";
                String timeStr = record['time'] ?? "10:00 AM";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: isAbsent ? Colors.red : Colors.green,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weekStr,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          dateStr,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            record['status'].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAbsent ? Colors.red : Colors.green,
                            ),
                          ),
                          if (isAbsent)
                            InkWell(
                              onTap: () => _showUploadOptions(context),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "Attach MC",
                                  style: GoogleFonts.lato(
                                    fontSize: 10,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// =========================================================
// PAGE 1: MAIN SUMMARY PAGE
// =========================================================
class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({super.key});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  // Data holder
  Map<String, List<Map<String, dynamic>>> _groupedData = {};
  final Map<String, Map<String, dynamic>> _subjectStats = {};

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  // --- MOCK DATA GENERATOR ---
  void _generateMockData() {
    DateTime semStart = DateTime(2025, 10, 6);

    // Helper function
    List<Map<String, dynamic>> generateClassDates(
      String title,
      String time,
      int dayOfWeek1, // 1=Mon, 2=Tue...
      int dayOfWeek2, // If -1, only 1 class/week
      List<bool> attendancePattern, {
      int maxWeeks = 14,
    }) {
      List<Map<String, dynamic>> classes = [];
      int patternIndex = 0;

      for (int week = 0; week < maxWeeks; week++) {
        DateTime weekStart = semStart.add(Duration(days: week * 7));

        // Class 1
        DateTime class1Date = weekStart.add(Duration(days: dayOfWeek1 - 1));
        if (patternIndex < attendancePattern.length) {
          bool isPresent = attendancePattern[patternIndex];
          classes.add({
            "date": class1Date,
            "title": title,
            "time": time,
            "status": isPresent ? "Present" : "Absent",
            "week": week + 1,
          });
          patternIndex++;
        }

        // Class 2 (Only if dayOfWeek2 is not -1)
        if (dayOfWeek2 != -1) {
          DateTime class2Date = weekStart.add(Duration(days: dayOfWeek2 - 1));
          if (patternIndex < attendancePattern.length) {
            bool isPresent = attendancePattern[patternIndex];
            classes.add({
              "date": class2Date,
              "title": title,
              "time": time,
              "status": isPresent ? "Present" : "Absent",
              "week": week + 1,
            });
            patternIndex++;
          }
        }
      }
      classes.sort((a, b) => b['date'].compareTo(a['date']));
      return classes;
    }

    // --- SCENARIO 1: CSCI 4300 (Warning Mid-Sem -> Good Overall) ---
    final List<bool> pattern1 = List.filled(28, true);
    pattern1[2] = false; // Absent W2
    pattern1[5] = false; // Absent W3
    pattern1[8] = false; // Absent W5 (Total 3 absences in first 7 weeks)

    var sub1 = generateClassDates(
      "CSCI 4300 - Computation and Complexity",
      "10:00 AM",
      1,
      3,
      pattern1, // Mon & Wed
    );

    // --- SCENARIO 2: CSCI 4332 (DEF) ---
    final List<bool> patternDEF = List.filled(28, true);
    // Student starts skipping in Week 9, 10, 11
    patternDEF[16] = false;
    patternDEF[17] = false;
    patternDEF[18] = false;
    patternDEF[19] = false;
    patternDEF[20] = false;
    patternDEF[21] = false;
    patternDEF[25] = false;

    var subDEF = generateClassDates(
      "CSCI 4332 - Digital Evidence Forensics",
      "11:30 AM",
      2,
      4,
      patternDEF, // Tue & Thu
    );

    // Other Subjects (Standard)
    final List<bool> patternGood = List.filled(28, true);
    var subFYP = generateClassDates(
      "CSCI 4402 - Final Year Project II",
      "11:30 AM",
      1,
      4,
      patternGood,
    );

    final List<bool> patternBarred = List.filled(28, true);
    // ignore: curly_braces_in_flow_control_structures
    for (int i = 0; i < 8; i++) patternBarred[i * 3] = false; // Barred
    var subNetSec = generateClassDates(
      "CSCI 4336 - Network Security",
      "02:00 PM",
      2,
      5,
      patternBarred,
    );

    var subCrypto = generateClassDates(
      "CSCI 4333 - Cryptography",
      "02:00 PM",
      1,
      3,
      patternGood,
    );

    _groupedData = {
      "CSCI 4300 - Computation and Complexity": sub1,
      "CSCI 4332 - Digital Evidence Forensics": subDEF,
      "CSCI 4402 - Final Year Project II": subFYP,
      "CSCI 4336 - Network Security": subNetSec,
      "CSCI 4333 - Cryptography": subCrypto,
    };

    // --- CALCULATE STATS ---
    _groupedData.forEach((subject, records) {
      // 1. Calculate Mid-Sem Stats
      var midRecords = records.where((e) => e['week'] <= 7).toList();
      int midTotal = midRecords.length;
      int midAttended = midRecords
          .where((e) => e['status'] == 'Present')
          .length;
      double midPercent = midTotal == 0 ? 0 : (midAttended / midTotal) * 100;

      String midStatus = "GOOD";
      Color midColor = Colors.green;
      String midLetter = "";

      if (midPercent < 80) {
        midStatus = "WARNING";
        midColor = Colors.orange;
        midLetter = "Warning Letter Issued";
      }

      // 2. Calculate Overall Stats
      var allRecords = records;
      int allTotal = allRecords.length;
      int allAttended = allRecords
          .where((e) => e['status'] == 'Present')
          .length;
      double allPercent = allTotal == 0 ? 0 : (allAttended / allTotal) * 100;

      String allStatus = "GOOD";
      Color allColor = Colors.green;
      String allLetter = "";

      // Logic: No Warning = No Barred
      if (allPercent < 80) {
        if (midPercent >= 80) {
          allStatus = "ATTENTION";
          allColor = Colors.amber.shade700;
          allLetter = "";
        } else {
          allStatus = "BARRED";
          allColor = Colors.redAccent;
          allLetter = "Barred Letter Issued";
        }
      } else if (midPercent < 80 && allPercent >= 80) {
        allStatus = "GOOD";
        allColor = Colors.green;
      }

      _subjectStats[subject] = {
        'midSem': {
          'percent': midPercent,
          'status': midStatus,
          'color': midColor,
          'letterAction': midLetter,
          'total': midTotal,
          'attended': midAttended,
        },
        'overall': {
          'percent': allPercent,
          'status': allStatus,
          'color': allColor,
          'letterAction': allLetter,
          'total': allTotal,
          'attended': allAttended,
        },
        'mainColor': allPercent < 80
            ? allColor
            : (midPercent < 80 ? Colors.orange : Colors.green),
      };
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _groupedData.keys.length,
              itemBuilder: (context, index) {
                String subjectName = _groupedData.keys.elementAt(index);
                var stats = _subjectStats[subjectName]!;
                return _buildSubjectSummaryCard(
                  subjectName,
                  stats,
                  _groupedData[subjectName]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSummaryCard(
    String title,
    Map<String, dynamic> stats,
    List<Map<String, dynamic>> history,
  ) {
    List<String> parts = title.split('-');
    String code = parts[0].trim();
    String name = parts.length > 1 ? parts[1].trim() : "";
    var midStats = stats['midSem'];
    var allStats = stats['overall'];
    // ignore: unused_local_variable
    Color themeColor = stats['mainColor'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailPage(
              subjectTitle: title,
              historyData: history,
              fullStats: stats,
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
                        code,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    "Mid-Sem (W1-7)",
                    midStats['percent'],
                    midStats['color'],
                    midStats['status'],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: _buildMiniStat(
                    "Overall (W1-14)",
                    allStats['percent'],
                    allStats['color'],
                    allStats['status'],
                  ),
                ),
              ],
            ),
            if (midStats['letterAction'].isNotEmpty ||
                allStats['letterAction'].isNotEmpty) ...[
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
                      allStats['letterAction'].isNotEmpty
                          ? allStats['letterAction']
                          : midStats['letterAction'],
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

  Widget _buildMiniStat(
    String label,
    double percent,
    Color color,
    String status,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "${percent.toInt()}%",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: GoogleFonts.lato(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =========================================================
// PAGE 2: DETAIL HISTORY PAGE
// =========================================================
class SubjectDetailPage extends StatefulWidget {
  final String subjectTitle;
  final List<Map<String, dynamic>> historyData;
  final Map<String, dynamic> fullStats;

  const SubjectDetailPage({
    super.key,
    required this.subjectTitle,
    required this.historyData,
    required this.fullStats,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  int _selectedView = 1;

  // --- UPDATED: FIXED UPLOAD OPTIONS (NO OVERFLOW) ---
  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Prevents keyboard overflow issues too
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          // SafeArea prevents bottom navigation bar overlap
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min, // THIS FIXES THE 2 PIXEL OVERFLOW
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Attach MC Letter",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: Text(
                    "Take Photo",
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Colors.purple,
                    ),
                  ),
                  title: Text(
                    "Choose from Gallery",
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.folder, color: Colors.orange),
                  ),
                  title: Text(
                    "Select File",
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
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
    var currentStats = _selectedView == 0
        ? widget.fullStats['midSem']
        : widget.fullStats['overall'];
    Color themeColor = currentStats['color'];

    List<Map<String, dynamic>> filteredHistory = widget.historyData.where((
      record,
    ) {
      if (_selectedView == 0) return record['week'] <= 7;
      return true;
    }).toList();

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
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [themeColor, themeColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
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
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${currentStats['attended']} / ${currentStats['total']} Attended",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: _selectedView == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedView = 0),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            "Week 1-7",
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: _selectedView == 0
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedView = 1),
                        child: Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            "Overall (W1-14)",
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              color: _selectedView == 1
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filteredHistory.length,
              itemBuilder: (context, index) {
                final record = filteredHistory[index];
                bool isAbsent = record['status'] == 'Absent';

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
                        children: [
                          Text(
                            "WEEK",
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "${record['week']}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMM').format(record['date']),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              record['time'],
                              style: GoogleFonts.lato(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isAbsent ? "ABSENT" : "PRESENT",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAbsent ? Colors.red : Colors.green,
                            ),
                          ),
                          if (isAbsent) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _showUploadOptions(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.upload_file_rounded,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Attach MC",
                                      style: GoogleFonts.lato(
                                        fontSize: 10,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

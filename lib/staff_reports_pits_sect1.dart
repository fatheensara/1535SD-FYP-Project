import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// --- PACKAGES FOR EXPORTING ---
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StaffReportsPitsSect1Page extends StatefulWidget {
  const StaffReportsPitsSect1Page({super.key});

  @override
  State<StaffReportsPitsSect1Page> createState() =>
      _StaffReportsPitsSect1PageState();
}

class _StaffReportsPitsSect1PageState extends State<StaffReportsPitsSect1Page> {
  // Filter State
  String _selectedFilter = 'All'; // Options: 'All', 'Warning', 'Barred'

  // --- MOCK DATA: 45 STUDENTS ---
  final List<Map<String, dynamic>> _allStudents = [
    {"name": "Aaron Lim", "w1_7": 95.0, "w1_14": 94.0},
    {"name": "Amira H.", "w1_7": 82.0, "w1_14": 85.0},
    {"name": "Benjamin T.", "w1_7": 65.0, "w1_14": 60.0}, // Barred
    {"name": "Cassandra", "w1_7": 78.0, "w1_14": 81.0}, // Warning -> Recovered
    {"name": "Dinesh K.", "w1_7": 88.0, "w1_14": 90.0},
    {"name": "Elena R.", "w1_7": 45.0, "w1_14": 40.0}, // Barred
    {"name": "Faizal M.", "w1_7": 92.0, "w1_14": 95.0},
    {"name": "Grace Lee", "w1_7": 75.0, "w1_14": 80.0}, // Warning -> Recovered
    {"name": "Hafiz S.", "w1_7": 70.0, "w1_14": 65.0}, // Barred
    {"name": "Iris Wong", "w1_7": 98.0, "w1_14": 97.0},
    {"name": "Jason C.", "w1_7": 85.0, "w1_14": 84.0},
    {"name": "Khairul A.", "w1_7": 55.0, "w1_14": 50.0}, // Barred
    {"name": "Latifah", "w1_7": 90.0, "w1_14": 92.0},
    {"name": "Michelle", "w1_7": 79.0, "w1_14": 82.0}, // Warning -> Recovered
    {"name": "Nathan", "w1_7": 88.0, "w1_14": 89.0},
    {"name": "Olivia P.", "w1_7": 94.0, "w1_14": 93.0},
    {"name": "Peter Tan", "w1_7": 60.0, "w1_14": 58.0}, // Barred
    {"name": "Qayla R.", "w1_7": 91.0, "w1_14": 90.0},
    {"name": "Ramesh V.", "w1_7": 76.0, "w1_14": 85.0}, // Warning -> Recovered
    {"name": "Sarah J.", "w1_7": 100.0, "w1_14": 99.0},
    {"name": "Taufiq H.", "w1_7": 82.0, "w1_14": 80.0},
    {"name": "Umairah", "w1_7": 74.0, "w1_14": 72.0}, // Barred
    {"name": "Victor L.", "w1_7": 89.0, "w1_14": 91.0},
    {"name": "Wei Ming", "w1_7": 68.0, "w1_14": 65.0}, // Barred
    {"name": "Xandra", "w1_7": 93.0, "w1_14": 94.0},
    {"name": "Yusri B.", "w1_7": 85.0, "w1_14": 86.0},
    {"name": "Zahra K.", "w1_7": 77.0, "w1_14": 81.0}, // Warning -> Recovered
    {"name": "Adam Lee", "w1_7": 96.0, "w1_14": 95.0},
    {"name": "Brian Goh", "w1_7": 50.0, "w1_14": 48.0}, // Barred
    {"name": "Cindy T.", "w1_7": 88.0, "w1_14": 87.0},
    {"name": "David C.", "w1_7": 92.0, "w1_14": 91.0},
    {"name": "Esther Y.", "w1_7": 75.0, "w1_14": 78.0}, // Warning -> Risk
    {"name": "Farhan Z.", "w1_7": 84.0, "w1_14": 83.0},
    {"name": "Gavin S.", "w1_7": 62.0, "w1_14": 59.0}, // Barred
    {"name": "Hana Lim", "w1_7": 95.0, "w1_14": 96.0},
    {"name": "Isaac N.", "w1_7": 88.0, "w1_14": 89.0},
    {"name": "Julia R.", "w1_7": 42.0, "w1_14": 40.0}, // Barred
    {"name": "Kamal D.", "w1_7": 81.0, "w1_14": 82.0},
    {"name": "Lisa M.", "w1_7": 90.0, "w1_14": 91.0},
    {"name": "Manny P.", "w1_7": 78.0, "w1_14": 80.0}, // Warning -> Recovered
    {"name": "Nina O.", "w1_7": 93.0, "w1_14": 94.0},
    {"name": "Oscar T.", "w1_7": 58.0, "w1_14": 55.0}, // Barred
    {"name": "Penny L.", "w1_7": 86.0, "w1_14": 88.0},
    {"name": "Quinn S.", "w1_7": 72.0, "w1_14": 70.0}, // Barred
    {"name": "Ryan K.", "w1_7": 97.0, "w1_14": 96.0},
  ];

  // Logic Helpers
  bool _isBarred(Map<String, dynamic> s) => s['w1_14'] < 80;
  bool _isWarning(Map<String, dynamic> s) => s['w1_7'] < 80 && s['w1_14'] >= 80;

  List<Map<String, dynamic>> get _filteredList {
    if (_selectedFilter == 'Barred') {
      return _allStudents.where((s) => _isBarred(s)).toList();
    } else if (_selectedFilter == 'Warning') {
      return _allStudents.where((s) => _isWarning(s)).toList();
    }
    return _allStudents;
  }

  // --- 1. EXPORT TO EXCEL LOGIC ---
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['PITS_Sect1_Report'];
    excel.setDefaultSheet('PITS_Sect1_Report');

    // Headers
    sheet.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Mid-Sem (W1-7)'),
      TextCellValue('Overall (W1-14)'),
      TextCellValue('Status'),
    ]);

    // Rows
    for (var s in _allStudents) {
      String status = "Good";

      // FIX: Added curly braces to satisfy linter
      if (_isBarred(s)) {
        status = "Barred";
      } else if (_isWarning(s)) {
        status = "Warning";
      }

      sheet.appendRow([
        TextCellValue(s['name']),
        DoubleCellValue(s['w1_7']),
        DoubleCellValue(s['w1_14']),
        TextCellValue(status),
      ]);
    }

    // Save & Share
    try {
      var fileBytes = excel.save();
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/PITS_Section1_Attendance.xlsx";

      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      await Share.shareXFiles([
        XFile(path),
      ], text: 'Attendance Report for PITS Section 1');
    } catch (e) {
      // FIX: Added mounted check before using context
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Export Error: $e")));
    }
  }

  // --- 2. GENERATE SUMMARY REPORT LOGIC ---
  void _generateSummaryReport() {
    int total = _allStudents.length;
    int barred = _allStudents.where((s) => _isBarred(s)).length;
    int warning = _allStudents.where((s) => _isWarning(s)).length;
    double avg =
        _allStudents.map((s) => s['w1_14'] as double).reduce((a, b) => a + b) /
        total;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_rounded, color: Color(0xFF4A00E0)),
                const SizedBox(width: 10),
                Text(
                  "Performance Summary",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildSummaryRow("Total Students", "$total", Colors.black87),
            _buildSummaryRow(
              "Class Average",
              "${avg.toStringAsFixed(1)}%",
              Colors.blue,
            ),
            _buildSummaryRow("At Risk (Warning)", "$warning", Colors.orange),
            _buildSummaryRow("Barred Candidates", "$barred", Colors.red),
            const SizedBox(height: 30),

            // Button inside report to download excel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  _exportToExcel(); // Trigger export
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text("Download Excel Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int warningCount = _allStudents.where((s) => _isWarning(s)).length;
    int barredCount = _allStudents.where((s) => _isBarred(s)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "CSCI 2303 - Sect 1",
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
                Text(
                  "Attendance Record",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Principles of IT Security (Section 1)",
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
                const SizedBox(height: 20),

                // FILTER TABS
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _buildFilterTab("All", _allStudents.length.toString()),
                      _buildFilterTab("Warning", warningCount.toString()),
                      _buildFilterTab("Barred", barredCount.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

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
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
                      itemCount: _filteredList.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 20, color: Colors.black12),
                      itemBuilder: (context, index) {
                        return _buildStudentRow(_filteredList[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // "Release Letters" Button (Only shows when filtered)
          if (_selectedFilter != 'All' && _filteredList.isNotEmpty)
            Positioned(
              bottom: 100, // Moved up slightly to not overlap FAB
              left: 40,
              right: 40,
              child: _buildReleaseButton(),
            ),
        ],
      ),

      // --- EXPORT / REPORT BUTTON (Floating Action Button) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open Bottom Sheet Menu
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Option 1: Excel
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(
                        Icons.table_view_rounded,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      "Export Data to Excel",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Download .xlsx file",
                      style: GoogleFonts.lato(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _exportToExcel();
                    },
                  ),
                  const Divider(),
                  // Option 2: Report
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.analytics_rounded, color: Colors.blue),
                    ),
                    title: Text(
                      "Generate Summary Report",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "View stats and insights",
                      style: GoogleFonts.lato(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _generateSummaryReport();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF4A00E0),
        // --- ICON & TEXT IN WHITE ---
        icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
        label: Text(
          "Export Report",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildFilterTab(String label, String count) {
    bool isSelected = _selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF4A00E0) : Colors.white70,
                ),
              ),
              Text(
                count,
                style: GoogleFonts.lato(
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF4A00E0) : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseButton() {
    String label = _selectedFilter == 'Warning'
        ? "Release Warning Letters"
        : "Release Barred Letters";
    Color color = _selectedFilter == 'Warning' ? Colors.orange : Colors.red;
    IconData icon = _selectedFilter == 'Warning'
        ? Icons.warning_rounded
        : Icons.block;

    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Processing: $label for ${_filteredList.length} students...",
            ),
            backgroundColor: color,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student) {
    double midSem = student['w1_7'];
    double overall = student['w1_14'];

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
        Icon(statusIcon, color: statusColor, size: 20),
      ],
    );
  }
}

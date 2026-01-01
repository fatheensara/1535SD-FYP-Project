import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- PACKAGES ---
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- PDF PACKAGES ---
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: unused_import
import 'package:printing/printing.dart';

class StaffReportsNetsecSect1Page extends StatefulWidget {
  const StaffReportsNetsecSect1Page({super.key});

  @override
  State<StaffReportsNetsecSect1Page> createState() =>
      _StaffReportsNetsecSect1PageState();
}

class _StaffReportsNetsecSect1PageState
    extends State<StaffReportsNetsecSect1Page> {
  // Filter State
  String _selectedFilter = 'All'; // Options: 'All', 'Warning', 'Barred'
  bool _isSending = false;

  // --- MOCK DATA: 38 STUDENTS (NetSec Sect 1) ---
  final List<Map<String, dynamic>> _allStudents = [
    {"name": "Alice Tan", "w1_7": 92.0, "w1_14": 90.0},
    {"name": "Bryan Lim", "w1_7": 85.0, "w1_14": 88.0},
    {"name": "Charles K.", "w1_7": 65.0, "w1_14": 60.0}, // Barred
    {"name": "Diana R.", "w1_7": 78.0, "w1_14": 82.0}, // Warning
    {"name": "Ethan Ho", "w1_7": 88.0, "w1_14": 89.0},
    {"name": "Fiona G.", "w1_7": 55.0, "w1_14": 50.0}, // Barred
    {"name": "George T.", "w1_7": 95.0, "w1_14": 94.0},
    {"name": "Hannah L.", "w1_7": 75.0, "w1_14": 80.0}, // Warning
    {"name": "Ian V.", "w1_7": 70.0, "w1_14": 68.0}, // Barred
    {"name": "Jessica M.", "w1_7": 98.0, "w1_14": 97.0},
    {"name": "Kevin S.", "w1_7": 85.0, "w1_14": 86.0},
    {"name": "Liam P.", "w1_7": 42.0, "w1_14": 40.0}, // Barred
    {"name": "Monica B.", "w1_7": 90.0, "w1_14": 92.0},
    {"name": "Nathan D.", "w1_7": 79.0, "w1_14": 81.0}, // Warning
    {"name": "Oliver Q.", "w1_7": 88.0, "w1_14": 87.0},
    {"name": "Patricia W.", "w1_7": 94.0, "w1_14": 93.0},
    {"name": "Quentin Z.", "w1_7": 60.0, "w1_14": 55.0}, // Barred
    {"name": "Rachel Y.", "w1_7": 91.0, "w1_14": 90.0},
    {"name": "Steven X.", "w1_7": 76.0, "w1_14": 82.0}, // Warning
    {"name": "Tiffany C.", "w1_7": 100.0, "w1_14": 99.0},
    {"name": "Umar F.", "w1_7": 82.0, "w1_14": 84.0},
    {"name": "Victor H.", "w1_7": 74.0, "w1_14": 70.0}, // Barred
    {"name": "Wendy J.", "w1_7": 89.0, "w1_14": 91.0},
    {"name": "Xavier K.", "w1_7": 68.0, "w1_14": 62.0}, // Barred
    {"name": "Yvonne N.", "w1_7": 93.0, "w1_14": 95.0},
    {"name": "Zack M.", "w1_7": 85.0, "w1_14": 86.0},
    {"name": "Adam O.", "w1_7": 77.0, "w1_14": 80.0}, // Warning
    {"name": "Bella P.", "w1_7": 96.0, "w1_14": 95.0},
    {"name": "Chris Q.", "w1_7": 50.0, "w1_14": 45.0}, // Barred
    {"name": "Daisy R.", "w1_7": 88.0, "w1_14": 89.0},
    {"name": "Edward S.", "w1_7": 92.0, "w1_14": 93.0},
    {"name": "Felicia T.", "w1_7": 75.0, "w1_14": 80.0}, // Warning
    {"name": "Greg U.", "w1_7": 84.0, "w1_14": 85.0},
    {"name": "Helen V.", "w1_7": 62.0, "w1_14": 58.0}, // Barred
    {"name": "Ivan W.", "w1_7": 95.0, "w1_14": 96.0},
    {"name": "Jenny X.", "w1_7": 81.0, "w1_14": 83.0},
    {"name": "Karl Y.", "w1_7": 72.0, "w1_14": 68.0}, // Barred
    {"name": "Lily Z.", "w1_7": 90.0, "w1_14": 91.0},
  ];

  // --- LOGIC HELPERS ---
  bool _isWarning(Map<String, dynamic> s) => s['w1_7'] < 80.0;
  bool _isBarred(Map<String, dynamic> s) =>
      s['w1_7'] < 80.0 && s['w1_14'] < 80.0;

  List<Map<String, dynamic>> get _filteredList {
    if (_selectedFilter == 'Barred') {
      return _allStudents.where((s) => _isBarred(s)).toList();
    } else if (_selectedFilter == 'Warning') {
      return _allStudents.where((s) => _isWarning(s)).toList();
    }
    return _allStudents;
  }

  // --- NOTIFICATION HELPER ---
  Future<void> _releaseNotifications(String type) async {
    setState(() => _isSending = true);

    List<Map<String, dynamic>> targetList;
    String title;
    String message;

    if (type == 'Warning') {
      targetList = _allStudents.where((s) => _isWarning(s)).toList();
      title = "Attendance Warning";
      message =
          "Your attendance for Week 1-7 is below 80%. Please submit a valid justification.";
    } else {
      targetList = _allStudents.where((s) => _isBarred(s)).toList();
      title = "Barring Notification";
      message =
          "You have been BARRED from the final exam due to low attendance (Week 1-14 < 80%).";
    }

    if (targetList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No students found for $type notifications.")),
        );
        setState(() => _isSending = false);
      }
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var student in targetList) {
        final docRef = FirebaseFirestore.instance
            .collection('student_notifications')
            .doc();
        batch.set(docRef, {
          'studentName': student['name'],
          'courseCode': 'CSCI 4336', // UPDATED COURSE CODE
          'type': type,
          'title': title,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
      await batch.commit();

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("$type Notifications Sent"),
            content: Text(
              "Successfully released notifications to ${targetList.length} students.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // --- PDF GENERATOR ---
  Future<List<int>> _makePdf() async {
    final pdf = pw.Document();
    final font = pw.Font.times();
    final fontBold = pw.Font.timesBold();

    pw.MemoryImage? image;
    try {
      final imageBytes = await rootBundle.load(
        'assets/IIUM_TAWHIDIC_UMMATIC_KHALIFAH.png',
      );
      image = pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (e) {
      debugPrint("Warning: Could not load PDF logo. $e");
    }

    // Stats
    int total = _allStudents.length;
    int barredCount = _allStudents.where((s) => _isBarred(s)).length;
    int warningCount = _allStudents.where((s) => _isWarning(s)).length;
    double avg =
        _allStudents.map((s) => s['w1_14'] as double).reduce((a, b) => a + b) /
        total;

    final warningStudents = _allStudents.where((s) => _isWarning(s)).toList();
    final barredStudents = _allStudents.where((s) => _isBarred(s)).toList();
    final String dateGenerated = DateFormat(
      'dd-MM-yyyy',
    ).format(DateTime.now());

    final textStyle = pw.TextStyle(font: font, fontSize: 12);
    final textStyleBold = pw.TextStyle(
      font: fontBold,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );

    pw.Widget _tableHeader(String text) {
      return pw.Container(
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(5),
        color: PdfColors.grey300,
        child: pw.Text(text, style: textStyleBold),
      );
    }

    pw.Widget _tableCell(String text, [bool isCenter = false]) {
      return pw.Container(
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(text, style: textStyle),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Center(
              child: pw.Column(
                children: [
                  if (image != null)
                    pw.Container(height: 60, child: pw.Image(image)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "KULLIYYAH OF INFORMATION AND COMMUNICATION TECHNOLOGY",
                    style: textStyleBold,
                  ),
                  pw.Text(
                    "DEPARTMENT OF COMPUTER SCIENCE",
                    style: textStyleBold,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text("SEMESTER 1, 25/26", style: textStyleBold),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "CSCI 4336 NETWORK SECURITY",
                    style: textStyleBold,
                  ), // UPDATED SUBJECT
                  pw.Text("SECTION 01", style: textStyleBold),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "ATTENDANCE SUMMARY REPORT",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 14,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text("DATE GENERATED: $dateGenerated", style: textStyle),
                ],
              ),
            ),
            pw.SizedBox(height: 25),

            // SUMMARY TABLE
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text("Attendance Summary", style: textStyleBold),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              children: [
                pw.TableRow(
                  children: [_tableHeader("Metric"), _tableHeader("Count")],
                ),
                pw.TableRow(
                  children: [
                    _tableCell("Total Students"),
                    _tableCell("$total", true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _tableCell("Class Average"),
                    _tableCell("${avg.toStringAsFixed(1)}%", true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _tableCell("At Risk (Warning)"),
                    _tableCell("$warningCount", true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _tableCell("Barred Candidates"),
                    _tableCell("$barredCount", true),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 25),

            // WARNING TABLE (SHOWS W1-7 ONLY)
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                "List of Warning Students (Week 1-7)",
                style: textStyleBold,
              ),
            ),
            pw.SizedBox(height: 5),
            if (warningStudents.isEmpty)
              pw.Text(
                "No students currently on warning list.",
                style: textStyle,
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      _tableHeader("Student Name"),
                      _tableHeader("Attendance % (W1-7)"),
                      _tableHeader("Status"),
                    ],
                  ),
                  ...warningStudents.map(
                    (s) => pw.TableRow(
                      children: [
                        _tableCell(s['name']),
                        _tableCell("${s['w1_7']}%", true),
                        _tableCell("WARNING", true),
                      ],
                    ),
                  ),
                ],
              ),
            pw.SizedBox(height: 25),

            // BARRED TABLE (SHOWS BOTH)
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                "List of Barred Students (Week 1-14)",
                style: textStyleBold,
              ),
            ),
            pw.SizedBox(height: 5),
            if (barredStudents.isEmpty)
              pw.Text("No barred students.", style: textStyle)
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      _tableHeader("Student Name"),
                      _tableHeader("Attendance % (W1-7)"),
                      _tableHeader("Attendance % (Overall)"),
                      _tableHeader("Status"),
                    ],
                  ),
                  ...barredStudents.map(
                    (s) => pw.TableRow(
                      children: [
                        _tableCell(s['name']),
                        _tableCell("${s['w1_7']}%", true),
                        _tableCell("${s['w1_14']}%", true),
                        _tableCell("BARRED", true),
                      ],
                    ),
                  ),
                ],
              ),
          ];
        },
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadPdfReport() async {
    try {
      final pdfBytes = await _makePdf();
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/NetSec_Section1_Full_Report.pdf");
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Attendance Report (NetSec Sect 1)');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _sendReportToAdmin() async {
    setState(() => _isSending = true);
    try {
      int total = _allStudents.length;
      int barredCount = _allStudents.where((s) => _isBarred(s)).length;
      int warningCount = _allStudents.where((s) => _isWarning(s)).length;
      double avg =
          _allStudents
              .map((s) => s['w1_14'] as double)
              .reduce((a, b) => a + b) /
          total;

      final barredList = _allStudents
          .where((s) => _isBarred(s))
          .map(
            (s) => {
              'name': s['name'],
              'attendance_w7': s['w1_7'],
              'attendance_w14': s['w1_14'],
              'status': 'BARRED',
            },
          )
          .toList();

      final warningList = _allStudents
          .where((s) => _isWarning(s))
          .map(
            (s) => {
              'name': s['name'],
              'attendance_w7': s['w1_7'],
              'status': 'WARNING',
            },
          )
          .toList();

      await FirebaseFirestore.instance.collection('admin_reports').add({
        'courseCode': 'CSCI 4336', // UPDATED COURSE CODE
        'courseName': 'Network Security',
        'section': '01',
        'semester': 'Semester 1, 25/26',
        'totalStudents': total,
        'averageAttendance': double.parse(avg.toStringAsFixed(1)),
        'barredCount': barredCount,
        'warningCount': warningCount,
        'barredStudents': barredList,
        'warningStudents': warningList,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Submitted',
        'reportFormat': 'Corrected PDF v4',
      });

      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'type': 'report_submission',
        'message': 'New Report: CSCI 4336 (Sect 1)',
        'details': '$barredCount Barred, $warningCount Warned.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Sent to Admin"),
          content: const Text(
            "The full attendance report data has been successfully sent to the Admin Portal.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // --- UI: SUMMARY SHEET ---
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
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
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

              Text(
                "Actions & Notifications",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending
                      ? null
                      : () => _releaseNotifications('Warning'),
                  icon: const Icon(Icons.notifications_active_rounded),
                  label: const Text("Release Warning Notifications"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending
                      ? null
                      : () => _releaseNotifications('Barred'),
                  icon: const Icon(Icons.block_rounded),
                  label: const Text("Release Barring Notifications"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Divider(height: 30),

              Text(
                "Exports",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _downloadPdfReport,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text("Download Full Report (PDF)"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A00E0),
                    side: const BorderSide(color: Color(0xFF4A00E0)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendReportToAdmin,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    _isSending ? "Sending..." : "Submit to Admin Portal",
                  ),
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
              const SizedBox(height: 20),
            ],
          ),
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
          "CSCI 4336 - Sect 1",
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
                  "Network Security (Section 1)",
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
                const SizedBox(height: 20),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateSummaryReport,
        backgroundColor: const Color(0xFF4A00E0),
        icon: const Icon(
          Icons.assignment_turned_in_rounded,
          color: Colors.white,
        ),
        label: Text(
          "Export / Actions",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

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

  Widget _buildStudentRow(Map<String, dynamic> student) {
    double midSem = student['w1_7'];
    double overall = student['w1_14'];

    Color statusColor = Colors.green;
    String statusText = "Good";
    IconData statusIcon = Icons.check_circle_outline;

    // --- CUSTOM FILTER LOGIC ---
    if (_selectedFilter == 'Warning') {
      statusColor = Colors.orange;
      statusText = "WARNING";
      statusIcon = Icons.warning_amber_rounded;
    } else if (_selectedFilter == 'Barred') {
      statusColor = Colors.red;
      statusText = "BARRED";
      statusIcon = Icons.block;
    } else {
      if (midSem < 80 && overall < 80) {
        statusColor = Colors.red;
        statusText = "Barred";
        statusIcon = Icons.block;
      } else if (midSem < 80) {
        statusColor = Colors.orange;
        statusText = "WARNING";
        statusIcon = Icons.warning_amber_rounded;
      }
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

        // --- COLUMNS DISPLAY LOGIC ---

        // 1. Column 1: W1-7 (Always Visible)
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

        // 2. Column 2: W1-14 (HIDDEN IN WARNING VIEW)
        if (_selectedFilter != 'Warning') ...[
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
        ],

        const SizedBox(width: 10),
        Icon(statusIcon, color: statusColor, size: 20),
      ],
    );
  }
}

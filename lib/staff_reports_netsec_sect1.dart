import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // --- MOCK DATA: 38 STUDENTS ---
  final List<Map<String, dynamic>> _allStudents = [
    {"name": "Alice Tan", "w1_7": 92.0, "w1_14": 90.0},
    {"name": "Bryan Lim", "w1_7": 85.0, "w1_14": 88.0},
    {"name": "Charles K.", "w1_7": 65.0, "w1_14": 60.0}, // Barred
    {"name": "Diana R.", "w1_7": 78.0, "w1_14": 82.0}, // Warning -> Recovered
    {"name": "Ethan Ho", "w1_7": 88.0, "w1_14": 89.0},
    {"name": "Fiona G.", "w1_7": 55.0, "w1_14": 50.0}, // Barred
    {"name": "George T.", "w1_7": 95.0, "w1_14": 94.0},
    {"name": "Hannah L.", "w1_7": 75.0, "w1_14": 80.0}, // Warning -> Recovered
    {"name": "Ian V.", "w1_7": 70.0, "w1_14": 68.0}, // Barred
    {"name": "Jessica M.", "w1_7": 98.0, "w1_14": 97.0},
    {"name": "Kevin S.", "w1_7": 85.0, "w1_14": 86.0},
    {"name": "Liam P.", "w1_7": 42.0, "w1_14": 40.0}, // Barred
    {"name": "Monica B.", "w1_7": 90.0, "w1_14": 92.0},
    {"name": "Nathan D.", "w1_7": 79.0, "w1_14": 81.0}, // Warning -> Recovered
    {"name": "Oliver Q.", "w1_7": 88.0, "w1_14": 87.0},
    {"name": "Patricia W.", "w1_7": 94.0, "w1_14": 93.0},
    {"name": "Quentin Z.", "w1_7": 60.0, "w1_14": 55.0}, // Barred
    {"name": "Rachel Y.", "w1_7": 91.0, "w1_14": 90.0},
    {"name": "Steven X.", "w1_7": 76.0, "w1_14": 82.0}, // Warning -> Recovered
    {"name": "Tiffany C.", "w1_7": 100.0, "w1_14": 99.0},
    {"name": "Umar F.", "w1_7": 82.0, "w1_14": 84.0},
    {"name": "Victor H.", "w1_7": 74.0, "w1_14": 70.0}, // Barred
    {"name": "Wendy J.", "w1_7": 89.0, "w1_14": 91.0},
    {"name": "Xavier K.", "w1_7": 68.0, "w1_14": 62.0}, // Barred
    {"name": "Yvonne N.", "w1_7": 93.0, "w1_14": 95.0},
    {"name": "Zack M.", "w1_7": 85.0, "w1_14": 86.0},
    {"name": "Adam O.", "w1_7": 77.0, "w1_14": 80.0}, // Warning -> Recovered
    {"name": "Bella P.", "w1_7": 96.0, "w1_14": 95.0},
    {"name": "Chris Q.", "w1_7": 50.0, "w1_14": 45.0}, // Barred
    {"name": "Daisy R.", "w1_7": 88.0, "w1_14": 89.0},
    {"name": "Edward S.", "w1_7": 92.0, "w1_14": 93.0},
    {"name": "Felicia T.", "w1_7": 75.0, "w1_14": 80.0}, // Warning -> Recovered
    {"name": "Greg U.", "w1_7": 84.0, "w1_14": 85.0},
    {"name": "Helen V.", "w1_7": 62.0, "w1_14": 58.0}, // Barred
    {"name": "Ivan W.", "w1_7": 95.0, "w1_14": 96.0},
    {"name": "Jenny X.", "w1_7": 81.0, "w1_14": 83.0},
    {"name": "Karl Y.", "w1_7": 72.0, "w1_14": 68.0}, // Barred
    {"name": "Lily Z.", "w1_7": 90.0, "w1_14": 91.0},
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
                  "Network Security (Section 1)",
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

          // ACTION BUTTON (Floating)
          if (_selectedFilter != 'All' && _filteredList.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 40,
              right: 40,
              child: _buildActionButton(),
            ),
        ],
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

  Widget _buildActionButton() {
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

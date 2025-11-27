import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({super.key});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  // Filter State
  String _selectedFilter = 'All Time';
  final List<String> _filterOptions = [
    'All Time',
    'This Week',
    'This Month',
    'This Year',
  ];

  // --- MOCK DATA: PAST ATTENDANCE RECORDS ---
  final List<Map<String, dynamic>> _allHistoryData = [
    {
      "date": DateTime.now().subtract(const Duration(hours: 2)), // Today
      "title": "CSCI 4300 - Computation",
      "status": "Present",
      "time": "10:00 AM",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 1)), // Yesterday
      "title": "CSCI 4332 - Digital Forensics",
      "status": "Present",
      "time": "11:30 AM",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "title": "CSCI 4333 - Cryptography",
      "status": "Late",
      "time": "02:00 PM",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "title": "CSCI 4300 - Computation",
      "status": "Excused",
      "time": "10:00 AM",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 10)),
      "title": "CSCI 4332 - Digital Forensics",
      "status": "Absent",
      "time": "11:30 AM",
    },
    {
      "date": DateTime.now().subtract(const Duration(days: 25)),
      "title": "CSCI 4333 - Cryptography",
      "status": "Present",
      "time": "09:00 AM",
    },
  ];

  // --- FILTER LOGIC ---
  List<Map<String, dynamic>> get _filteredData {
    DateTime now = DateTime.now();

    return _allHistoryData.where((record) {
      DateTime date = record['date'];

      if (_selectedFilter == 'This Week') {
        // Last 7 days
        return date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_selectedFilter == 'This Month') {
        // Same month and year
        return date.month == now.month && date.year == now.year;
      } else if (_selectedFilter == 'This Year') {
        // Same year
        return date.year == now.year;
      }
      return true; // 'All Time'
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Filtered Data
    List<Map<String, dynamic>> displayData = _filteredData;

    // 2. Calculate Stats based on FILTERED data
    int total = displayData.length;
    int present = displayData.where((e) => e['status'] == 'Present').length;
    int absent = displayData.where((e) => e['status'] == 'Absent').length;
    int late = displayData.where((e) => e['status'] == 'Late').length;
    int excused = displayData.where((e) => e['status'] == 'Excused').length;

    // Simple Percentage Calculation (Present + Late counts as attending)
    double attendanceRate = total == 0 ? 0 : ((present + late) / total) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          // --- HEADER SECTION ---
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Attendance History",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Showing: $_selectedFilter",
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // DYNAMIC STATS ROW (SCROLLABLE)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard(
                        "Rate",
                        "${attendanceRate.toStringAsFixed(0)}%",
                        Icons.pie_chart,
                        Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        "Present",
                        "$present",
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        "Late",
                        "$late",
                        Icons.access_time,
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        "Excused",
                        "$excused",
                        Icons.info_outline,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        "Absent",
                        "$absent",
                        Icons.cancel,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- FILTER CHIPS ---
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              // ignore: unnecessary_underscores
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                String filter = _filterOptions[index];
                bool isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: GoogleFonts.lato(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- HISTORY LIST ---
          Expanded(
            child: displayData.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    // Padding Bottom 120 ensures the floating nav bar never hides the last item
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    itemCount: displayData.length,
                    itemBuilder: (context, index) {
                      final record = displayData[index];
                      return _buildHistoryTile(record);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            "No records found for this period",
            style: GoogleFonts.poppins(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color == Colors.white ? Colors.white : Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> record) {
    String status = record['status'];
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'Absent':
        statusColor = Colors.red;
        statusIcon = Icons.highlight_off;
        break;
      case 'Excused':
        statusColor = Colors.blue;
        statusIcon = Icons.info_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    String dateStr = DateFormat('MMM d, y').format(record['date']);
    String dayStr = DateFormat('EEE').format(record['date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  dayStr,
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('d').format(record['date']),
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      record['time'],
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

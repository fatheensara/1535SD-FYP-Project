import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT THE MONITOR PAGE so we can navigate to it
import 'staff_attendance_monitor_page.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  // --- MOCK DATA ---
  int _selectedDateIndex = 0;
  final List<String> _dates = ["27", "28", "29", "30", "01"];
  final List<String> _days = ["Wed", "Thu", "Fri", "Sat", "Sun"];

  final List<Map<String, dynamic>> _classes = [
    {
      "time": "08:00 AM",
      "endTime": "10:00 AM",
      "course": "Data Structures",
      "code": "CSC 2101",
      "venue": "Lab 3, Block B",
      "status": "Finished",
    },
    {
      "time": "10:00 AM",
      "endTime": "12:00 PM",
      "course": "Operating Systems",
      "code": "CSC 3302",
      "venue": "Lecture Hall 1",
      "status": "Live", // 'Live' status makes it green
    },
    {
      "time": "02:00 PM",
      "endTime": "04:00 PM",
      "course": "Software Engineering",
      "code": "CSC 3401",
      "venue": "Lab 1, Block A",
      "status": "Upcoming",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      // We do not use a standard AppBar because this is a main tab
      // Instead, we use a custom Container for the header
      body: Column(
        children: [
          // --- 1. HEADER SECTION ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.purple.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile and Welcome Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back,",
                          style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Dr. Aishah",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Profile Picture Placeholder
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Horizontal Date Selector
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    itemBuilder: (context, index) {
                      bool isSelected = index == _selectedDateIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDateIndex = index;
                          });
                        },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: isSelected
                                ? Colors.white
                                // ignore: deprecated_member_use
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dates[index],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                _days[index],
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- 2. TIMELINE / CLASS LIST ---
          Expanded(
            child: ListView.builder(
              // UPDATED PADDING: Bottom 100 to clear the StaffHomePage Navigation Bar
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                return _buildClassCard(_classes[index]);
              },
            ),
          ),
        ],
      ),

      // REMOVED FAB: StaffHomePage already has the main Floating Action Button
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classInfo) {
    String status = classInfo['status'];
    bool isLive = status == 'Live';
    bool isFinished = status == 'Finished';

    // Status Colors
    Color statusColor = isLive
        ? Colors.green
        : (isFinished ? Colors.grey : Colors.orange);

    return GestureDetector(
      onTap: () {
        // --- NAVIGATION TO MONITOR PAGE ---
        // We only navigate if the class is not finished
        if (!isFinished) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StaffAttendanceMonitorPage(className: classInfo['course']),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This class has ended.")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            Column(
              children: [
                Text(
                  classInfo['time'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  height: 60,
                  width: 2,
                  color: Colors.grey.shade300,
                ),
                Text(
                  classInfo['endTime'],
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 15),

            // Card Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
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
                  // Colored left border based on status
                  border: Border(
                    left: BorderSide(color: statusColor, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const Icon(Icons.more_horiz, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      classInfo['course'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isFinished ? Colors.grey : Colors.black87,
                      ),
                    ),
                    Text(
                      classInfo['code'],
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.purple.shade300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          classInfo['venue'],
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

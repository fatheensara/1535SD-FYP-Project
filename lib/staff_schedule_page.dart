import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'staff_attendance_monitor_page.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
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
      "status": "Live",
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
    // We assume the parent Scaffold in StaffHome provides the dark background,
    // but just in case this is used standalone, we wrap content in transparent container
    return Container(
      color: Colors.transparent, // Background handled by StaffHome stack
      child: Column(
        children: [
          // HEADER (Custom Date Picker)
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  Colors.deepPurple.shade900.withOpacity(0.8),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Schedule",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    itemBuilder: (context, index) {
                      bool isSelected = index == _selectedDateIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDateIndex = index),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: isSelected
                                ? Colors.purpleAccent
                                // ignore: deprecated_member_use
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white12,
                            ),
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
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                _days[index],
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.black87
                                      : Colors.white54,
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

          // TIMELINE
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: _classes.length,
              itemBuilder: (context, index) {
                return _buildTimelineItem(_classes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> data) {
    String status = data['status'];
    bool isLive = status == 'Live';
    Color statusColor = isLive
        ? Colors.greenAccent
        : (status == 'Finished' ? Colors.grey : Colors.amberAccent);

    return GestureDetector(
      onTap: () {
        if (status != 'Finished') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StaffAttendanceMonitorPage(className: data['course']),
            ),
          );
        }
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data['time'],
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['endTime'],
                    style: GoogleFonts.lato(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Line
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                    boxShadow: [
                      if (isLive) BoxShadow(color: statusColor, blurRadius: 8),
                    ],
                  ),
                ),
                Expanded(child: Container(width: 2, color: Colors.white10)),
              ],
            ),
            const SizedBox(width: 15),

            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    // ignore: deprecated_member_use
                    border: isLive
                        // ignore: deprecated_member_use
                        ? Border.all(color: statusColor.withOpacity(0.5))
                        : Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white30,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['course'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        data['code'],
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data['venue'],
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

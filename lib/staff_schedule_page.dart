import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  // 1. STATE FOR SELECTED DAY
  String _selectedDay = "MON";
  final List<String> _days = ["MON", "TUE", "WED", "THU", "FRI"];

  // 2. MOCK DATA
  final Map<String, List<Map<String, dynamic>>> _scheduleData = {
    "MON": [
      {
        "startTime": "08:30 AM",
        "endTime": "10:00 AM",
        "title": "CSCI 2303 - Principles of IT Security",
        "subtitle": "Section 1",
        "type": "Class",
        "location": "Lab 1",
      },
      {
        "startTime": "10:00 AM",
        "endTime": "11:30 AM",
        "title": "CSCI 2303 - Principles of IT Security",
        "subtitle": "Section 2",
        "type": "Class",
        "location": "Lab 1",
      },
      {
        "startTime": "11:30 AM",
        "endTime": "01:00 PM",
        "title": "CSCI 4332 - Digital Evidence Forensics",
        "subtitle": "Section 2",
        "type": "Class",
        "location": "Lecture Hall 2",
      },
      {
        "startTime": "02:00 PM",
        "endTime": "05:00 PM",
        "title": "Student Consultation",
        //"subtitle": "Email me for an appointment",
        "type": "Consultation",
        "location": "Office / Online",
        "isEmailAction": true,
      },
    ],
    "TUE": [
      {
        "startTime": "10:00 AM",
        "endTime": "11:30 AM",
        "title": "FYP Students' Meeting",
        "type": "Meeting",
        "location": "Meeting Room 1",
      },
      {
        "startTime": "02:00 PM",
        "endTime": "03:30 PM",
        "title": "CSCI 4336 - Network Security",
        "subtitle": "Section 1",
        "type": "Class",
        "location": "Lab 3",
      },
      {
        "startTime": "03:30 PM",
        "endTime": "05:00 PM",
        "title": "Research Meeting",
        "type": "Meeting",
        "location": "Conference Room",
      },
    ],
    "WED": [
      {
        "startTime": "08:30 AM",
        "endTime": "10:00 AM",
        "title": "CSCI 2303 - Principles of IT Security",
        "subtitle": "Section 1",
        "type": "Class",
        "location": "Lab 1",
      },
      {
        "startTime": "10:00 AM",
        "endTime": "11:30 AM",
        "title": "CSCI 2303 - Principles of IT Security",
        "subtitle": "Section 2",
        "type": "Class",
        "location": "Lab 1",
      },
      {
        "startTime": "11:30 AM",
        "endTime": "01:00 PM",
        "title": "CSCI 4332 - Digital Evidence Forensics",
        "subtitle": "Section 2",
        "type": "Class",
        "location": "Lecture Hall 2",
      },
      {
        "startTime": "02:00 PM",
        "endTime": "05:00 PM",
        "title": "Student Consultation",
        //"subtitle": "Email me for an appointment",
        "type": "Consultation",
        "location": "Office",
        "isEmailAction": true,
      },
    ],
    "THU": [
      {
        "startTime": "10:00 AM",
        "endTime": "11:30 AM",
        "title": "PG Students' Meeting",
        "type": "Meeting",
        "location": "Seminar Room",
      },
      {
        "startTime": "02:00 PM",
        "endTime": "03:30 PM",
        "title": "CSCI 4336 - Network Security",
        "subtitle": "Section 1",
        "type": "Class",
        "location": "Lab 3",
      },
      {
        "startTime": "03:30 PM",
        "endTime": "05:00 PM",
        "title": "Research Meeting",
        "type": "Meeting",
        "location": "Conference Room",
      },
    ],
    "FRI": [
      {
        "startTime": "10:00 AM",
        "endTime": "11:30 AM",
        "title": "Faculty Meeting",
        "type": "Meeting",
        "location": "Main Auditorium",
      },
      {
        "startTime": "02:00 PM",
        "endTime": "05:00 PM",
        "title": "Student Consultation",
        //"subtitle": "Email me for an appointment",
        "type": "Consultation",
        "location": "Office",
        "isEmailAction": true,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dailyEvents = _scheduleData[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA), // Clean Light Background
      body: Column(
        children: [
          // --- 1. HEADER & DAY SELECTOR ---
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A0038), // Deep Midnight Purple
                  Color(0xFF4A00E0), // Royal Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF4A00E0).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Weekly Schedule",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Horizontal Day Selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: _days.map((day) {
                      bool isSelected = _selectedDay == day;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                // ignore: deprecated_member_use
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            day,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF4A00E0)
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. TIMELINE LIST ---
          Expanded(
            child: dailyEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: dailyEvents.length,
                    itemBuilder: (context, index) {
                      return _buildTimelineCard(dailyEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildTimelineCard(Map<String, dynamic> event) {
    // Determine Color Theme based on Type
    Color accentColor;
    Color bgColor;
    // ignore: unused_local_variable
    IconData icon;

    switch (event['type']) {
      case 'Class':
        accentColor = const Color(0xFF4A00E0); // Royal Purple
        bgColor = Colors.white;
        icon = Icons.class_outlined;
        break;
      case 'Meeting':
        accentColor = Colors.orange.shade800; // Orange
        bgColor = Colors.orange.shade50;
        icon = Icons.groups_outlined;
        break;
      case 'Consultation':
        accentColor = const Color(0xFFFF5C8D); // Pink
        bgColor = const Color(0xFFFFF0F5); // Light Pink
        icon = Icons.chat_bubble_outline;
        break;
      default:
        accentColor = Colors.grey;
        bgColor = Colors.white;
        icon = Icons.event;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TIME COLUMN
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event['startTime'],
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  event['endTime'],
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 2. TIMELINE LINE
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 3),
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.grey.shade200)),
            ],
          ),

          const SizedBox(width: 12),

          // 3. EVENT CARD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  // Left accent border
                  border: Border(
                    left: BorderSide(color: accentColor, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event['title'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (event['isEmailAction'] == true)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.email,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),

                    // Subtitle (if any)
                    if (event['subtitle'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        event['subtitle'],
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: accentColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Footer Info
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event['location'],
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event['type'].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.weekend, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            "No Schedule",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            "Enjoy your day off!",
            style: GoogleFonts.lato(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffSchedulePage extends StatefulWidget {
  const StaffSchedulePage({super.key});

  @override
  State<StaffSchedulePage> createState() => _StaffSchedulePageState();
}

class _StaffSchedulePageState extends State<StaffSchedulePage> {
  // 1. STATE FOR SELECTED DATE
  DateTime _selectedDate = DateTime.now();

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
        "type": "Consultation",
        "location": "Office",
        "isEmailAction": true,
      },
    ],
  };

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _returnToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    // Map current date to generic weekday key (e.g., "MON")
    String dayKey = DateFormat('E').format(_selectedDate).toUpperCase();
    List<Map<String, dynamic>> dailyEvents = _scheduleData[dayKey] ?? [];
    bool isToday = _isToday(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          // --- 1. HEADER & DATE NAVIGATOR ---
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 40,
              left: 20,
              right: 20,
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title Only (Logout Removed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back,",
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "My Schedule",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Date Navigator Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeDate(-1),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          DateFormat('EEEE').format(_selectedDate),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM d, y').format(_selectedDate),
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. CONDITIONAL "RETURN TO TODAY" BUTTON ---
          if (!isToday) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _returnToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Color(0xFF4A00E0),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Return to Today",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A00E0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // --- 3. TIMELINE LIST ---
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.weekend_rounded, // Sofa icon substitute
              size: 50,
              color: Colors.purple.shade200,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Classes",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Enjoy your rest day!",
            style: GoogleFonts.lato(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> event) {
    Color accentColor;
    Color bgColor;

    switch (event['type']) {
      case 'Class':
        accentColor = const Color(0xFF4A00E0);
        bgColor = Colors.white;
        break;
      case 'Meeting':
        accentColor = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        break;
      case 'Consultation':
        accentColor = const Color(0xFFFF5C8D);
        bgColor = const Color(0xFFFFF0F5);
        break;
      default:
        accentColor = Colors.grey;
        bgColor = Colors.white;
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
                  border: Border(
                    left: BorderSide(color: accentColor, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
}

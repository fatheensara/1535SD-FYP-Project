import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- SCREEN IMPORTS ---
import 'welcome.dart';
import 'fade_page_route.dart';
import 'student_mark_attendance_page.dart';
import 'student_class_details_page.dart';
import 'student_history_page.dart';
import 'student_alerts_page.dart';
import 'student_profile_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  DateTime _selectedDate = DateTime.now();
  int _currentIndex = 0; // 0=Home, 1=History, 2=Alerts, 3=Profile

  // --- 1. DATA LOGIC ---
  List<Map<String, String>> _getClassesForDate(DateTime date) {
    int day = date.weekday;

    // Monday (1) & Wednesday (3)
    if (day == DateTime.monday || day == DateTime.wednesday) {
      return [
        {
          "title": "CSCI 4300 - Computation",
          "fullTitle": "CSCI 4300 - Computation and Complexity",
          "time": "10:00 AM - 11:20 AM",
          "lecturer": "Dr. Nurul Liyana",
          "status": "Pending",
          "type": "Lecture",
        },
        {
          "title": "CSCI 4332 - Digital Forensics",
          "fullTitle": "CSCI 4332 - Digital Evidence Forensics",
          "time": "11:30 AM - 12:50 PM",
          "lecturer": "Dr. Andi Fitriah",
          "status": "Pending",
          "type": "Lab",
        },
      ];
    }
    // Tuesday (2) & Thursday (4)
    else if (day == DateTime.tuesday || day == DateTime.thursday) {
      return [
        {
          "title": "CSCI 4333 - Cryptography",
          "fullTitle": "CSCI 4333 - Cryptography",
          "time": "11:30 AM - 12:50 PM",
          "lecturer": "Dr. Takumi Sase",
          "status": "Present",
          "type": "Lecture",
        },
      ];
    }
    // Weekends & Friday
    else {
      return [];
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  // --- 2. SMART QUICK SCAN LOGIC ---
  void _handleQuickScan() {
    // A. Check REAL TIME (Today)
    DateTime now = DateTime.now();
    List<Map<String, String>> todaysClasses = _getClassesForDate(now);

    // B. Find the first class that is still 'Pending'
    Map<String, String> pendingClass = {};
    try {
      pendingClass = todaysClasses.firstWhere(
        (cls) => cls['status'] == 'Pending',
      );
    } catch (e) {
      pendingClass = {};
    }

    // C. Navigate or Show Message
    if (pendingClass.isNotEmpty) {
      Navigator.push(
        context,
        FadePageRoute(
          page: MarkAttendancePage(className: pendingClass['title']!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text("All caught up! No pending classes for today."),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // --- 3. UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      extendBody: true,

      body: Stack(
        children: [
          // MAIN CONTENT SWITCHER
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildScheduleView(), // Index 0: Home Dashboard
              const StudentHistoryPage(), // Index 1: History
              const StudentAlertsPage(), // Index 2: Alerts
              const StudentProfilePage(), // Index 3: Profile
            ],
          ),

          // FLOATING NAV BAR (Bottom)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),

      // CENTER FLOATING BUTTON (Quick Scan)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanFloatingButton(),
    );
  }

  // --- COMPONENT: SCHEDULE VIEW (Index 0) ---
  Widget _buildScheduleView() {
    List<Map<String, String>> dailyClasses = _getClassesForDate(_selectedDate);
    bool isToday = CalendarUtils.isSameDay(_selectedDate, DateTime.now());
    String fullDate = DateFormat('MMMM d, y').format(_selectedDate);
    String dayName = DateFormat('EEEE').format(_selectedDate);

    // Padding bottom 100 to prevent content hiding behind nav bar
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // HEADER
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
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
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
              children: [
                // Welcome Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            FadePageRoute(page: const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Date Navigator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeDate(-1),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          dayName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          fullDate,
                          style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Return to Today Button
          if (!isToday)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = DateTime.now()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.replay,
                        size: 16,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Return to Today",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Class List
          if (dailyClasses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: _buildEmptyState(),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailyClasses.length,
              itemBuilder: (context, index) =>
                  _buildInterestingCard(dailyClasses[index]),
            ),
        ],
      ),
    );
  }

  // --- COMPONENT: FLOATING NAV BAR ---
  Widget _buildFloatingNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.grid_view_rounded, index: 0, label: "Home"),
          _buildNavItem(
            icon: Icons.history_edu_rounded,
            index: 1,
            label: "History",
          ),

          const SizedBox(width: 50), // Gap for the center button

          _buildNavItem(
            icon: Icons.notifications_none_rounded,
            index: 2,
            label: "Alerts",
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            index: 3,
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.purple.shade700 : Colors.grey.shade400,
              size: 26,
            ),
          ),
          if (isSelected)
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // --- COMPONENT: QUICK SCAN BUTTON ---
  Widget _buildScanFloatingButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 45), // Push up to align with Dock
      height: 70,
      width: 70,
      child: FloatingActionButton(
        onPressed: _handleQuickScan, // Triggers smart scan
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- HELPERS: CARDS & PLACEHOLDERS ---

  Widget _buildInterestingCard(Map<String, String> cls) {
    bool isPending = cls['status'] == "Pending";
    Color statusColor = isPending ? Colors.orange : Colors.green;
    IconData typeIcon = cls['type'] == 'Lecture'
        ? Icons.menu_book
        : Icons.computer;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.purple.shade100.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Faded Icon
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                typeIcon,
                // ignore: deprecated_member_use
                size: 100,
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.05),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Time & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 14,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              cls['time']!,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cls['status']!.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Class Info
                  Text(
                    cls['fullTitle']!,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    cls['lecturer']!,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  InkWell(
                    onTap: () {
                      if (isPending) {
                        Navigator.push(
                          context,
                          FadePageRoute(
                            page: MarkAttendancePage(className: cls['title']!),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          FadePageRoute(
                            page: ClassDetailsPage(classTitle: cls['title']!),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isPending
                            ? const LinearGradient(
                                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.green.shade600,
                                  Colors.green.shade400,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isPending ? "Scan Attendance" : "View History",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.weekend_rounded, size: 60, color: Colors.purple.shade200),
          const SizedBox(height: 10),
          Text(
            "No Classes",
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class CalendarUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

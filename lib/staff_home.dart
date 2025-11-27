import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- IMPORTS ---
import 'welcome.dart';
import 'fade_page_route.dart';
import 'staff_attendance_monitor_page.dart';
import 'staff_schedule_page.dart'; // <--- IMPORT THE NEW PAGE HERE

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _currentIndex = 0; // 0=Home, 1=Schedule, 2=Reports, 3=Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      extendBody: true, // Allows content to flow behind the floating nav bar
      body: Stack(
        children: [
          // MAIN CONTENT SWITCHER
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboardView(), // Index 0: Dashboard
              const StaffSchedulePage(), // Index 1: ACTUAL SCHEDULE PAGE
              _buildPlaceholder("Reports"), // Index 2: Placeholder
              _buildPlaceholder("Profile"), // Index 3: Placeholder
            ],
          ),

          // FLOATING NAV BAR
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCenterFab(),
    );
  }

  // --- VIEW 0: LECTURER DASHBOARD ---
  Widget _buildDashboardView() {
    String dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER SECTION
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.purple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning,",
                          style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Dr. Takumi",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  dateStr,
                  style: GoogleFonts.lato(
                    color: Colors.blue.shade100,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "You have 3 classes today",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 2. HAPPENING NOW CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Happening Now",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildActiveSessionCard(),

          const SizedBox(height: 30),

          // 3. UPCOMING SCHEDULE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Today's Schedule",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 15),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildClassTile(
                "10:00 AM",
                "11:20 AM",
                "CSCI 4333 - Cryptography",
                "Lecture Hall 1",
                "Live Now",
              ),
              _buildClassTile(
                "02:00 PM",
                "03:30 PM",
                "CSCI 4300 - Computation",
                "Lab 3",
                "Upcoming",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildActiveSessionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.purple.shade900.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Part (Info)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "NOW",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CSCI 4333 - Cryptography",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Lecture Hall 1",
                            style: GoogleFonts.lato(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(Icons.people, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Live Session",
                            style: GoogleFonts.lato(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ACTION BUTTON: NAVIGATES TO MONITOR PAGE
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                FadePageRoute(
                  page: const StaffAttendanceMonitorPage(
                    className: "CSCI 4333 - Cryptography",
                  ),
                ),
              );
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.purple.shade50.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_tethering, color: Colors.purple),
                  const SizedBox(width: 10),
                  Text(
                    "Activate Attendance Mode",
                    style: GoogleFonts.poppins(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTile(
    String start,
    String end,
    String title,
    String loc,
    String status,
  ) {
    bool isLive = status == "Live Now";
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                start,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                end,
                style: GoogleFonts.lato(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 15),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc,
                  style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLive ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isLive ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "$title Page",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRoute(page: const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text("Temporary Logout"),
          ),
        ],
      ),
    );
  }

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
          _buildNavItem(Icons.dashboard_rounded, 0, "Home"),
          _buildNavItem(Icons.calendar_month_rounded, 1, "Schedule"),
          const SizedBox(width: 50), // Gap for FAB
          _buildNavItem(Icons.analytics_rounded, 2, "Reports"),
          _buildNavItem(Icons.person_rounded, 3, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.purple.shade900 : Colors.grey.shade400,
            size: 26,
          ),
          if (isSelected)
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.purple.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterFab() {
    return Container(
      margin: const EdgeInsets.only(bottom: 45),
      height: 65,
      width: 65,
      child: FloatingActionButton(
        onPressed: () {
          // Action: Quick Create Class
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.purple.shade800, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

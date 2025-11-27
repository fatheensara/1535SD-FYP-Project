import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- IMPORTS ---
import 'welcome.dart'; // Required for Logout
import 'fade_page_route.dart';
import 'staff_attendance_monitor_page.dart';
import 'staff_schedule_page.dart';
import 'staff_reports_page.dart';
import 'staff_profile_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. GLOBAL DARK BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0C29), // Onyx
                  Color(0xFF302B63), // Deep Purple
                  Color(0xFF24243E), // Dark Slate
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. MAIN CONTENT SWITCHER
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildDashboardView(),
              const StaffSchedulePage(),
              const StaffReportsPage(),
              const StaffProfilePage(),
            ],
          ),

          // 3. FLOATING NAV BAR
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCenterFab(),
    );
  }

  // --- DASHBOARD VIEW (Index 0) ---
  Widget _buildDashboardView() {
    String dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
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

                  // *** LOGOUT BUTTON (Updated) ***
                  Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Navigate back to Welcome Screen
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
            ),

            // DATE & STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                dateStr,
                style: GoogleFonts.lato(
                  color: Colors.cyanAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // QUICK STATS ROW
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard(
                    "Total Classes",
                    "3",
                    Icons.class_outlined,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Avg Attendance",
                    "92%",
                    Icons.pie_chart_outline,
                    Colors.purple,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Pending Reports",
                    "1",
                    Icons.assignment_outlined,
                    Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // HAPPENING NOW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Happening Now",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildActiveSessionCard(),

            const SizedBox(height: 30),

            // UPCOMING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Up Next",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildClassTile(
              "02:00 PM",
              "03:30 PM",
              "CSCI 4300 - Computation",
              "Lab 3",
              "Upcoming",
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            // ignore: deprecated_member_use
            Colors.deepPurple.shade900.withOpacity(0.8),
            // ignore: deprecated_member_use
            Colors.purple.shade900.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.purpleAccent.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Live Indicator
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: Colors.greenAccent.withOpacity(0.5),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.sensors, color: Colors.greenAccent),
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
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Lecture Hall 1",
                                style: GoogleFonts.lato(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "LIVE",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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

              // Action Button
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
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.1),
                    // ignore: deprecated_member_use
                    border: Border(
                      // ignore: deprecated_member_use
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enter Attendance Mode",
                        style: GoogleFonts.poppins(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                start,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                end,
                style: GoogleFonts.lato(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.white24,
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc,
                  style: GoogleFonts.lato(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Text(
              "NEXT",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 0, "Home"),
              _buildNavItem(Icons.calendar_month_rounded, 1, "Schedule"),
              const SizedBox(width: 50),
              _buildNavItem(Icons.analytics_rounded, 2, "Reports"),
              _buildNavItem(Icons.person_rounded, 3, "Profile"),
            ],
          ),
        ),
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
            color: isSelected ? Colors.purpleAccent : Colors.grey,
            size: 24,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                ),
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
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE100FF), Color(0xFF8E2DE2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: const Color(0xFFE100FF).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'welcome.dart';
import 'fade_page_route.dart';
import 'admin_staff_management_page.dart';
import 'admin_approvals_page.dart';
import 'admin_settings_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. GLOBAL ADMIN BACKGROUND (Deep Teal & Night Blue)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF021B26), // Deep Night Teal
                  Color(0xFF0F303F), // Dark Slate
                  Color(0xFF164857), // Muted Cyan
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
              _buildDashboardView(), // Index 0: Overview
              const AdminStaffManagementPage(), // Index 1: Manage Lecturers
              const AdminApprovalsPage(), // Index 2: Pending Requests
              const AdminSettingsPage(), // Index 3: System Config
            ],
          ),

          // 3. FLOATING GLASS NAV BAR
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildGlassNavBar(),
          ),
        ],
      ),
    );
  }

  // --- DASHBOARD VIEW (Index 0) ---
  Widget _buildDashboardView() {
    // ignore: unused_local_variable
    String dateStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER & LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin Console",
                        style: GoogleFonts.lato(
                          color: Colors.tealAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "Overview",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.redAccent,
                      ),
                      tooltip: "Logout",
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
            ),

            // PERFORMANCE MONITOR CARD (The "Pantau" Visual)
            _buildPerformanceCard(),

            const SizedBox(height: 25),

            // QUICK STATS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildStatCard(
                    "Active Lecturers",
                    "42",
                    Icons.badge_outlined,
                    Colors.purpleAccent,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Students Tracked",
                    "1,205",
                    Icons.groups_outlined,
                    Colors.blueAccent,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "Avg Attendance",
                    "94%",
                    Icons.show_chart,
                    Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ACTION REQUIRED SECTION (Approvals)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Needs Approval",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "3 NEW",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildApprovalTile(
              "Dr. Takumi",
              "MC Submission (Student)",
              "2m ago",
              Icons.medical_services_outlined,
            ),
            _buildApprovalTile(
              "Dr. Aishah",
              "Class Cancellation",
              "1h ago",
              Icons.event_busy_outlined,
            ),
            _buildApprovalTile(
              "System",
              "New Staff Registration",
              "3h ago",
              Icons.person_add_alt_1_outlined,
            ),

            const SizedBox(height: 30),

            // MANAGEMENT GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Management",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.4,
              children: [
                _buildActionCard(
                  Icons.supervisor_account,
                  "Manage Staff",
                  Colors.purple,
                ),
                _buildActionCard(Icons.school, "Manage Students", Colors.blue),
                _buildActionCard(Icons.analytics, "Full Reports", Colors.teal),
                _buildActionCard(Icons.settings, "Config", Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildPerformanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            // ignore: deprecated_member_use
            Colors.teal.withOpacity(0.2),
            // ignore: deprecated_member_use
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 0.94,
                  color: Colors.tealAccent,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                ),
                Text(
                  "94%",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overall Performance",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Attendance rate is stable. 3 classes currently active.",
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              fontSize: 20,
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

  Widget _buildApprovalTile(
    String title,
    String subtitle,
    String time,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.orangeAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.orangeAccent, size: 20),
          ),
          const SizedBox(width: 15),
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
                Text(
                  subtitle,
                  style: GoogleFonts.lato(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white30,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.tealAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "REVIEW",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
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
              _buildNavItem(Icons.dashboard_rounded, 0, "Overview"),
              _buildNavItem(Icons.people_outline, 1, "Staff"),
              _buildNavItem(Icons.task_alt_rounded, 2, "Approvals"),
              _buildNavItem(Icons.settings_outlined, 3, "Settings"),
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
            color: isSelected ? Colors.tealAccent : Colors.grey,
            size: 24,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        "$title Page",
        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 20),
      ),
    );
  }
}

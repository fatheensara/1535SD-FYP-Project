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
      backgroundColor: const Color(0xFFF6F8FA),
      resizeToAvoidBottomInset: false, // Prevents resizing when keyboard opens
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A0038), // Deep Midnight Purple
                  Color(0xFF4A00E0), // Royal Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildLecturerDashboard(),
              const StaffSchedulePage(),
              const StaffReportsPage(),
              const StaffProfilePage(),
            ],
          ),

          // 3. FLOATING NAV BAR (Positioned at bottom)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildWhiteNavBar(),
          ),

          // 4. FLOATING ACTION BUTTON (Manual Position to prevent moving)
          // Placing it here in the Stack ensures SnackBars don't push it up.
          Positioned(
            bottom: 45, // Aligns perfectly with the Nav Bar curve
            left: 0,
            right: 0,
            child: Center(child: _buildCenterFab()),
          ),
        ],
      ),
    );
  }

  // --- LECTURER DASHBOARD VIEW ---
  Widget _buildLecturerDashboard() {
    String dateStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CONTENT
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                            "Welcome Back,",
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Dr. Andi Fitriah",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 26,
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
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
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
                  const SizedBox(height: 10),
                  Text(
                    dateStr.toUpperCase(),
                    style: GoogleFonts.lato(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // OVERLAPPING CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION TITLE
                Text(
                  "Action Required",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),

                // ACTION CARD
                _buildActionRequiredCard(),

                const SizedBox(height: 30),

                // QUICK ACCESS GRID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(
                      Icons.qr_code_scanner,
                      "Attendance",
                      Colors.indigo,
                      () => Navigator.push(
                        context,
                        FadePageRoute(
                          page: const StaffAttendanceMonitorPage(
                            className: "CSCI 4333 - Cryptography",
                          ),
                        ),
                      ),
                    ),
                    _buildQuickAction(
                      Icons.people_alt_outlined,
                      "Consultation",
                      Colors.orange,
                      () => _showSnackBar("Opening Consultation Schedule..."),
                    ),
                    _buildQuickAction(
                      Icons.assessment_outlined,
                      "Results",
                      Colors.teal,
                      () => _showSnackBar("Opening Exam Results..."),
                    ),
                    _buildQuickAction(
                      Icons.campaign_outlined,
                      "Broadcast",
                      Colors.pink,
                      () => _showSnackBar("Create New Announcement..."),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // IMPORTANT NOTICES LIST
                Text(
                  "Important Notices",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                _buildNoticeTile(
                  "Grade Submission Deadline",
                  "Final grades for Sem 1 must be submitted by 15 Jan.",
                  Colors.redAccent,
                ),
                _buildNoticeTile(
                  "System Maintenance",
                  "LMS will be down this Saturday from 12AM - 4AM.",
                  Colors.amber,
                ),
                _buildNoticeTile(
                  "Department Meeting",
                  "Monthly meeting scheduled for next Monday at 10 AM.",
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Clear previous
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating, // Floats above content
        margin: const EdgeInsets.only(
          bottom: 20,
          left: 20,
          right: 20,
        ), // Custom positioning
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- NEW: PLUS BUTTON MENU ---
  void _showQuickCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Quick Create",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuOption(
                icon: Icons.add_alarm_rounded,
                color: Colors.blue,
                title: "Start Instant Class",
                subtitle: "Create an ad-hoc session immediately",
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar("Starting Instant Session...");
                },
              ),
              _buildMenuOption(
                icon: Icons.campaign_rounded,
                color: Colors.orange,
                title: "Post Announcement",
                subtitle: "Notify students in your active classes",
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar("Creating Announcement...");
                },
              ),
              _buildMenuOption(
                icon: Icons.qr_code_2_rounded,
                color: Colors.purple,
                title: "Scan Student ID",
                subtitle: "Verify a student manually via QR",
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar("Opening Scanner...");
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRequiredCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "3 Pending Approvals",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Students from CSCI 4332 requesting MC approval.",
                        style: GoogleFonts.lato(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              _showSnackBar("Opening Approval Dashboard...");
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Review Requests",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A00E0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF4A00E0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeTile(String title, String subtitle, Color stripColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: stripColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
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
          const SizedBox(width: 50),
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
            color: isSelected ? const Color(0xFF4A00E0) : Colors.grey.shade400,
            size: 24,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF4A00E0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- UPDATED FAB WITH ACTION ---
  Widget _buildCenterFab() {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF2E006A), Color(0xFF4A00E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF4A00E0).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _showQuickCreateMenu, // Calls the menu now
          child: const Center(
            child: Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

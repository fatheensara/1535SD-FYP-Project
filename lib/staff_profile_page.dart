// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome.dart';
import 'fade_page_route.dart';
import 'staff_consultation_page.dart';
import 'staff_leave_application.dart';
import 'staff_courses.dart';
import 'staff_stud_directory.dart';
import 'staff_faculty_announcement.dart';
import 'staff_profile_settings.dart'; // <--- 1. IMPORT NEW FILE

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  // --- STATE VARIABLES ---
  String _name = "Dr. Andi Fitriah";
  String _role = "Senior Lecturer";
  String _department = "Dept of Computer Science";

  // --- HELPER: Navigation/Feedback ---
  Future<void> _handleTileTap(String title) async {
    if (title == "Consultation Requests") {
      Navigator.push(
        context,
        FadePageRoute(page: const StaffConsultationPage()),
      );
    } else if (title == "Leave Application") {
      Navigator.push(
        context,
        FadePageRoute(page: const StaffLeaveApplicationPage()),
      );
    } else if (title == "My Courses") {
      Navigator.push(context, FadePageRoute(page: const StaffCoursesPage()));
    } else if (title == "Student Directory") {
      Navigator.push(
        context,
        FadePageRoute(page: const StaffStudentDirectoryPage()),
      );
    } else if (title == "Faculty Announcements") {
      Navigator.push(
        context,
        FadePageRoute(page: const StaffFacultyAnnouncementPage()),
      );
    } else if (title == "Profile Settings") {
      // <--- 2. UPDATED LOGIC FOR SETTINGS
      final result = await Navigator.push(
        context,
        FadePageRoute(
          page: StaffProfileSettingsPage(
            currentName: _name,
            currentRole: _role,
            currentDept: _department,
          ),
        ),
      );

      // 3. Update State if data returned
      if (result != null && result is Map<String, String>) {
        setState(() {
          _name = result['name']!;
          _role = result['role']!;
          _department = result['department']!;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Opening $title..."),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- LOGIC: Quick Edit (Pencil Icon) ---
  // You can keep this or redirect it to the full settings page as well
  void _openQuickEdit() async {
    // Reuse the new settings page logic
    final result = await Navigator.push(
      context,
      FadePageRoute(
        page: StaffProfileSettingsPage(
          currentName: _name,
          currentRole: _role,
          currentDept: _department,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _name = result['name']!;
        _role = result['role']!;
        _department = result['department']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND
          Container(
            height: 340,
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
          ),

          // 2. CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // --- PROFILE HEADER ---
                  Center(
                    child: Column(
                      children: [
                        // Avatar Ring
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  'https://italeemc.iium.edu.my/pluginfile.php/5130/user/icon/remui/f3?rev=175531',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Change Profile Photo"),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Color(0xFF4A00E0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Name & Department
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _name,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  _openQuickEdit, // Link pencil to new page
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white70,
                                size: 18,
                              ),
                              tooltip: "Edit Profile",
                            ),
                          ],
                        ),
                        Text(
                          "$_role • $_department",
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- FLOATING STATS CARD ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat("Courses", "3"),
                        _buildVerticalDivider(),
                        _buildStat("Students", "142"),
                        _buildVerticalDivider(),
                        _buildStat("Consultations", "8"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- MENU SECTIONS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION 1: ACADEMIC
                        Text(
                          "ACADEMIC MANAGEMENT",
                          style: GoogleFonts.lato(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingsTile(
                          Icons.menu_book_rounded,
                          "My Courses",
                          "Syllabus & Materials",
                        ),
                        _buildSettingsTile(
                          Icons.calendar_today_rounded,
                          "Consultation Requests",
                          "Manage student appointments",
                          hasNotification: true,
                        ),
                        _buildSettingsTile(
                          Icons.people_alt_rounded,
                          "Student Directory",
                          "View profiles & performance",
                        ),

                        const SizedBox(height: 30),

                        // SECTION 2: STAFF SERVICES
                        Text(
                          "STAFF SERVICES",
                          style: GoogleFonts.lato(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingsTile(
                          Icons.flight_takeoff_rounded,
                          "Leave Application",
                          "Apply for annual/medical leave",
                        ),
                        _buildSettingsTile(
                          Icons.campaign_rounded,
                          "Faculty Announcements",
                          "Latest updates & circulars",
                        ),

                        const SizedBox(height: 30),

                        // SECTION 3: ACCOUNT
                        Text(
                          "ACCOUNT",
                          style: GoogleFonts.lato(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingsTile(
                          Icons.settings_outlined,
                          "Profile Settings",
                          "Edit Profile, Password & Security",
                        ),

                        const SizedBox(height: 40),

                        // --- LOGOUT BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                FadePageRoute(page: const WelcomeScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Log Out",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    bool hasNotification = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A00E0).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4A00E0), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(color: Colors.grey.shade500, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasNotification)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        onTap: () => _handleTileTap(title),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_page_route.dart';

// --- IMPORTS FOR SPECIFIC COURSE PAGES ---
import 'staff_courses_pits_sect1.dart';
import 'staff_courses_pits_sect2.dart';
import 'staff_courses_netsec_sect1.dart';
import 'staff_courses_def_sect2.dart';

class StaffCoursesPage extends StatefulWidget {
  const StaffCoursesPage({super.key});

  @override
  State<StaffCoursesPage> createState() => _StaffCoursesPageState();
}

class _StaffCoursesPageState extends State<StaffCoursesPage> {
  // Mock Data (Updated with specific timetable)
  final List<Map<String, dynamic>> _courses = [
    {
      "code": "CSCI 2303",
      "name": "Principles of IT Security",
      "section": "Section 1",
      "students": 45,
      // mon & wed: 08.30-10.00 Lab 1
      "time": "Mon & Wed 08:30 - 10:00",
      "room": "Lab 1",
      "progress": 0.65,
      "color": Colors.orange,
    },
    {
      "code": "CSCI 2303",
      "name": "Principles of IT Security",
      "section": "Section 2",
      "students": 40,
      // mon & wed: 10.00-11.30 Lab 1
      "time": "Mon & Wed 10:00 - 11:30",
      "room": "Lab 1",
      "progress": 0.55,
      "color": Colors.orange,
    },
    {
      "code": "CSCI 4336",
      "name": "Network Security",
      "section": "Section 1",
      "students": 38,
      // tue & thu: 14.00-15.30 Lab 3
      "time": "Tue & Thu 14:00 - 15:30",
      "room": "Lab 3",
      "progress": 0.60,
      "color": Colors.blue,
    },
    {
      "code": "CSCI 4332",
      "name": "Digital Evidence Forensics",
      "section": "Section 2",
      "students": 42,
      // mon & wed: 11.30-13.00 Lecture Hall 2
      "time": "Mon & Wed 11:30 - 13:00",
      "room": "Lecture Hall 2", // Shortened for UI fit
      "progress": 0.70,
      "color": Colors.purple,
    },
  ];

  // --- NAVIGATION LOGIC ---
  void _handleCourseTap(Map<String, dynamic> course) {
    Widget? targetPage;

    // Determine destination based on Code + Section
    if (course['code'] == "CSCI 2303" && course['section'] == "Section 1") {
      targetPage = const StaffCoursesPitsSect1Page();
    } else if (course['code'] == "CSCI 2303" &&
        course['section'] == "Section 2") {
      targetPage = const StaffCoursesPitsSect2Page();
    } else if (course['code'] == "CSCI 4336" &&
        course['section'] == "Section 1") {
      targetPage = const StaffCoursesNetsecSect1Page();
    } else if (course['code'] == "CSCI 4332" &&
        course['section'] == "Section 2") {
      targetPage = const StaffCoursesDefSect2Page();
    }

    if (targetPage != null) {
      Navigator.push(context, FadePageRoute(page: targetPage));
    } else {
      // Fallback if the page hasn't been created yet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Materials for ${course['code']} not yet available."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "My Courses",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Header Background
          Container(
            height: 250,
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

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search course code...",
                        hintStyle: GoogleFonts.lato(
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                // Course List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(_courses[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // Material & InkWell make the entire card clickable with ripple effect
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleCourseTap(course), // Trigger Navigation
          child: Column(
            children: [
              // Top Section: Color Strip & Basic Info
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: course['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          course['code'].split(' ')[1], // e.g., 2303
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: course['color'],
                            fontSize: 14,
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
                            course['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "${course['code']} • ${course['section']}",
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: Colors.grey.shade100, height: 1),
              ),

              // Bottom Section: Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Schedule Chips
                    // Using Flexible to prevent overflow on smaller screens
                    Expanded(
                      child: Wrap(
                        spacing: 8, // gap between adjacent chips
                        runSpacing: 8, // gap between lines
                        children: [
                          _buildInfoChip(
                            Icons.access_time_rounded,
                            course['time'],
                          ),
                          _buildInfoChip(
                            Icons.location_on_rounded,
                            course['room'],
                          ),
                        ],
                      ),
                    ),

                    // Students count (Fixed width to keep aligned right)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${course['students']}",
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
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
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // shrink to fit text
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

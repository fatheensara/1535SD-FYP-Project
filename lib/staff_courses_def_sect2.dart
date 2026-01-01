// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffCoursesDefSect2Page extends StatefulWidget {
  const StaffCoursesDefSect2Page({super.key});

  @override
  State<StaffCoursesDefSect2Page> createState() =>
      _StaffCoursesDefSect2PageState();
}

class _StaffCoursesDefSect2PageState extends State<StaffCoursesDefSect2Page>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Course Details",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Header Background
          Container(
            height: 280,
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

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Course Info Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "CSCI 4332 • SECTION 2",
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Digital Evidence Forensics",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 5),

                          Text(
                            "Mon & Wed 11:30 - 13:00 • Lecture Hall 2",
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF4A00E0),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF4A00E0),
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: "Materials"),
                      Tab(text: "Syllabus"),
                      Tab(text: "Students"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tab View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMaterialsTab(),
                      _buildSyllabusTab(),
                      _buildStudentsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add new material dialog...")),
          );
        },
        backgroundColor: const Color(0xFF4A00E0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Material",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // --- TAB 1: MATERIALS ---
  Widget _buildMaterialsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      children: [
        _buildModuleCard("Week 1: Fundamentals of Forensics", [
          {
            "type": "pdf",
            "title": "Lecture 1: Locard's Principle",
            "size": "1.8 MB",
          },
          {
            "type": "video",
            "title": "Case Study: The BTK Killer",
            "size": "20 mins",
          },
        ], isExpanded: false),
        _buildModuleCard(
          "Week 2: Data Acquisition",
          [
            {
              "type": "pdf",
              "title": "Lecture 2: Imaging & Hashing",
              "size": "2.5 MB",
            },
            {
              "type": "lab",
              "title": "Lab 1: Creating Disk Images",
              "size": "500 MB (Dataset)",
            },
          ],
          isExpanded: true, // Currently active week
        ),
        _buildModuleCard("Week 3: File Systems Analysis", [
          {"type": "pdf", "title": "Lecture 3: FAT vs NTFS", "size": "3.0 MB"},
          {
            "type": "lab",
            "title": "Lab 2: Deleted File Recovery",
            "size": "1.5 MB",
          },
          {
            "type": "quiz",
            "title": "Quiz 1: Evidence Handling",
            "size": "15 mins",
          },
        ]),
      ],
    );
  }

  // --- TAB 2: SYLLABUS ---
  Widget _buildSyllabusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Course Description",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This course focuses on the identification, preservation, analysis, and presentation of digital evidence. Students will learn legal procedures, chain of custody, and hands-on techniques using forensic tools.",
              style: GoogleFonts.lato(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              "Learning Outcomes",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              "Apply proper chain of custody procedures for digital evidence.",
            ),
            _buildBulletPoint(
              "Analyze file systems (NTFS, FAT, EXT) to recover deleted data.",
            ),
            _buildBulletPoint(
              "Utilize forensic tools (Autopsy, FTK) for investigation.",
            ),
            const SizedBox(height: 20),
            Text(
              "Assessment Grading",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildGradingRow("Lab Reports", "30%"),
            _buildGradingRow("Case Study", "20%"),
            _buildGradingRow("Midterm Exam", "20%"),
            _buildGradingRow("Final Exam", "30%"),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: STUDENTS ---
  Widget _buildStudentsTab() {
    // Mock List for DEF Section 2
    final List<String> students = [
      "Kevin Hart",
      "Diana Prince",
      "Bruce Wayne",
      "Clark Kent",
      "Natasha R.",
      "Tony Stark",
      "Steve Rogers",
      "Wanda M.",
      "Peter Parker",
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple.shade50, // Purple for DEF
                child: Text(
                  students[index][0],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                students[index],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.mail_outline,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildModuleCard(
    String title,
    List<Map<String, String>> items, {
    bool isExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.only(bottom: 10),
          children: items.map((item) => _buildMaterialItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildMaterialItem(Map<String, String> item) {
    IconData icon;
    Color iconColor;

    switch (item['type']) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        iconColor = Colors.redAccent;
        break;
      case 'video':
        icon = Icons.play_circle_fill_rounded;
        iconColor = Colors.blueAccent;
        break;
      case 'lab':
        icon = Icons.science_rounded; // Science icon for Labs
        iconColor = Colors.teal;
        break;
      case 'quiz':
        icon = Icons.quiz_rounded;
        iconColor = Colors.purpleAccent;
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        item['title']!,
        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        item['size']!,
        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.download_rounded, color: Colors.grey, size: 20),
        onPressed: () {},
      ),
      onTap: () {},
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF4A00E0)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.lato(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingRow(String component, String weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(component, style: GoogleFonts.lato(color: Colors.grey.shade700)),
          Text(
            weight,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A00E0),
            ),
          ),
        ],
      ),
    );
  }
}

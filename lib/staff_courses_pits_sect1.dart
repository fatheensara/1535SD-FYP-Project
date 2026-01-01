// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffCoursesPitsSect1Page extends StatefulWidget {
  const StaffCoursesPitsSect1Page({super.key});

  @override
  State<StaffCoursesPitsSect1Page> createState() =>
      _StaffCoursesPitsSect1PageState();
}

class _StaffCoursesPitsSect1PageState extends State<StaffCoursesPitsSect1Page>
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
                          "CSCI 2303 • SECTION 1",
                          style: GoogleFonts.sourceCodePro(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Principles of IT Security",
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
                            " Mon & Wed 08:30 - 10:00 • Lab 1",
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

  // --- TAB 1: MATERIALS (Modules) ---
  Widget _buildMaterialsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      children: [
        _buildModuleCard("Week 1: Introduction to Security", [
          {"type": "pdf", "title": "Lecture 1: CIA Triad", "size": "2.4 MB"},
          {"type": "video", "title": "Intro Video", "size": "15 mins"},
        ], isExpanded: true),
        _buildModuleCard("Week 2: Cryptography Basics", [
          {
            "type": "pdf",
            "title": "Lecture 2: Symmetric Keys",
            "size": "3.1 MB",
          },
          {"type": "lab", "title": "Lab 1: Caesar Cipher", "size": "1.2 MB"},
        ]),
        _buildModuleCard("Week 3: Public Key Infrastructure", [
          {"type": "pdf", "title": "Lecture 3: RSA & ECC", "size": "2.8 MB"},
          {"type": "quiz", "title": "Quiz 1: Crypto", "size": "30 mins"},
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
              "This course provides a comprehensive overview of information security principles. Topics include confidentiality, integrity, availability, cryptography, network security, and risk management.",
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
              "Understand the core principles of the CIA triad.",
            ),
            _buildBulletPoint(
              "Analyze cryptographic algorithms and protocols.",
            ),
            _buildBulletPoint("Identify network vulnerabilities and threats."),
            const SizedBox(height: 20),
            Text(
              "Assessment Grading",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildGradingRow("Quizzes", "10%"),
            _buildGradingRow("Assignments", "20%"),
            _buildGradingRow("Midterm Exam", "30%"),
            _buildGradingRow("Final Exam", "40%"),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: STUDENTS ---
  Widget _buildStudentsTab() {
    // Mock List
    final List<String> students = [
      "Ahmad Ali",
      "Sarah Lee",
      "Muthu Kumar",
      "Jessica Tan",
      "Lee Wei Ming",
      "Nurul Huda",
      "John Doe",
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
                backgroundColor: Colors.indigo.shade50,
                child: Text(
                  students[index][0],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
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
        icon = Icons.terminal_rounded;
        iconColor = Colors.orangeAccent;
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
      onTap: () {}, // Open file logic
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

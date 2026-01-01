import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffFacultyAnnouncementPage extends StatefulWidget {
  const StaffFacultyAnnouncementPage({super.key});

  @override
  State<StaffFacultyAnnouncementPage> createState() =>
      _StaffFacultyAnnouncementPageState();
}

class _StaffFacultyAnnouncementPageState
    extends State<StaffFacultyAnnouncementPage> {
  // Filter State
  String _selectedCategory = "All";

  // Mock Data
  final List<Map<String, dynamic>> _announcements = [
    {
      "title": "Dean's List Ceremony Postponed",
      "date": "2 hours ago",
      "category": "Events",
      "priority": "Urgent",
      "content":
          "Due to unforeseen venue maintenance, the Dean's List Award Ceremony scheduled for this Friday has been postponed to next Wednesday, 2:00 PM at the Main Audi. We apologize for the inconvenience.",
      "author": "Office of the Dean",
    },
    {
      "title": "New Grant Application Guidelines",
      "date": "Yesterday",
      "category": "Research",
      "priority": "Normal",
      "content":
          "The Ministry has released updated guidelines for the FRGS 2026 cycle. Please review the attached PDF in the portal before submitting your proposals. Key changes include budget allocation limits.",
      "author": "Research Management Centre",
    },
    {
      "title": "Campus Shuttle Service Update",
      "date": "2 days ago",
      "category": "Admin",
      "priority": "Normal",
      "content":
          "Starting next week, the campus shuttle frequency will increase during peak hours (8 AM - 10 AM). A new route covering the Mahallah Ruqayyah sector has also been added.",
      "author": "Facilities Management",
    },
    {
      "title": "Submission of Final Grades",
      "date": "3 days ago",
      "category": "Academic",
      "priority": "High",
      "content":
          "All academic staff are reminded that the deadline for final grade submission for Semester 1, 2025/2026 is strictly on 15th January. Late submissions will require written justification.",
      "author": "Academic Management Division",
    },
  ];

  List<String> get _categories => [
    "All",
    "Academic",
    "Research",
    "Events",
    "Admin",
  ];

  List<Map<String, dynamic>> get _filteredList {
    if (_selectedCategory == "All") return _announcements;
    return _announcements
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  // --- LOGIC: Show Details Modal ---
  void _showAnnouncementDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              child: Column(
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
                  // Badges
                  Row(
                    children: [
                      _buildCategoryBadge(item['category']),
                      const SizedBox(width: 10),
                      if (item['priority'] != "Normal")
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item['priority'] == "Urgent"
                                ? Colors.red.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: item['priority'] == "Urgent"
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                          child: Text(
                            item['priority'].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item['priority'] == "Urgent"
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    item['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${item['date']} • by ${item['author']}",
                        style: GoogleFonts.lato(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  Text(
                    item['content'],
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A00E0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Announcements",
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
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    children: _categories.map((cat) {
                      bool isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  // ignore: deprecated_member_use
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF4A00E0)
                                    : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildAnnouncementCard(_filteredList[index]);
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

  Widget _buildAnnouncementCard(Map<String, dynamic> item) {
    bool isUrgent = item['priority'] == "Urgent";

    return GestureDetector(
      onTap: () => _showAnnouncementDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: isUrgent ? Border.all(color: Colors.red.shade200) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryBadge(item['category']),
                if (isUrgent)
                  const Icon(
                    Icons.priority_high_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['title'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['content'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 5),
                Text(
                  item['date'],
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                Text(
                  "Read More",
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A00E0),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Color(0xFF4A00E0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color bg;
    Color text;

    switch (category) {
      case "Academic":
        bg = Colors.blue.shade50;
        text = Colors.blue;
        break;
      case "Events":
        bg = Colors.purple.shade50;
        text = Colors.purple;
        break;
      case "Research":
        bg = Colors.teal.shade50;
        text = Colors.teal;
        break;
      case "Admin":
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        break;
      default:
        bg = Colors.indigo.shade50;
        text = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Optional: Add to pubspec if you want real calls

class StaffStudentDirectoryPage extends StatefulWidget {
  const StaffStudentDirectoryPage({super.key});

  @override
  State<StaffStudentDirectoryPage> createState() =>
      _StaffStudentDirectoryPageState();
}

class _StaffStudentDirectoryPageState extends State<StaffStudentDirectoryPage> {
  // Filter State
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredStudents = [];

  // Mock Data
  final List<String> _filters = [
    "All",
    "CSCI 2303",
    "CSCI 4336",
    "CSCI 4332",
    "Probation",
  ];

  final List<Map<String, dynamic>> _allStudents = [
    {
      "name": "Ahmad Ali",
      "matric": "2115542",
      "course": "CSCI 2303",
      "email": "ahmad.ali@student.iium.edu.my",
      "status": "Active",
      "gpa": "3.5",
      "image": "A",
    },
    {
      "name": "Sarah Lee",
      "matric": "2113341",
      "course": "CSCI 4336",
      "email": "sarah.lee@student.iium.edu.my",
      "status": "Active",
      "gpa": "3.8",
      "image": "S",
    },
    {
      "name": "Muthu Kumar",
      "matric": "2114421",
      "course": "CSCI 4332",
      "email": "muthu.k@student.iium.edu.my",
      "status": "Probation",
      "gpa": "1.9",
      "image": "M",
    },
    {
      "name": "Jessica Tan",
      "matric": "2118892",
      "course": "CSCI 2303",
      "email": "jessica.t@student.iium.edu.my",
      "status": "Active",
      "gpa": "3.2",
      "image": "J",
    },
    {
      "name": "Lee Wei Ming",
      "matric": "2117763",
      "course": "CSCI 4336",
      "email": "lee.wm@student.iium.edu.my",
      "status": "Active",
      "gpa": "3.9",
      "image": "L",
    },
    {
      "name": "Nurul Huda",
      "matric": "2119912",
      "course": "CSCI 4332",
      "email": "nurul.h@student.iium.edu.my",
      "status": "Active",
      "gpa": "3.6",
      "image": "N",
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredStudents = _allStudents;
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        bool matchesFilter =
            _selectedFilter == "All" ||
            student['course'] == _selectedFilter ||
            (_selectedFilter == "Probation" &&
                student['status'] == "Probation");

        bool matchesSearch =
            student['name'].toLowerCase().contains(query) ||
            student['matric'].contains(query);

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _onFilterTap(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterList();
    });
  }

  // Action Sheet
  void _showStudentActions(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                student['name'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                student['matric'],
                style: GoogleFonts.lato(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email_outlined, color: Colors.blue),
                ),
                title: const Text("Send Email"),
                subtitle: Text(student['email']),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Drafting email to ${student['name']}..."),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: Colors.green,
                  ),
                ),
                title: const Text("View Academic Performance"),
                subtitle: Text("Current GPA: ${student['gpa']}"),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to detailed performance page if needed
                },
              ),
            ],
          ),
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
          "Student Directory",
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
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0038), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
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
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search by name or matric...",
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

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: _filters.map((filter) {
                      bool isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: GoogleFonts.lato(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4A00E0),
                          backgroundColor: Colors.white,
                          onSelected: (bool selected) {
                            if (selected) _onFilterTap(filter);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Student List
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "No students found",
                                style: GoogleFonts.lato(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            return _buildStudentCard(_filteredStudents[index]);
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

  Widget _buildStudentCard(Map<String, dynamic> student) {
    bool isProbation = student['status'] == "Probation";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isProbation ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isProbation
              ? Colors.red.shade50
              : Colors.indigo.shade50,
          child: Text(
            student['image'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isProbation ? Colors.red : Colors.indigo,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          student['name'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${student['matric']} • ${student['course']}",
              style: GoogleFonts.lato(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            if (isProbation)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Probation",
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
          onPressed: () => _showStudentActions(student),
        ),
        onTap: () => _showStudentActions(student),
      ),
    );
  }
}

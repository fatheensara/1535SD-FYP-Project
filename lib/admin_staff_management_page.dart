import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminStaffManagementPage extends StatefulWidget {
  const AdminStaffManagementPage({super.key});

  @override
  State<AdminStaffManagementPage> createState() =>
      _AdminStaffManagementPageState();
}

class _AdminStaffManagementPageState extends State<AdminStaffManagementPage> {
  // Mock Data
  final List<Map<String, dynamic>> _staffList = [
    {
      "name": "Dr. Takumi Sase",
      "id": "S1029",
      "dept": "Computer Science",
      "status": "Active",
      "color": Colors.blue,
    },
    {
      "name": "Dr. Nurul Liyana",
      "id": "S1033",
      "dept": "Information Systems",
      "status": "Active",
      "color": Colors.purple,
    },
    {
      "name": "Mdm. Sarah Jones",
      "id": "S2001",
      "dept": "Registrar Office",
      "status": "On Leave",
      "color": Colors.orange,
    },
    {
      "name": "Dr. Andi Fitriah",
      "id": "S1045",
      "dept": "Computer Science",
      "status": "Active",
      "color": Colors.green,
    },
    {
      "name": "Mr. John Doe",
      "id": "S3002",
      "dept": "Lab Technician",
      "status": "Suspended",
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Note: Background is provided by the parent AdminHomePage stack
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Staff Directory",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Manage access & roles",
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.tealAccent,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SEARCH BAR
                  _buildGlassSearchBar(),
                ],
              ),
            ),

            // --- LIST SECTION ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: _staffList.length,
                itemBuilder: (context, index) {
                  return _buildStaffCard(_staffList[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Push above nav bar
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Opening Registration Form...")),
            );
          },
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.person_add),
          label: Text(
            "Add Staff",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildGlassSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            style: GoogleFonts.lato(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search by Name or ID...",
              hintStyle: GoogleFonts.lato(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff) {
    Color statusColor;
    switch (staff['status']) {
      case 'Active':
        statusColor = Colors.greenAccent;
        break;
      case 'On Leave':
        statusColor = Colors.orangeAccent;
        break;
      default:
        statusColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: staff['color'], width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Text(
                      staff['name'][0],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${staff['id']} • ${staff['dept']}",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status & Menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        staff['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.more_horiz,
                      color: Colors.white30,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

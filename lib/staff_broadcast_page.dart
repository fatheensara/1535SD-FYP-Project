import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffBroadcastPage extends StatefulWidget {
  const StaffBroadcastPage({super.key});

  @override
  State<StaffBroadcastPage> createState() => _StaffBroadcastPageState();
}

class _StaffBroadcastPageState extends State<StaffBroadcastPage> {
  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // --- MOCK SUBJECT LIST ---
  // isSelected tracks the checkbox state
  final List<Map<String, dynamic>> _subjects = [
    {
      "code": "CSCI 2303",
      "section": "Section 1",
      "name": "Principles of IT Security",
      "isSelected": false,
    },
    {
      "code": "CSCI 2303",
      "section": "Section 2",
      "name": "Principles of IT Security",
      "isSelected": false,
    },
    {
      "code": "CSCI 4336",
      "section": "Section 1",
      "name": "Network Security",
      "isSelected": false,
    },
    {
      "code": "CSCI 4332",
      "section": "Section 2",
      "name": "Digital Evidence Forensics",
      "isSelected": false,
    },
  ];

  // Helper to toggle all
  void _toggleSelectAll(bool? value) {
    setState(() {
      for (var subject in _subjects) {
        subject['isSelected'] = value ?? false;
      }
    });
  }

  // Quick Templates
  void _applyTemplate(String type) {
    setState(() {
      if (type == "Cancel") {
        _titleController.text = "URGENT: Class Cancelled";
        _bodyController.text =
            "Dear students, today's class is cancelled due to unavoidable circumstances. Please check the LMS for replacement details.";
      } else if (type == "Room") {
        _titleController.text = "Venue Change Update";
        _bodyController.text =
            "Please note that today's class has been moved to Lab 4.";
      } else if (type == "Reminder") {
        _titleController.text = "Assignment Reminder";
        _bodyController.text =
            "This is a gentle reminder that Assignment 1 is due this Friday at 11:59 PM.";
      }
    });
  }

  void _sendBroadcast() {
    int selectedCount = _subjects.where((s) => s['isSelected']).length;

    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one class.")),
      );
      return;
    }
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and message.")),
      );
      return;
    }

    // Success Simulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Broadcast sent to $selectedCount classes!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Go back home
  }

  @override
  Widget build(BuildContext context) {
    bool allSelected = _subjects.every((s) => s['isSelected']);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "New Broadcast",
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
          // 1. HEADER BACKGROUND
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

          // 2. CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notify Students",
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Select Recipients",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- SUBJECT SELECTION CARD ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Select All Toggle
                        CheckboxListTile(
                          title: Text(
                            "Select All Classes",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A00E0),
                            ),
                          ),
                          value: allSelected,
                          onChanged: _toggleSelectAll,
                          activeColor: const Color(0xFF4A00E0),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const Divider(height: 1),
                        // List of Subjects
                        ..._subjects.map((subject) {
                          return CheckboxListTile(
                            title: Text(
                              "${subject['code']} - ${subject['section']}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              subject['name'],
                              style: GoogleFonts.lato(fontSize: 12),
                            ),
                            value: subject['isSelected'],
                            onChanged: (val) {
                              setState(() {
                                subject['isSelected'] = val;
                              });
                            },
                            activeColor: const Color(0xFF4A00E0),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- MESSAGE COMPOSITION ---
                  Text(
                    "Compose Message",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Templates
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTemplateChip(
                          "Class Cancelled",
                          "Cancel",
                          Colors.red,
                        ),
                        const SizedBox(width: 8),
                        _buildTemplateChip(
                          "Room Change",
                          "Room",
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildTemplateChip("Reminder", "Reminder", Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Title Input
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Subject / Title",
                      hintStyle: GoogleFonts.lato(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),

                  // Body Input
                  TextField(
                    controller: _bodyController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Type your announcement here...",
                      hintStyle: GoogleFonts.lato(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    style: GoogleFonts.lato(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // SEND BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _sendBroadcast,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            icon: const Icon(Icons.send_rounded),
            label: Text(
              "Send Broadcast",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label, String type, Color color) {
    return ActionChip(
      label: Text(label),
      labelStyle: GoogleFonts.poppins(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _applyTemplate(type),
    );
  }
}

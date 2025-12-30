import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/notification_service.dart'; 

class StaffBroadcastPage extends StatefulWidget {
  const StaffBroadcastPage({super.key});

  @override
  State<StaffBroadcastPage> createState() => _StaffBroadcastPageState();
}

class _StaffBroadcastPageState extends State<StaffBroadcastPage> {
  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSending = false; 

  // --- MOCK SUBJECT LIST ---
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

  // --- MAIN FUNCTION: SEND TO DATABASE ---
  Future<void> _sendBroadcast() async {
    // 1. Validation
    List<String> selectedCourses = _subjects
        .where((s) => s['isSelected'])
        .map((s) => "${s['code']} - ${s['section']}")
        .toList();

    if (selectedCourses.isEmpty) {
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

    // 2. Start Loading
    setState(() => _isSending = true);

    try {
      // 3. Call Service
      await NotificationService.sendBroadcast(
        title: _titleController.text,
        message: _bodyController.text,
        type: "Broadcast", 
        courseCodes: selectedCourses,
        senderName: "Dr. Andi Fitriah", 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Broadcast sent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sending broadcast: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Notify Students", style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text("Select Recipients", style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  // Subject Selection Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text("Select All Classes", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF4A00E0))),
                          value: allSelected,
                          onChanged: _toggleSelectAll,
                          activeColor: const Color(0xFF4A00E0),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const Divider(height: 1),
                        ..._subjects.map((subject) {
                          return CheckboxListTile(
                            title: Text("${subject['code']} - ${subject['section']}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(subject['name'], style: GoogleFonts.lato(fontSize: 12)),
                            value: subject['isSelected'],
                            onChanged: (val) => setState(() => subject['isSelected'] = val),
                            activeColor: const Color(0xFF4A00E0),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  Text("Compose Message", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTemplateChip("Class Cancelled", "Cancel", Colors.red),
                        const SizedBox(width: 8),
                        _buildTemplateChip("Room Change", "Room", Colors.orange),
                        const SizedBox(width: 8),
                        _buildTemplateChip("Reminder", "Reminder", Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Input Fields
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration("Subject / Title"),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _bodyController,
                    maxLines: 5,
                    decoration: _inputDecoration("Type your announcement here..."),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isSending ? null : _sendBroadcast,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
            ),
            icon: _isSending 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.send_rounded),
            label: Text(_isSending ? "Sending..." : "Send Broadcast", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: GoogleFonts.lato(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(20),
    );
  }

  Widget _buildTemplateChip(String label, String type, Color color) {
    return ActionChip(
      label: Text(label),
      labelStyle: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _applyTemplate(type),
    );
  }
}

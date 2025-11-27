import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffAttendanceSettingsPage extends StatefulWidget {
  final VoidCallback onReset;
  const StaffAttendanceSettingsPage({super.key, required this.onReset});

  @override
  State<StaffAttendanceSettingsPage> createState() =>
      _StaffAttendanceSettingsPageState();
}

class _StaffAttendanceSettingsPageState
    extends State<StaffAttendanceSettingsPage> {
  bool _allowLate = true;
  bool _lockSession = false;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text(
          "Session Control",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader("Access"),
          _buildSwitchTile(
            "Allow Late Check-ins",
            "Students can scan after 15 mins",
            _allowLate,
            (v) => setState(() => _allowLate = v),
            Icons.timer_outlined,
          ),
          _buildSwitchTile(
            "Lock Session",
            "Prevent new scans instantly",
            _lockSession,
            (v) => setState(() => _lockSession = v),
            Icons.lock_outline,
            activeColor: Colors.redAccent,
          ),

          const SizedBox(height: 30),
          _buildHeader("Feedback"),
          _buildSwitchTile(
            "Sound Effects",
            "Beep on scan success",
            _soundEnabled,
            (v) => setState(() => _soundEnabled = v),
            Icons.volume_up_outlined,
          ),

          const SizedBox(height: 40),
          _buildHeader("Danger Zone"),
          InkWell(
            onTap: () {
              // Confirm Dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF24243E),
                  title: const Text(
                    "Reset Session?",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "This clears all attendance records.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        widget.onReset();
                        Navigator.pop(ctx);
                        Navigator.pop(context); // Go back to monitor
                      },
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_forever, color: Colors.redAccent),
                  const SizedBox(width: 15),
                  Text(
                    "Reset All Data",
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
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

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lato(
          color: Colors.white38,
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool val,
    Function(bool) onChange,
    IconData icon, {
    Color activeColor = Colors.purpleAccent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: val,
        onChanged: onChange,
        // ignore: deprecated_member_use
        activeColor: activeColor,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(color: Colors.white38, fontSize: 12),
        ),
        secondary: Icon(icon, color: Colors.white70),
      ),
    );
  }
}

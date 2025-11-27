import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffAttendanceSettingsPage extends StatefulWidget {
  // Add this variable to hold the function
  final VoidCallback onReset;

  // Update constructor to require this function
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
  bool _hapticEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Session Settings",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ... (Session Control and Feedback sections remain the same) ...
          _buildSectionHeader("Session Control"),
          _buildSwitchTile(
            title: "Allow Late Check-ins",
            subtitle: "Students can still mark attendance after 15 mins",
            value: _allowLate,
            onChanged: (val) => setState(() => _allowLate = val),
            icon: Icons.access_time_filled,
            color: Colors.orange,
          ),
          _buildSwitchTile(
            title: "Lock Session",
            subtitle: "Prevent any new scans immediately",
            value: _lockSession,
            onChanged: (val) => setState(() => _lockSession = val),
            icon: Icons.lock_outline,
            color: Colors.red,
          ),

          const SizedBox(height: 25),
          _buildSectionHeader("Feedback"),
          _buildSwitchTile(
            title: "Sound Effects",
            subtitle: "Play a beep on successful scan",
            value: _soundEnabled,
            onChanged: (val) => setState(() => _soundEnabled = val),
            icon: Icons.volume_up_rounded,
            color: Colors.blue,
          ),
          _buildSwitchTile(
            title: "Haptic Feedback",
            subtitle: "Vibrate device on scan",
            value: _hapticEnabled,
            onChanged: (val) => setState(() => _hapticEnabled = val),
            icon: Icons.vibration,
            color: Colors.purple,
          ),

          const SizedBox(height: 25),
          _buildSectionHeader("Data Management"),

          _buildActionTile(
            title: "Export Attendance Data",
            subtitle: "Download as CSV or PDF",
            icon: Icons.download_rounded,
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Exporting data...")),
              );
            },
          ),

          // --- THE RESET BUTTON ---
          _buildActionTile(
            title: "Reset Session",
            subtitle: "Clear all current scans",
            icon: Icons.refresh_rounded,
            color: Colors.redAccent,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Reset Session?"),
                    content: const Text(
                      "This will clear all current attendance records for this class. This action cannot be undone.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Reset"),
                        onPressed: () {
                          // 1. Close the dialog
                          Navigator.of(context).pop();

                          // 2. CALL THE FUNCTION FROM THE PARENT PAGE
                          widget.onReset();

                          // 3. Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Session has been reset."),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ... (Helper widgets _buildSectionHeader, _buildSwitchTile, etc. remain the same) ...
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        // ignore: deprecated_member_use
        activeColor: color,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

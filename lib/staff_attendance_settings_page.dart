import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffAttendanceSettingsPage extends StatefulWidget {
  final VoidCallback onReset;
  final bool soundEnabled;
  final ValueChanged<bool> onSoundChanged;
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const StaffAttendanceSettingsPage({
    super.key,
    required this.onReset,
    required this.soundEnabled,
    required this.onSoundChanged,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  State<StaffAttendanceSettingsPage> createState() =>
      _StaffAttendanceSettingsPageState();
}

class _StaffAttendanceSettingsPageState
    extends State<StaffAttendanceSettingsPage> {
  bool _allowLate = true;
  bool _lockSession = false;
  late bool _soundEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.soundEnabled;
    _volume = widget.volume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Session Control",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                Text(
                  "Configure your live session",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),

                // SETTINGS LIST
                _buildHeader("Access Control"),
                _buildSwitchTile(
                  "Allow Late Check-ins",
                  "Students can scan after 15 mins",
                  _allowLate,
                  (v) => setState(() => _allowLate = v),
                  Icons.timer_outlined,
                  Colors.orange,
                ),
                _buildSwitchTile(
                  "Lock Session",
                  "Prevent new scans instantly",
                  _lockSession,
                  (v) => setState(() => _lockSession = v),
                  Icons.lock_outline,
                  Colors.red,
                ),

                const SizedBox(height: 25),
                _buildHeader("Feedback"),
                _buildSwitchTile(
                  "Sound Effects",
                  "Beep on scan success",
                  _soundEnabled,
                  (v) {
                    setState(() => _soundEnabled = v);
                    widget.onSoundChanged(v); 
                  },
                  Icons.volume_up_outlined,
                  Colors.blue,
                ),

                // VOLUME SLIDER
                if (_soundEnabled) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Beep Volume: ${(_volume * 100).toInt()}%",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Slider(
                          value: _volume,
                          min: 0.0,
                          max: 1.0,
                          activeColor: const Color(0xFF4A00E0),
                          inactiveColor: Colors.grey.shade200,
                          onChanged: (newVal) {
                            setState(() => _volume = newVal);
                            widget.onVolumeChanged(newVal); 
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),
                _buildHeader("Danger Zone"),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text(
                          "Reset Session?",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        content: Text(
                          "This clears all attendance records for the current session.",
                          style: GoogleFonts.lato(color: Colors.grey[700]),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          TextButton(
                            child: const Text(
                              "Reset",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              widget.onReset();
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reset All Data",
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Clear list & restart",
                                style: GoogleFonts.lato(
                                  color: Colors.red.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
          color: Colors.grey.shade600,
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
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        value: val,
        onChanged: onChange,
        activeThumbColor: const Color(0xFF4A00E0),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(color: Colors.grey.shade500, fontSize: 12),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}

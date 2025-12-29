import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // REQUIRED PACKAGE
import 'staff_attendance_settings_page.dart';

class StaffLiveAttendancePitsSect1Page extends StatefulWidget {
  const StaffLiveAttendancePitsSect1Page({super.key});

  @override
  State<StaffLiveAttendancePitsSect1Page> createState() =>
      _StaffLiveAttendancePitsSect1PageState();
}

class _StaffLiveAttendancePitsSect1PageState
    extends State<StaffLiveAttendancePitsSect1Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Audio Player
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true; // State for sound
  double _volume = 0.5; // State for volume (0.0 to 1.0)

  // --- MOCK DATA: 45 STUDENTS ---
  final List<Map<String, dynamic>> _students = [
    {"name": "Aaron Lim", "id": "2110001", "status": "Pending", "time": "-"},
    {"name": "Amira H.", "id": "2110002", "status": "Pending", "time": "-"},
    {"name": "Benjamin T.", "id": "2110003", "status": "Pending", "time": "-"},
    {"name": "Cassandra", "id": "2110004", "status": "Pending", "time": "-"},
    {"name": "Dinesh K.", "id": "2110005", "status": "Pending", "time": "-"},
    {"name": "Elena R.", "id": "2110006", "status": "Pending", "time": "-"},
    {"name": "Faizal M.", "id": "2110007", "status": "Pending", "time": "-"},
    {"name": "Grace Lee", "id": "2110008", "status": "Pending", "time": "-"},
    {"name": "Hafiz S.", "id": "2110009", "status": "Pending", "time": "-"},
    {"name": "Iris Wong", "id": "2110010", "status": "Pending", "time": "-"},
    {"name": "Jason C.", "id": "2110011", "status": "Pending", "time": "-"},
    {"name": "Khairul A.", "id": "2110012", "status": "Pending", "time": "-"},
    {"name": "Latifah", "id": "2110013", "status": "Pending", "time": "-"},
    {"name": "Michelle", "id": "2110014", "status": "Pending", "time": "-"},
    {"name": "Nathan", "id": "2110015", "status": "Pending", "time": "-"},
    {"name": "Olivia P.", "id": "2110016", "status": "Pending", "time": "-"},
    {"name": "Peter Tan", "id": "2110017", "status": "Pending", "time": "-"},
    {"name": "Qayla R.", "id": "2110018", "status": "Pending", "time": "-"},
    {"name": "Ramesh V.", "id": "2110019", "status": "Pending", "time": "-"},
    {"name": "Sarah J.", "id": "2110020", "status": "Pending", "time": "-"},
    {"name": "Taufiq H.", "id": "2110021", "status": "Pending", "time": "-"},
    {"name": "Umairah", "id": "2110022", "status": "Pending", "time": "-"},
    {"name": "Victor L.", "id": "2110023", "status": "Pending", "time": "-"},
    {"name": "Wei Ming", "id": "2110024", "status": "Pending", "time": "-"},
    {"name": "Xandra", "id": "2110025", "status": "Pending", "time": "-"},
    {"name": "Yusri B.", "id": "2110026", "status": "Pending", "time": "-"},
    {"name": "Zahra K.", "id": "2110027", "status": "Pending", "time": "-"},
    {"name": "Adam Lee", "id": "2110028", "status": "Pending", "time": "-"},
    {"name": "Brian Goh", "id": "2110029", "status": "Pending", "time": "-"},
    {"name": "Cindy T.", "id": "2110030", "status": "Pending", "time": "-"},
    {"name": "David C.", "id": "2110031", "status": "Pending", "time": "-"},
    {"name": "Esther Y.", "id": "2110032", "status": "Pending", "time": "-"},
    {"name": "Farhan Z.", "id": "2110033", "status": "Pending", "time": "-"},
    {"name": "Gavin S.", "id": "2110034", "status": "Pending", "time": "-"},
    {"name": "Hana Lim", "id": "2110035", "status": "Pending", "time": "-"},
    {"name": "Isaac N.", "id": "2110036", "status": "Pending", "time": "-"},
    {"name": "Julia R.", "id": "2110037", "status": "Pending", "time": "-"},
    {"name": "Kamal D.", "id": "2110038", "status": "Pending", "time": "-"},
    {"name": "Lisa M.", "id": "2110039", "status": "Pending", "time": "-"},
    {"name": "Manny P.", "id": "2110040", "status": "Pending", "time": "-"},
    {"name": "Nina O.", "id": "2110041", "status": "Pending", "time": "-"},
    {"name": "Oscar T.", "id": "2110042", "status": "Pending", "time": "-"},
    {"name": "Penny L.", "id": "2110043", "status": "Pending", "time": "-"},
    {"name": "Quinn S.", "id": "2110044", "status": "Pending", "time": "-"},
    {"name": "Ryan K.", "id": "2110045", "status": "Pending", "time": "-"},
  ];

  @override
  void initState() {
    super.initState();
    _students.sort((a, b) => a['id'].compareTo(b['id']));

    // Initialize Audio
    _audioPlayer = AudioPlayer();

    // Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose(); // Dispose audio
    super.dispose();
  }

  void _resetAttendanceData() {
    setState(() {
      for (var s in _students) {
        s['status'] = 'Pending';
        s['time'] = '-';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All attendance data has been reset."),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // --- PLAY SOUND LOGIC ---
  Future<void> _playSound() async {
    if (_soundEnabled) {
      try {
        await _audioPlayer.setVolume(_volume);
        // Ensure you have 'beep.mp3' in your assets folder and pubspec.yaml
        await _audioPlayer.play(AssetSource('beep.mp3'));
      } catch (e) {
        debugPrint("Audio Error: $e");
      }
    }
  }

  void _simulateNfcScan() async {
    bool marked = false;
    setState(() {
      for (var s in _students) {
        if (s['status'] == 'Pending') {
          s['status'] = 'Present';
          s['time'] = '08:45 AM';
          marked = true;
          break;
        }
      }
    });

    if (marked) {
      // Play Sound
      await _playSound();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("NFC Tag Detected: Student Marked Present"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students.where((s) => s['status'] == 'Present').length;
    int absentCount = _students.where((s) => s['status'] == 'Absent').length;
    int excusedCount = _students.where((s) => s['status'] == 'Excused').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        title: Text(
          "Live: PITS Sect 1",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                // Pass current state and callbacks
                builder: (_) => StaffAttendanceSettingsPage(
                  onReset: _resetAttendanceData,
                  soundEnabled: _soundEnabled,
                  onSoundChanged: (val) => setState(() => _soundEnabled = val),
                  volume: _volume,
                  onVolumeChanged: (val) => setState(() => _volume = val),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 320,
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
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Pulse Animation
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: const Icon(
                      Icons.nfc_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Principles of IT Security (Sect 1)",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // STATS CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Present", presentCount, Colors.green),
                      _buildVerticalDivider(),
                      _buildStatItem("Excused", excusedCount, Colors.blue),
                      _buildVerticalDivider(),
                      _buildStatItem("Absent", absentCount, Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // STUDENT LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: _students.length,
                    itemBuilder: (context, index) =>
                        _buildStudentCard(_students[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateNfcScan,
        backgroundColor: const Color(0xFF4A00E0),
        icon: const Icon(
          Icons.wifi_tethering,
          color: Colors.white,
        ), // Icon White
        label: const Text(
          "Simulate Scan",
          style: TextStyle(color: Colors.white), // Text White
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    String status = student['status'];
    Color statusColor;
    IconData statusIcon;

    if (status == 'Present') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'Excused') {
      statusColor = Colors.blue;
      statusIcon = Icons.file_present;
    } else if (status == 'Absent') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.hourglass_empty;
    }

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFF6F8FA),
          child: Text(
            student['name'][0],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A00E0),
            ),
          ),
        ),
        title: Text(
          student['name'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student['id'],
              style: GoogleFonts.sourceCodePro(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (status == 'Present')
              Text(
                "Scanned at ${student['time']}",
                style: GoogleFonts.lato(
                  color: Colors.green,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  "Manual Override",
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      "Present",
                      Colors.green,
                      status == "Present",
                      () => setState(() {
                        student['status'] = "Present";
                        student['time'] = "Manual";
                      }),
                    ),
                    _buildActionButton(
                      "Excused",
                      Colors.blue,
                      status == "Excused",
                      () => setState(() => student['status'] = "Excused"),
                    ),
                    _buildActionButton(
                      "Absent",
                      Colors.red,
                      status == "Absent",
                      () => setState(() => student['status'] = "Absent"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            // ignore: deprecated_member_use
            color: isActive ? Colors.transparent : color.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isActive ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

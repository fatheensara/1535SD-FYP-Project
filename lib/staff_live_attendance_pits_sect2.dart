import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // REQUIRED PACKAGE
import 'staff_attendance_settings_page.dart';

class StaffLiveAttendancePitsSect2Page extends StatefulWidget {
  const StaffLiveAttendancePitsSect2Page({super.key});

  @override
  State<StaffLiveAttendancePitsSect2Page> createState() =>
      _StaffLiveAttendancePitsSect2PageState();
}

class _StaffLiveAttendancePitsSect2PageState
    extends State<StaffLiveAttendancePitsSect2Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Audio Player State
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  double _volume = 0.5;

  // --- MOCK DATA: 40 STUDENTS (Sect 2) ---
  final List<Map<String, dynamic>> _students = [
    {"name": "Ahmad A.", "id": "2120001", "status": "Pending", "time": "-"},
    {"name": "Siti N.", "id": "2120002", "status": "Pending", "time": "-"},
    {"name": "Chong W.", "id": "2120003", "status": "Pending", "time": "-"},
    {"name": "Muthu K.", "id": "2120004", "status": "Pending", "time": "-"},
    {"name": "Alice T.", "id": "2120005", "status": "Pending", "time": "-"},
    {"name": "Brendan", "id": "2120006", "status": "Pending", "time": "-"},
    {"name": "Catherine", "id": "2120007", "status": "Pending", "time": "-"},
    {"name": "Daniel L.", "id": "2120008", "status": "Pending", "time": "-"},
    {"name": "Elaine K.", "id": "2120009", "status": "Pending", "time": "-"},
    {"name": "Farid R.", "id": "2120010", "status": "Pending", "time": "-"},
    {"name": "Gita P.", "id": "2120011", "status": "Pending", "time": "-"},
    {"name": "Harris M.", "id": "2120012", "status": "Pending", "time": "-"},
    {"name": "Izzat H.", "id": "2120013", "status": "Pending", "time": "-"},
    {"name": "Jenny L.", "id": "2120014", "status": "Pending", "time": "-"},
    {"name": "Kevin T.", "id": "2120015", "status": "Pending", "time": "-"},
    {"name": "Liyana Z.", "id": "2120016", "status": "Pending", "time": "-"},
    {"name": "Marcus", "id": "2120017", "status": "Pending", "time": "-"},
    {"name": "Nadia S.", "id": "2120018", "status": "Pending", "time": "-"},
    {"name": "Omar F.", "id": "2120019", "status": "Pending", "time": "-"},
    {"name": "Patricia", "id": "2120020", "status": "Pending", "time": "-"},
    {"name": "Qistina", "id": "2120021", "status": "Pending", "time": "-"},
    {"name": "Ravi J.", "id": "2120022", "status": "Pending", "time": "-"},
    {"name": "Sarah W.", "id": "2120023", "status": "Pending", "time": "-"},
    {"name": "Tan Y.S.", "id": "2120024", "status": "Pending", "time": "-"},
    {"name": "Umar K.", "id": "2120025", "status": "Pending", "time": "-"},
    {"name": "Vivian", "id": "2120026", "status": "Pending", "time": "-"},
    {"name": "Wan A.", "id": "2120027", "status": "Pending", "time": "-"},
    {"name": "Xavier", "id": "2120028", "status": "Pending", "time": "-"},
    {"name": "Yusof I.", "id": "2120029", "status": "Pending", "time": "-"},
    {"name": "Zara B.", "id": "2120030", "status": "Pending", "time": "-"},
    {"name": "Adam F.", "id": "2120031", "status": "Pending", "time": "-"},
    {"name": "Bella C.", "id": "2120032", "status": "Pending", "time": "-"},
    {"name": "Carl J.", "id": "2120033", "status": "Pending", "time": "-"},
    {"name": "Diana", "id": "2120034", "status": "Pending", "time": "-"},
    {"name": "Eric L.", "id": "2120035", "status": "Pending", "time": "-"},
    {"name": "Fatin N.", "id": "2120036", "status": "Pending", "time": "-"},
    {"name": "Gary H.", "id": "2120037", "status": "Pending", "time": "-"},
    {"name": "Hana R.", "id": "2120038", "status": "Pending", "time": "-"},
    {"name": "Imran", "id": "2120039", "status": "Pending", "time": "-"},
    {"name": "Jessica", "id": "2120040", "status": "Pending", "time": "-"},
  ];

  @override
  void initState() {
    super.initState();
    // Sort by ID
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
    _audioPlayer.dispose();
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

  Future<void> _playSound() async {
    if (_soundEnabled) {
      try {
        await _audioPlayer.setVolume(_volume);
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
          s['time'] = '10:15 AM';
          marked = true;
          break;
        }
      }
    });

    if (marked) {
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
          "Live: PITS Sect 2",
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
                  "Principles of IT Security (Sect 2)",
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
        icon: const Icon(Icons.wifi_tethering, color: Colors.white),
        label: const Text(
          "Simulate Scan",
          style: TextStyle(color: Colors.white),
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

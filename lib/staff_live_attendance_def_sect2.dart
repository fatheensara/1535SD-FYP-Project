import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; // REQUIRED PACKAGE
import 'staff_attendance_settings_page.dart';

class StaffLiveAttendanceDefSect2Page extends StatefulWidget {
  const StaffLiveAttendanceDefSect2Page({super.key});

  @override
  State<StaffLiveAttendanceDefSect2Page> createState() =>
      _StaffLiveAttendanceDefSect2PageState();
}

class _StaffLiveAttendanceDefSect2PageState
    extends State<StaffLiveAttendanceDefSect2Page>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Audio Player State
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  double _volume = 0.5;

  // --- MOCK DATA: 42 STUDENTS (DEF Sect 2) ---
  final List<Map<String, dynamic>> _students = [
    {"name": "Aaron Kyle", "id": "2140001", "status": "Pending", "time": "-"},
    {"name": "Brandon L.", "id": "2140002", "status": "Pending", "time": "-"},
    {"name": "Chloe Tan", "id": "2140003", "status": "Pending", "time": "-"},
    {"name": "Derek W.", "id": "2140004", "status": "Pending", "time": "-"},
    {"name": "Elise M.", "id": "2140005", "status": "Pending", "time": "-"},
    {"name": "Felix H.", "id": "2140006", "status": "Pending", "time": "-"},
    {"name": "Gina P.", "id": "2140007", "status": "Pending", "time": "-"},
    {"name": "Harry O.", "id": "2140008", "status": "Pending", "time": "-"},
    {"name": "Ivy C.", "id": "2140009", "status": "Pending", "time": "-"},
    {"name": "Jack N.", "id": "2140010", "status": "Pending", "time": "-"},
    {"name": "Kara Z.", "id": "2140011", "status": "Pending", "time": "-"},
    {"name": "Leo D.", "id": "2140012", "status": "Pending", "time": "-"},
    {"name": "Mina S.", "id": "2140013", "status": "Pending", "time": "-"},
    {"name": "Noah R.", "id": "2140014", "status": "Pending", "time": "-"},
    {"name": "Owen B.", "id": "2140015", "status": "Pending", "time": "-"},
    {"name": "Paula G.", "id": "2140016", "status": "Pending", "time": "-"},
    {"name": "Quincy A.", "id": "2140017", "status": "Pending", "time": "-"},
    {"name": "Ruby F.", "id": "2140018", "status": "Pending", "time": "-"},
    {"name": "Sam E.", "id": "2140019", "status": "Pending", "time": "-"},
    {"name": "Tina V.", "id": "2140020", "status": "Pending", "time": "-"},
    {"name": "Usman K.", "id": "2140021", "status": "Pending", "time": "-"},
    {"name": "Vera L.", "id": "2140022", "status": "Pending", "time": "-"},
    {"name": "Will J.", "id": "2140023", "status": "Pending", "time": "-"},
    {"name": "Xena Y.", "id": "2140024", "status": "Pending", "time": "-"},
    {"name": "Yusuf M.", "id": "2140025", "status": "Pending", "time": "-"},
    {"name": "Zara N.", "id": "2140026", "status": "Pending", "time": "-"},
    {"name": "Alan T.", "id": "2140027", "status": "Pending", "time": "-"},
    {"name": "Bethany", "id": "2140028", "status": "Pending", "time": "-"},
    {"name": "Caleb R.", "id": "2140029", "status": "Pending", "time": "-"},
    {"name": "Donna S.", "id": "2140030", "status": "Pending", "time": "-"},
    {"name": "Evan P.", "id": "2140031", "status": "Pending", "time": "-"},
    {"name": "Faith H.", "id": "2140032", "status": "Pending", "time": "-"},
    {"name": "George W.", "id": "2140033", "status": "Pending", "time": "-"},
    {"name": "Holly K.", "id": "2140034", "status": "Pending", "time": "-"},
    {"name": "Ian J.", "id": "2140035", "status": "Pending", "time": "-"},
    {"name": "Jenny L.", "id": "2140036", "status": "Pending", "time": "-"},
    {"name": "Kyle Z.", "id": "2140037", "status": "Pending", "time": "-"},
    {"name": "Luna X.", "id": "2140038", "status": "Pending", "time": "-"},
    {"name": "Max C.", "id": "2140039", "status": "Pending", "time": "-"},
    {"name": "Nora V.", "id": "2140040", "status": "Pending", "time": "-"},
    {"name": "Oscar B.", "id": "2140041", "status": "Pending", "time": "-"},
    {"name": "Penny N.", "id": "2140042", "status": "Pending", "time": "-"},
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
          s['time'] = '11:45 AM'; // Forensics time
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
          "Live: DEF Sect 2",
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
                  "Digital Evidence Forensics (Sect 2)",
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

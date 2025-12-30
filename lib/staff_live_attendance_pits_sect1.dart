import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'staff_attendance_settings_page.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Audio Player State
  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;
  double _volume = 0.5;

  // --- NFC STATE ---
  bool _isNfcScanning = false; 
  String _nfcStatus = "Ready to Scan";

  // --- MOCK DATA: 38 STUDENTS (NetSec Sect 1) ---
  final List<Map<String, dynamic>> _students = [
    {"name": "Alice Tan", "id": "2130001", "status": "Pending", "time": "-"},
    {"name": "Bryan Lim", "id": "2130002", "status": "Pending", "time": "-"},
    {"name": "Charles K.", "id": "2130003", "status": "Pending", "time": "-"},
    {"name": "Diana R.", "id": "2130004", "status": "Pending", "time": "-"},
    {"name": "Ethan Ho", "id": "2130005", "status": "Pending", "time": "-"},
    {"name": "Fiona G.", "id": "2130006", "status": "Pending", "time": "-"},
    {"name": "George T.", "id": "2130007", "status": "Pending", "time": "-"},
    {"name": "Hannah L.", "id": "2130008", "status": "Pending", "time": "-"},
    {"name": "Ian V.", "id": "2130009", "status": "Pending", "time": "-"},
    {"name": "Jessica M.", "id": "2130010", "status": "Pending", "time": "-"},
    {"name": "Kevin S.", "id": "2130011", "status": "Pending", "time": "-"},
    {"name": "Liam P.", "id": "2130012", "status": "Pending", "time": "-"},
    {"name": "Monica B.", "id": "2130013", "status": "Pending", "time": "-"},
    {"name": "Nathan D.", "id": "2130014", "status": "Pending", "time": "-"},
    {"name": "Oliver Q.", "id": "2130015", "status": "Pending", "time": "-"},
    {"name": "Patricia W.", "id": "2130016", "status": "Pending", "time": "-"},
    {"name": "Quentin Z.", "id": "2130017", "status": "Pending", "time": "-"},
    {"name": "Rachel Y.", "id": "2130018", "status": "Pending", "time": "-"},
    {"name": "Steven X.", "id": "2130019", "status": "Pending", "time": "-"},
    {"name": "Tiffany C.", "id": "2130020", "status": "Pending", "time": "-"},
    {"name": "Umar F.", "id": "2130021", "status": "Pending", "time": "-"},
    {"name": "Victor H.", "id": "2130022", "status": "Pending", "time": "-"},
    {"name": "Wendy J.", "id": "2130023", "status": "Pending", "time": "-"},
    {"name": "Xavier K.", "id": "2130024", "status": "Pending", "time": "-"},
    {"name": "Yvonne N.", "id": "2130025", "status": "Pending", "time": "-"},
    {"name": "Zack M.", "id": "2130026", "status": "Pending", "time": "-"},
    {"name": "Adam O.", "id": "2130027", "status": "Pending", "time": "-"},
    {"name": "Bella P.", "id": "2130028", "status": "Pending", "time": "-"},
    {"name": "Chris Q.", "id": "2130029", "status": "Pending", "time": "-"},
    {"name": "Daisy R.", "id": "2130030", "status": "Pending", "time": "-"},
    {"name": "Edward S.", "id": "2130031", "status": "Pending", "time": "-"},
    {"name": "Felicia T.", "id": "2130032", "status": "Pending", "time": "-"},
    {"name": "Greg U.", "id": "2130033", "status": "Pending", "time": "-"},
    {"name": "Helen V.", "id": "2130034", "status": "Pending", "time": "-"},
    {"name": "Ivan W.", "id": "2130035", "status": "Pending", "time": "-"},
    {"name": "Jenny X.", "id": "2130036", "status": "Pending", "time": "-"},
    {"name": "Karl Y.", "id": "2130037", "status": "Pending", "time": "-"},
    {"name": "Lily Z.", "id": "2130038", "status": "Pending", "time": "-"},
  ];

  @override
  void initState() {
    super.initState();
    _students.sort((a, b) => a['id'].compareTo(b['id']));
    _audioPlayer = AudioPlayer();
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
    NfcManager.instance.stopSession();
    super.dispose();
  }

  // --- NFC LOGIC START ---
  void _toggleNfc() async {
    if (_isNfcScanning) {
      // Stop Scanning
      await NfcManager.instance.stopSession();
      setState(() {
        _isNfcScanning = false;
        _nfcStatus = "Scanning Stopped";
      });
    } else {
      // Start Scanning
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        _showSnackBar("NFC not available on this device", Colors.red);
        return;
      }

      setState(() {
        _isNfcScanning = true;
        _nfcStatus = "Hold card to phone...";
      });

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Extract UID
          String? uid = _extractUid(tag);
          if (uid != null) {
            _handleScannedTag(uid);
          }
        },
      );
    }
  }

  String? _extractUid(NfcTag tag) {
    final data = tag.data;
    List<int>? idBytes;
    if (data.containsKey('isodep')) {
      idBytes = List<int>.from(data['isodep']['identifier']);
    } else if (data.containsKey('nfca')) {
      idBytes = List<int>.from(data['nfca']['identifier']);
    } else if (data.containsKey('mifareclassic')) {
      idBytes = List<int>.from(data['mifareclassic']['identifier']);
    }

    if (idBytes == null) return null;
    return idBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
  }

  void _handleScannedTag(String uid) async {
    // 1. Play "Beep" Sound
    if (_soundEnabled) {
      try {
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play(AssetSource('beep.mp3'));
      } catch (e) {
      }
    }

    _showSnackBar("Checking database...", Colors.blue);

    try {
      // 2. LOOK UP USER IN FIRESTORE
      final querySnapshot = await FirebaseFirestore.instance
          .collection('student_registrations')
          .where('physicalCardUid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar("❌ Card not registered in system.", Colors.red);
        return;
      }

      // 3. GET STUDENT DATA FROM DATABASE
      final studentData = querySnapshot.docs.first.data();
      final String scannedName = studentData['name'] ?? "Unknown";
      final String scannedId = studentData['studentId'] ?? "0000000";

      // 4. FIND & UPDATE (OR ADD NEW)
      bool foundInClass = false;

      setState(() {
        // A. Try to find them in the existing list
        for (var s in _students) {
          if (s['id'].toString() == scannedId) {
            s['status'] = 'Present';
            s['time'] = TimeOfDay.now().format(context);
            foundInClass = true;
            break;
          }
        }

        // B. If NOT found, add them dynamically (FYP Feature)
        if (!foundInClass) {
          _students.insert(0, { 
            "name": scannedName,
            "id": scannedId,
            "status": "Present",
            "time": TimeOfDay.now().format(context),
          });
        }
      });

      // 5. SUCCESS MESSAGE
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (foundInClass) {
        _showSnackBar("✅ $scannedName marked PRESENT!", Colors.green);
      } else {
        _showSnackBar("➕ $scannedName added to class & marked PRESENT!", Colors.blue);
      }

    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    }
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
  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
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
          s['time'] = '02:15 PM'; 
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
          "Live: NetSec Sect 1",
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
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
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
                  "Network Security (Sect 1)",
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
        onPressed: _toggleNfc,
        backgroundColor: _isNfcScanning ? Colors.red : const Color(0xFF4A00E0),
        icon: Icon(_isNfcScanning ? Icons.stop_circle_outlined : Icons.nfc, color: Colors.white),
        label: Text(
          _isNfcScanning ? "Stop Scanning" : "Start NFC Scan",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNfcIcon(Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Icon(Icons.nfc_rounded, size: 50, color: color),
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

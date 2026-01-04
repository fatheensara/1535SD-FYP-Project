import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:intl/intl.dart'; // REQUIRED for DateFormat & TimeOfDay
import 'dart:typed_data';

// Assuming this file exists in your project, otherwise remove/replace.
import 'staff_attendance_settings_page.dart';

class StaffLiveAttendanceDefSect2Page extends StatefulWidget {
  // Added sessionId to accept it from the previous page (or hardcode it if needed)
  final String sessionId; 

  const StaffLiveAttendanceDefSect2Page({
    super.key, 
    this.sessionId = "default_session_id" // Default value to prevent errors if not passed
  });

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

  // --- NFC STATE ---
  bool _isNfcScanning = false;
  String _nfcStatus = "Ready to Scan";
  bool _demoMode = true;
  int _demoStep = 0;

  // --- MOCK DATA ---
   final List<Map<String, dynamic>> _students = [
    {"name": "Fatheen Sara Sofiah", "id": "2218114", "status": "Pending", "time": "-"},
    {"name": "Nur Farisya Adila", "id": "2212186", "status": "Pending", "time": "-"},
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
    NfcManager.instance.stopSession();
    super.dispose();
  }

  // --- NFC LOGIC ---
  void _toggleNfc() async {
    if (_isNfcScanning) {
      await NfcManager.instance.stopSession();
      setState(() {
        _isNfcScanning = false;
        _nfcStatus = "Scanning Stopped";
      });
    } else {
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
    return idBytes
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }

  void _handleScannedTag(String uid) async {
    // 1. Play "Beep" Sound
    if (_soundEnabled) {
      try {
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play(AssetSource('beep.mp3'));
      } catch (e) {
        // ignore audio errors
      }
    }

    try {
      // 2. LOOK UP USER IN FIRESTORE
      final querySnapshot = await FirebaseFirestore.instance
          .collection('student_registrations')
          .where('physicalCardUid', isEqualTo: uid)
          .limit(1)
          .get();

      String scannedName;
      String scannedId;

      if (querySnapshot.docs.isEmpty) {
        // --- STRICT MODE CHECK (For Examiner) ---
        if (!_demoMode) {
           _showSnackBar("Error: Card not registered in system.", Colors.red);
           // You can play an error sound here if you want
           // await _audioPlayer.play(AssetSource('error.mp3'));
           return; // STOP HERE! Do not mark present.
        }

        // --- DEMO MODE (Fake it) ---
        // Pick the first "Pending" student to mark present
        final pendingStudent = _students.firstWhere(
          (s) => s['status'] == 'Pending',
          orElse: () => {}, 
        );

        if (pendingStudent.isNotEmpty) {
          scannedName = pendingStudent['name'];
          scannedId = pendingStudent['id'];
        } else {
          scannedName = "Extra Demo Student";
          scannedId = "9999999";
        }
      } else {
        // NORMAL BEHAVIOR (Card Found)
        final studentData = querySnapshot.docs.first.data();
        scannedName = studentData['name'] ?? "Unknown";
        scannedId = studentData['studentId'] ?? "0000000";
      }

      // 3. UPDATE UI
      bool foundInClass = false;
      setState(() {
        for (var s in _students) {
          if (s['id'].toString() == scannedId) {
            s['status'] = 'Present';
            s['time'] = TimeOfDay.now().format(context);
            foundInClass = true;
            break;
          }
        }
        if (!foundInClass) {
          _students.insert(0, {
            "name": scannedName,
            "id": scannedId,
            "status": "Present",
            "time": TimeOfDay.now().format(context),
          });
        }
      });

      // 4. SUCCESS MESSAGE
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar("✅ $scannedName marked PRESENT!", Colors.green);

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
    _showSnackBar("All attendance data has been reset.", Colors.black87);
  }

  // --- MANUAL OVERRIDE LOGIC ---
  Future<void> _markManually(String docId, String name, String matric) async {
    // 1. Update Local State (Immediate UI Feedback)
    setState(() {
      for (var s in _students) {
        if (s['id'] == matric) {
          s['status'] = 'Present';
          s['time'] = TimeOfDay.now().format(context); // Update Time
          break;
        }
      }
    });

    // 2. Play Sound (Optional)
    if (_soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('manual_success.mp3')); 
      } catch (e) {
        debugPrint("Audio Error: $e");
      }
    }

    // 3. Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(widget.sessionId)
          .collection('students')
          .doc(matric)
          .set({
        'name': name,
        'matric': matric,
        'status': 'Present',
        'time': DateFormat('hh:mm a').format(DateTime.now()),
        'method': 'Manual',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showSnackBar("✅ Manually marked $name as PRESENT", Colors.green);
    } catch (e) {
      _showSnackBar("Error updating DB: $e", Colors.red);
    }
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
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.white),
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
          // HIDDEN DEMO BUTTON
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.transparent),
            onPressed: () {
              _markManually("doc_id_123", "Demo Student Alice", "2140001");
            },
          ),
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
                GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _demoMode = !_demoMode;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_demoMode ? "✨ Demo Mode ON (Accept All)" : "Strict Mode ON (Show Errors)"),
                        backgroundColor: Colors.black87,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    "Digital Evidence Forensics (Sect 2)",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
        backgroundColor:
            _isNfcScanning ? Colors.red : const Color(0xFF4A00E0),
        icon: Icon(_isNfcScanning ? Icons.stop_circle_outlined : Icons.nfc,
            color: Colors.white),
        label: Text(
          _isNfcScanning ? "Stop Scanning" : "Start NFC Scan",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

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
    // Extract variables correctly from the map
    String status = student['status'];
    bool isPresent = status == 'Present';
    String matric = student['id'];
    String name = student['name'];
    String docId = student['docId'] ?? matric; // Fallback

    Color statusColor;
    IconData statusIcon;

    // Determine Colors based on status
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
        // Add Green Border if Present
        border: isPresent
            ? Border.all(color: Colors.green.withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: isPresent ? Colors.green[50] : const Color(0xFFF6F8FA),
          child: isPresent
              ? const Icon(Icons.check, color: Colors.green, size: 20)
              : Text(
                  name[0],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A00E0),
                  ),
                ),
        ),
        title: Text(
          name,
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
              matric,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
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
            // Popup Menu for Override
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'mark_present') {
                  _markManually(docId, name, matric);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'mark_present',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Text('Force Mark Present'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'cancel',
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
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
                        student['time'] = TimeOfDay.now().format(context);
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

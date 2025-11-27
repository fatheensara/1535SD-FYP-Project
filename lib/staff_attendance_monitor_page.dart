import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'staff_attendance_settings_page.dart'; // Ensure this file exists

class StaffAttendanceMonitorPage extends StatefulWidget {
  final String className;
  const StaffAttendanceMonitorPage({super.key, required this.className});

  @override
  State<StaffAttendanceMonitorPage> createState() =>
      _StaffAttendanceMonitorPageState();
}

class _StaffAttendanceMonitorPageState extends State<StaffAttendanceMonitorPage>
    with SingleTickerProviderStateMixin {
  // --- MOCK STUDENT DATA ---
  final List<Map<String, dynamic>> _students = [
    {
      "name": "Nurul Iman",
      "id": "2115542",
      "status": "Present",
      "time": "10:05 AM",
      "file": null,
    },
    {
      "name": "Ahmad Ali",
      "id": "2119982",
      "status": "Present",
      "time": "10:10 AM",
      "file": null,
    },
    {
      "name": "Sarah Lee",
      "id": "2113341",
      "status": "Excused",
      "time": "-",
      "file": "MC_Sarah_Lee.pdf",
    },
    {
      "name": "John Doe",
      "id": "2118876",
      "status": "Late",
      "time": "10:45 AM",
      "file": null,
    },
    {
      "name": "Muthu Kumar",
      "id": "2114421",
      "status": "Absent",
      "time": "-",
      "file": null,
    },
    {
      "name": "Siti Aminah",
      "id": "2116653",
      "status": "Pending",
      "time": "-",
      "file": null,
    },
    {
      "name": "Michael Chen",
      "id": "2117788",
      "status": "Present",
      "time": "10:02 AM",
      "file": null,
    },
    {
      "name": "Jessica Wong",
      "id": "2112233",
      "status": "Present",
      "time": "10:08 AM",
      "file": null,
    },
    {
      "name": "Daniel Tan",
      "id": "2119911",
      "status": "Pending",
      "time": "-",
      "file": null,
    },
    {
      "name": "Rachel Green",
      "id": "2114455",
      "status": "Late",
      "time": "10:50 AM",
      "file": null,
    },
    {
      "name": "Omar Farooq",
      "id": "2116677",
      "status": "Absent",
      "time": "-",
      "file": null,
    },
    {
      "name": "Lisa Manoban",
      "id": "2118899",
      "status": "Present",
      "time": "10:15 AM",
      "file": null,
    },
    {
      "name": "Kevin Hart",
      "id": "2110022",
      "status": "Present",
      "time": "10:12 AM",
      "file": null,
    },
    {
      "name": "Priya Sharma",
      "id": "2113344",
      "status": "Excused",
      "time": "-",
      "file": "Letter_Priya.pdf",
    },
    {
      "name": "Tom Holland",
      "id": "2115566",
      "status": "Pending",
      "time": "-",
      "file": null,
    },
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // --- LOGIC: RESET SESSION ---
  void _resetAttendanceData() {
    setState(() {
      for (var student in _students) {
        if (student['status'] != 'Excused') {
          student['status'] = 'Pending';
          student['time'] = '-';
        }
      }
    });
  }

  // --- SIMULATE NFC READ ---
  void _simulateNfcRead() {
    int index = _students.indexWhere(
      (s) => s['status'] == 'Pending' || s['status'] == 'Absent',
    );

    if (index != -1) {
      setState(() {
        _students[index]['status'] = 'Present';
        _students[index]['time'] = TimeOfDay.now().format(context);
        var student = _students.removeAt(index);
        _students.insert(0, student);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_students[0]['name']} successfully checked in!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All students present!"),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students
        .where((s) => s['status'] == 'Present' || s['status'] == 'Late')
        .length;
    int totalCount = _students.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          // --- HEADER & NFC RECEIVER AREA ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, Colors.purple.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Attendance Monitor",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffAttendanceSettingsPage(
                              onReset: _resetAttendanceData,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pulsing NFC Icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.15),
                      // ignore: deprecated_member_use
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wifi_tethering,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Scanning for Student Cards...",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                Text(
                  widget.className,
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Live Stats Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$presentCount / $totalCount Students Present",
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- STUDENT LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return _buildStudentTile(student);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateNfcRead,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.nfc),
        label: const Text("Simulate Card Tap"),
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    String status = student['status'];
    Color statusColor;
    IconData statusIcon;

    // Determine visual style based on status
    switch (status) {
      case 'Present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_filled;
        break;
      case 'Absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'Excused':
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        break;
      default: // Pending
        statusColor = Colors.grey;
        statusIcon = Icons.circle_outlined;
    }

    // Determine Document Label based on Status
    String docLabel = "Supporting Document";
    if (status == 'Absent') {
      docLabel = "Medical Certificate (MC)";
    } else if (status == 'Excused') {
      docLabel = "Excuse Letter";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          student['name'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          student['id'],
          style: GoogleFonts.lato(color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              status.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (status == 'Present' || status == 'Late')
              Text(
                student['time'],
                style: GoogleFonts.lato(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
        children: [
          // 1. DYNAMIC FILE VIEWER
          // Shows specific label (MC vs Letter) based on status
          if (student['file'] != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 24,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docLabel, // UPDATED LABEL
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            student['file'],
                            style: GoogleFonts.lato(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Opening $docLabel...")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("View"),
                    ),
                  ],
                ),
              ),
            ),

          // 2. STATUS OVERRIDE BUTTONS (Expanded to 4 options)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8.0, // Gap between adjacent chips
              runSpacing: 8.0, // Gap between lines
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildActionBtn(
                  "Present",
                  Colors.green,
                  () => setState(() => student['status'] = "Present"),
                ),
                _buildActionBtn(
                  "Late",
                  Colors.orange,
                  () => setState(() => student['status'] = "Late"),
                ),
                _buildActionBtn(
                  "Absent",
                  Colors.red,
                  () => setState(() => student['status'] = "Absent"),
                ),
                _buildActionBtn(
                  "Excused",
                  Colors.blue,
                  () => setState(() => student['status'] = "Excused"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // Slightly smaller padding to fit more buttons
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

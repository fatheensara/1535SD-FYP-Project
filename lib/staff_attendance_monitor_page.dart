import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'staff_attendance_settings_page.dart';

class StaffAttendanceMonitorPage extends StatefulWidget {
  final String className;
  const StaffAttendanceMonitorPage({super.key, required this.className});

  @override
  State<StaffAttendanceMonitorPage> createState() =>
      _StaffAttendanceMonitorPageState();
}

class _StaffAttendanceMonitorPageState extends State<StaffAttendanceMonitorPage>
    with SingleTickerProviderStateMixin {
  // Mock Data (Same as before, abbreviated for brevity)
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
  ];

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _resetAttendanceData() {
    setState(() {
      for (var s in _students) {
        if (s['status'] != 'Excused') {
          s['status'] = 'Pending';
          s['time'] = '-';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _students
        .where((s) => s['status'] == 'Present' || s['status'] == 'Late')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29), // Dark background
      body: Column(
        children: [
          // RADAR HEADER
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, const Color(0xFF0F0C29)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Animated Pulse Rings
              ...List.generate(3, (index) {
                return FadeTransition(
                  opacity: Tween(begin: 0.5, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Interval(index * 0.2, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.5).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Interval(
                          index * 0.2,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // ignore: deprecated_member_use
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: Colors.purpleAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Central Hub
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.purpleAccent.withOpacity(0.2),
                          blurRadius: 20,
                        ),
                      ],
                      // ignore: deprecated_member_use
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.wifi_tethering,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Scanning...",
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.purpleAccent,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    widget.className,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Nav Buttons
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StaffAttendanceSettingsPage(
                        onReset: _resetAttendanceData,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // STATS BAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Live Count",
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
                Text(
                  "$presentCount / ${_students.length}",
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return _buildStudentTile(_students[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    String status = student['status'];
    Color statusColor = status == 'Present'
        ? Colors.greenAccent
        : (status == 'Absent' ? Colors.redAccent : Colors.orangeAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(),
        ),
        child: ExpansionTile(
          // ignore: deprecated_member_use
          leading: CircleAvatar(
            // ignore: deprecated_member_use
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(Icons.person, color: statusColor, size: 20),
          ),
          title: Text(
            student['name'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            student['id'],
            style: GoogleFonts.sourceCodePro(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            // ignore: deprecated_member_use
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.poppins(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statusBtn(
                    "Present",
                    Colors.green,
                    () => setState(() => student['status'] = 'Present'),
                  ),
                  _statusBtn(
                    "Late",
                    Colors.orange,
                    () => setState(() => student['status'] = 'Late'),
                  ),
                  _statusBtn(
                    "Absent",
                    Colors.red,
                    () => setState(() => student['status'] = 'Absent'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(color: color, fontSize: 12),
        ),
      ),
    );
  }
}

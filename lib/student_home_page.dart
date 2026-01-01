// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'welcome.dart';
import 'fade_page_route.dart';
import 'student_mark_attendance_page.dart';
import 'student_history_page.dart';
import 'student_alerts_page.dart';
import 'student_profile_page.dart';
import 'screens/my_virtual_card.dart';
import 'widgets/fade_slide_transition.dart';
import 'services/notifications_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage>
    with SingleTickerProviderStateMixin {
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

  DateTime _selectedDate = DateTime.now();
  int _currentIndex = 0;

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  // --- SMART QUICK SCAN LOGIC (REAL USER) ---
  Future<void> _handleQuickScan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack("Please log in first.", isError: true);
      return;
    }

    final now = DateTime.now();
    final String currentDay = DateFormat('EEEE').format(now);

    // 1. Fetch THIS student's record using their email
    // (Assumes 'student_registrations' stores the 'email' field)
    final snapshot = await FirebaseFirestore.instance
        .collection('student_registrations')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      _showSnack(
        "Student profile not found. Please contact admin.",
        isError: true,
      );
      return;
    }

    final data = snapshot.docs.first.data();

    // 2. Get their registered classes
    List<Map<String, dynamic>> allClasses = [];
    if (data['registeredClasses'] != null) {
      for (var c in data['registeredClasses']) {
        allClasses.add(c as Map<String, dynamic>);
      }
    }

    // 3. Check if they have a class TODAY
    final todaysClasses = allClasses
        .where((c) => (c['day'] ?? "").toString().trim() == currentDay)
        .toList();

    if (todaysClasses.isEmpty) {
      _showSnack("You have no classes scheduled for today ($currentDay).");
      return;
    }

    // 4. Proceed to Scan
    // (If multiple classes, we pick the first one for the Quick Button)
    final classToScan = todaysClasses.first;

    Navigator.push(
      context,
      FadePageRoute(
        page: MarkAttendancePage(
          className: classToScan['subject'] ?? "Unknown Class",
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade800 : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildScheduleView(),
              const StudentHistoryPage(),
              const StudentAlertsPage(),
              const StudentProfilePage(),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildScanFloatingButton(),
    );
  }

  Widget _buildScheduleView() {
    String selectedDayName = DateFormat('EEEE').format(_selectedDate);
    String fullDate = DateFormat('MMMM d, y').format(_selectedDate);
    bool isToday = CalendarUtils.isSameDay(_selectedDate, DateTime.now());

    // Get Current User
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // --- HEADER SECTION ---
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A00E0).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- DYNAMIC NAME FETCHING ---
                        if (user != null)
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('student_registrations')
                                .where('email', isEqualTo: user.email)
                                .limit(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              String displayName = "Student"; // Default
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                final data =
                                    snapshot.data!.docs.first.data()
                                        as Map<String, dynamic>;
                                // Assuming 'name' or 'fullName' is the field key
                                displayName =
                                    data['name'] ??
                                    data['fullName'] ??
                                    "Student";
                              }

                              return Text(
                                "Welcome Back, $displayName",
                                style: GoogleFonts.lato(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            "Welcome,",
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        Text(
                          "My Schedule",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            FadePageRoute(page: const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // DATE NAVIGATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeDate(-1),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          selectedDayName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          fullDate,
                          style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!isToday)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = DateTime.now()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.replay,
                        size: 16,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Return to Today",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // --- FETCH SCHEDULE FOR LOGGED IN USER ---
          if (user == null)
            const Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text("Please log in to view schedule."),
            )
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('student_registrations')
                  .where(
                    'email',
                    isEqualTo: user.email,
                  ) // Filter by logged in email
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: _buildEmptyState(message: "Profile not found"),
                  );
                }

                final data =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;

                List<Map<String, dynamic>> allClasses = [];
                if (data['registeredClasses'] != null) {
                  for (var c in data['registeredClasses']) {
                    allClasses.add(c as Map<String, dynamic>);
                  }
                }

                // Filter classes for the selected day
                final dailyClasses = allClasses.where((cls) {
                  final classDay = cls['day']?.toString() ?? "";
                  return classDay.trim().toLowerCase() ==
                      selectedDayName.toLowerCase();
                }).toList();

                if (dailyClasses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Icon(
                          Icons.weekend_rounded,
                          size: 60,
                          color: Colors.purple.shade200,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No classes on $selectedDayName",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dailyClasses.length,
                  itemBuilder: (context, index) {
                    final cls = dailyClasses[index];

                    return FadeSlideTransition(
                      index: index,
                      child: _LiveClassCard(
                        subject: cls['subject'] ?? "Unknown",
                        section: cls['section'] ?? "1",
                        defaultTime: cls['time'] ?? "TBA",
                        defaultLecturer: cls['lecturer'] ?? "TBA",
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Widgets: _buildScanFloatingButton, _buildFloatingNavBar, _buildNavItem, _buildEmptyState ---

  Widget _buildScanFloatingButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 45),
      height: 70,
      width: 70,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _handleQuickScan();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const CircleBorder(),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A00E0).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
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
          _buildNavItem(icon: Icons.grid_view_rounded, index: 0, label: "Home"),
          _buildNavItem(
            icon: Icons.history_edu_rounded,
            index: 1,
            label: "History",
          ),
          const SizedBox(width: 50),
          _buildNavItem(
            icon: Icons.notifications_none_rounded,
            index: 2,
            label: "Alerts",
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            index: 3,
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.purple.shade700 : Colors.grey.shade400,
              size: 26,
            ),
          ),
          if (isSelected)
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String message = "No Classes"}) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.weekend_rounded, size: 60, color: Colors.purple.shade200),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class CalendarUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _LiveClassCard extends StatelessWidget {
  final String subject;
  final String section;
  final String defaultTime;
  final String defaultLecturer;

  const _LiveClassCard({
    required this.subject,
    required this.section,
    required this.defaultTime,
    required this.defaultLecturer,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('class_schedule')
          .doc(subject)
          .snapshots(),
      builder: (context, snapshot) {
        String status = "Physical";
        String venue = "Default Venue";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final sections = List.from(data['sections'] ?? []);

          final sectionData = sections.firstWhere(
            (s) => s['section'].toString() == section,
            orElse: () => null,
          );

          if (sectionData != null) {
            status = sectionData['status'] ?? "Physical";
            venue = sectionData['venue'] ?? "Default Venue";
          }
        }

        Color cardColor = Colors.white;
        Color statusBadgeColor = Colors.green;
        IconData typeIcon = Icons.menu_book;
        bool isAttention = false;

        if (status == 'Online') {
          cardColor = Colors.blue.shade50;
          statusBadgeColor = Colors.blue;
          typeIcon = Icons.videocam;
          isAttention = true;
        } else if (status == 'Quiz') {
          cardColor = Colors.purple.shade50;
          statusBadgeColor = Colors.purple;
          typeIcon = Icons.assignment;
          isAttention = true;
        } else if (status == 'Postponed') {
          cardColor = Colors.orange.shade50;
          statusBadgeColor = Colors.orange;
          typeIcon = Icons.warning;
          isAttention = true;
        } else if (status == 'Cancelled') {
          cardColor = Colors.red.shade50;
          statusBadgeColor = Colors.red;
          typeIcon = Icons.block;
          isAttention = true;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade900.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: isAttention
                ? Border.all(color: statusBadgeColor.withOpacity(0.3))
                : Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    typeIcon,
                    size: 100,
                    color: statusBadgeColor.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBadgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 14,
                                  color: statusBadgeColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  defaultTime,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusBadgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAttention)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusBadgeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        subject,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        defaultLecturer,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            venue,
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (status != 'Cancelled')
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              FadePageRoute(
                                page: MarkAttendancePage(className: subject),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Scan Attendance",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

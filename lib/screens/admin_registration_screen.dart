import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../admin_signin.dart';
import '../fade_page_route.dart';
import '../services/notifications_page.dart';
import 'admin_student_list.dart';
import 'admin_notifications_page.dart';
import 'admin_class_dashboard.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();
  final _cardUidController = TextEditingController();

  // State Variables
  String? _selectedCourse;
  bool _isScanning = false;
  bool _isRegistering = false;
  String _statusMessage = "";
  String? _selectedSubject;
  String? _selectedSection;
  String? _selectedTime;
  String? _selectedDay;
  String? _selectedLecturer;

  // ---------------------------------------------------------
  // 1. ADMIN NFC SCANNER
  // ---------------------------------------------------------
  void _scanCardForAdmin() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ NFC not available on this device")));
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = "Hold card against phone...";
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final data = tag.data;
            List<int>? idBytes;

            if (data.containsKey('isodep')) {
              idBytes = List<int>.from(data['isodep']['identifier']);
            } else if (data.containsKey('nfca')) {
              idBytes = List<int>.from(data['nfca']['identifier']);
            } else if (data.containsKey('mifareclassic')) {
              idBytes = List<int>.from(data['mifareclassic']['identifier']);
            }

            if (idBytes == null) {
              await NfcManager.instance.stopSession(errorMessage: "Failed");
              return;
            }

            String scannedUid = idBytes
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();

            await NfcManager.instance.stopSession();

            if (mounted) {
              setState(() {
                _cardUidController.text = scannedUid;
                _isScanning = false;
                _statusMessage = "✅ Captured UID: $scannedUid";
              });
            }
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessage: "Error");
            setState(() => _isScanning = false);
          }
        },
      );
    } catch (e) {
      setState(() => _isScanning = false);
    }
  }

  // ---------------------------------------------------------
  // 2. DATABASE ACTIONS
  // ---------------------------------------------------------
  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isRegistering = true);

    try {
      final uid = _cardUidController.text.trim();

      final check = await FirebaseFirestore.instance
          .collection('student_registrations')
          .where('physicalCardUid', isEqualTo: uid)
          .get();

      if (check.docs.isNotEmpty) {
        setState(() => _statusMessage = "❌ This card is already registered!");
        return;
      }

      DocumentReference newStudentRef = await FirebaseFirestore.instance
          .collection('student_registrations')
          .add({
        'name': _nameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'course': _courseController.text.trim(),
        'enrolledSubject': _selectedSubject,
        'section': _selectedSection,
        'classTime': _selectedTime,
        'classDay': _selectedDay,
        'lecturer': _selectedLecturer,
        'registeredClasses': _selectedSubject != null
            ? [
                {
                  'subject': _selectedSubject,
                  'section': _selectedSection,
                  'time': _selectedTime,
                  'day': _selectedDay,
                  'lecturer': _selectedLecturer,
                }
              ]
            : [],
        'physicalCardUid': uid,
        'isActive': true,
        'deviceId': null,
        'registeredAt': DateTime.now().toIso8601String(),
        'registeredBy': 'admin',
      });

      if (_selectedSubject != null) {
        await newStudentRef.collection('notifications').add({
          'title': "Course Registration Successful",
          'message': "Welcome! You are now registered for $_selectedSubject.",
          'type': "Success",
          'time': DateTime.now().toIso8601String(),
          'isRead': false,
        });
      }

      setState(() {
        _statusMessage = "✅ Student Registered Successfully";
        _nameController.clear();
        _studentIdController.clear();
        _courseController.clear();
        _selectedCourse = null;
        _cardUidController.clear();
        _selectedSubject = null;
        _selectedSection = null;
        _selectedTime = null;
        _selectedDay = null;
        _selectedLecturer = null;
      });

      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      setState(() => _statusMessage = "❌ Error: $e");
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  // ---------------------------------------------------------
  // 3. UI BUILDER (MODERN DASHBOARD THEME)
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Soft Blue-Grey Background
      body: CustomScrollView(
        slivers: [
          // --- APP BAR ---
          SliverAppBar(
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF4F7FE),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black87, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () => Navigator.pushReplacement(
                      context, FadePageRoute(page: const AdminSignInPage())),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
              title: Text(
                "Admin Dashboard",
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- QUICK ACTIONS GRID ---
                  Text("Quick Actions",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 15),
                  _buildDashboardGrid(),

                  const SizedBox(height: 30),

                  // --- REGISTRATION FORM ---
                  Text("New Student Entry",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
                  const SizedBox(height: 15),
                  _buildRegistrationCard(),
                  
                  const SizedBox(height: 50), // Bottom Padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- GRID FOR DASHBOARD BUTTONS ---
  Widget _buildDashboardGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5, // Wider cards
      children: [
        _buildGridButton(
          label: "Manage Classes",
          icon: Icons.dashboard_customize,
          color: Colors.blue.shade700,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AdminClassDashboard())),
        ),
        _buildGridButton(
          label: "HOD Alerts",
          icon: Icons.notifications_active,
          color: Colors.orange.shade800,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminNotificationsPage())),
        ),
        _buildGridButton(
          label: "Manage Subjects",
          icon: Icons.edit_calendar,
          color: Colors.teal.shade700,
          onTap: _addNewSubjectDialog,
        ),
        _buildGridButton(
          label: "Student List",
          icon: Icons.people_alt,
          color: Colors.purple.shade700,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AdminStudentList())),
        ),
      ],
    );
  }

  Widget _buildGridButton(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // --- MAIN FORM CARD ---
  Widget _buildRegistrationCard() {
    const List<String> courseOptions = [
      "Computer Science",
      "Information Technology"
    ];
    final bool isValidCourse =
        _selectedCourse != null && courseOptions.contains(_selectedCourse);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. NFC Section
            _buildSectionHeader("Identity Card"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildModernTextField(
                    controller: _cardUidController,
                    label: "Card UID",
                    icon: Icons.nfc,
                    readOnly: true, // Prevent manual typing if desired
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  width: 56,
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanCardForAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cardUidController.text.isNotEmpty
                          ? Colors.green
                          : const Color(0xFF2D3748),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(
                            _cardUidController.text.isNotEmpty
                                ? Icons.check
                                : Icons.qr_code_scanner,
                            color: Colors.white),
                  ),
                ),
              ],
            ),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_statusMessage,
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _statusMessage.contains("✅")
                          ? Colors.green
                          : Colors.red)),
            ],

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 25),

            // 2. Personal Details
            _buildSectionHeader("Student Details"),
            const SizedBox(height: 15),
            _buildModernTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline),
            const SizedBox(height: 15),
            _buildModernTextField(
                controller: _studentIdController,
                label: "Matric ID",
                icon: Icons.badge_outlined),
            const SizedBox(height: 15),

            // 3. Course Selection
            DropdownButtonFormField<String>(
              value: isValidCourse ? _selectedCourse : null,
              dropdownColor: Colors.white,
              decoration: _inputDecoration("Program / Course", Icons.school_outlined),
              style: GoogleFonts.poppins(color: Colors.black87),
              items: courseOptions.map((course) {
                return DropdownMenuItem(value: course, child: Text(course));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCourse = val;
                  _courseController.text = val ?? "";
                });
              },
              validator: (v) => v == null ? "Please select a course" : null,
            ),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 25),

            // 4. Class Enrollment
            _buildSectionHeader("Class Enrollment"),
            const SizedBox(height: 15),
            _buildClassSelection(),

            const SizedBox(height: 30),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isRegistering ? null : _registerStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF319795), // Teal
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                  shadowColor: const Color(0xFF319795).withOpacity(0.4),
                ),
                child: _isRegistering
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "COMPLETE REGISTRATION",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: GoogleFonts.poppins(color: Colors.black87),
      decoration: _inputDecoration(label, icon),
      validator: (v) => v!.isEmpty ? "$label Required" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
      filled: true,
      fillColor: const Color(0xFFF7FAFC), // Very light grey
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      
      // ✅ Corrected: borderSide used instead of border in OutlineInputBorder
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: BorderSide.none
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: BorderSide.none
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF319795), width: 1.5), // ✅ Fixed here
      ),
    );
  }

  // --- REUSED WIDGETS (Keep Logic Same, Just Style Update) ---

  Widget _buildClassSelection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('class_schedule').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        final docs = snapshot.data!.docs;
        List<String> subjects = docs.map((doc) => doc.id).toList();

        // Reset if selection invalid
        if (_selectedSubject != null && !subjects.contains(_selectedSubject)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedSubject = null;
              _selectedSection = null;
            });
          });
        }

        return Column(
          children: [
            // Subject Dropdown with Delete Button inside
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: subjects.contains(_selectedSubject)
                        ? _selectedSubject
                        : null,
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration("Subject", Icons.class_),
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                          value: subject,
                          child:
                              Text(subject, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSubject = val;
                        _selectedSection = null;
                        _selectedTime = null;
                        _selectedDay = null;
                        _selectedLecturer = null;
                      });
                    },
                    validator: (v) =>
                        v == null ? "Please select a subject" : null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: () {
                      if (_selectedSubject == null) return;
                      _confirmDeleteSubject(context);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Section Dropdown
            if (_selectedSubject != null && subjects.contains(_selectedSubject))
              Builder(
                builder: (context) {
                  final selectedDoc =
                      docs.firstWhere((d) => d.id == _selectedSubject);
                  final data = selectedDoc.data() as Map<String, dynamic>;
                  final sectionsList = List.from(data['sections'] ?? []);

                  String? currentDropdownValue;
                  if (_selectedSection != null && _selectedDay != null) {
                    final combinedKey = "${_selectedSection}_${_selectedDay}";
                    if (sectionsList.any(
                        (s) => "${s['section']}_${s['day']}" == combinedKey)) {
                      currentDropdownValue = combinedKey;
                    }
                  }

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: currentDropdownValue,
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration("Section & Time", Icons.layers),
                    items:
                        sectionsList.map<DropdownMenuItem<String>>((secData) {
                      final section = secData['section'].toString();
                      final day = secData['day'].toString();
                      final time = secData['time'].toString();
                      final uniqueKey = "${section}_$day";

                      return DropdownMenuItem<String>(
                        value: uniqueKey,
                        child: Text("Sec $section • $day • $time",
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      final secData = sectionsList.firstWhere(
                          (e) => "${e['section']}_${e['day']}" == val);
                      setState(() {
                        _selectedSection = secData['section'];
                        _selectedDay = secData['day'];
                        _selectedTime = secData['time'];
                        _selectedLecturer = secData['lecturer'];
                      });
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSubject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Subject?",
            style: TextStyle(color: Colors.black87)),
        content: Text("Delete '$_selectedSubject'? This cannot be undone.",
            style: const TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('class_schedule')
                  .doc(_selectedSubject)
                  .delete();
              Navigator.pop(ctx);
              setState(() => _selectedSubject = null);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Subject Deleted")));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG FOR ADDING SUBJECTS ---
  Future<void> _addNewSubjectDialog() async {
    final subjectCtrl = TextEditingController();
    final sectionCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final lecturerCtrl = TextEditingController();
    List<String> selectedDays = [];
    final List<String> weekDays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday"
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Add New Class",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogField(subjectCtrl, "Subject Name (e.g. CSCI 101)"),
                const SizedBox(height: 10),
                _buildDialogField(sectionCtrl, "Section (e.g. 1)"),
                const SizedBox(height: 10),
                _buildDialogField(timeCtrl, "Time (e.g. 10:00 AM - 12:00 PM)"),
                const SizedBox(height: 10),
                _buildDialogField(lecturerCtrl, "Lecturer Name"),
                const SizedBox(height: 15),
                Text("Select Days:",
                    style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: weekDays.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setDialogState(() {
                          if (selected) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.teal.shade100,
                      labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.teal.shade900 : Colors.black87),
                      checkmarkColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: isSelected
                                  ? Colors.teal
                                  : Colors.grey.shade300)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel",
                    style: TextStyle(color: Colors.grey.shade600))),
            ElevatedButton(
              onPressed: () async {
                if (subjectCtrl.text.isEmpty ||
                    sectionCtrl.text.isEmpty ||
                    selectedDays.isEmpty) return;

                List<Map<String, dynamic>> newEntries = selectedDays.map((day) {
                  return {
                    'section': sectionCtrl.text.trim(),
                    'time': timeCtrl.text.trim(),
                    'day': day,
                    'lecturer': lecturerCtrl.text.trim(),
                  };
                }).toList();

                final docRef = FirebaseFirestore.instance
                    .collection('class_schedule')
                    .doc(subjectCtrl.text.trim());
                await docRef.set({
                  'sections': FieldValue.arrayUnion(newEntries)
                }, SetOptions(merge: true));

                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("✅ Added ${selectedDays.length} sessions!")));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Save Class"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}
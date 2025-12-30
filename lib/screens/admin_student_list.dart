import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AdminStudentList extends StatefulWidget {
  const AdminStudentList({super.key});

  @override
  State<AdminStudentList> createState() => _AdminStudentListState();
}

class _AdminStudentListState extends State<AdminStudentList> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Computer Science", "Information Technology", "Unclaimed Cards"];
  String _sortBy = "Date";
  bool _isAscending = true;

  // --- BULK SELECTION STATE ---
  final Set<String> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  // --- HELPER: SEND NOTIFICATION ---
  Future<void> _sendNotification(String studentUid, String title, String message, String type) async {
    if (studentUid.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('student_registrations')
          .doc(studentUid)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type, // 'Info', 'Warning', 'Success'
        'time': DateTime.now().toIso8601String(),
        'isRead': false,
      });
      print("✅ Notification sent to $studentUid");
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (_selectedIds.contains(docId)) {
        _selectedIds.remove(docId);
      } else {
        _selectedIds.add(docId);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: Text("Delete $count Students?", style: const TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete All", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final batch = FirebaseFirestore.instance.batch();
      for (var id in _selectedIds) {
        final docRef = FirebaseFirestore.instance.collection('student_registrations').doc(id);
        batch.delete(docRef);
      }
      await batch.commit();

      setState(() {
        _selectedIds.clear();
      });

      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selected students deleted")));
    }
  }

  void _exportToCSV(List<QueryDocumentSnapshot> docs) {
    String csvData = "Name,Student ID,Course,Status,Registered Date\n";

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = data['name'] ?? "Unknown";
      final id = data['studentId'] ?? "N/A";
      final course = data['course'] ?? "N/A";
      final isClaimed = data['deviceId'] != null ? "Active" : "Unclaimed";
      final date = data['registeredAt'] ?? "";

      csvData += "$name,$id,$course,$isClaimed,$date\n";
    }

    Clipboard.setData(ClipboardData(text: csvData));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ CSV Copied to Clipboard!")));
  }

  // --- SINGLE ACTIONS ---
  Future<void> _deleteStudent(String docId, String studentName) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Delete Student?", style: TextStyle(color: Colors.white)),
        content: Text("Remove $studentName?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('student_registrations').doc(docId).delete();
    }
  }

  // --- EDIT & ADD CLASS LOGIC ---
  Future<void> _editStudent(String docId, Map<String, dynamic> data) async {
    final nameCtrl = TextEditingController(text: data['name']);
    final idCtrl = TextEditingController(text: data['studentId']);
    
    // FETCH EXISTING CLASSES
    List<dynamic> existingClasses = data['registeredClasses'] ?? [];
    if (existingClasses.isEmpty && data['enrolledSubject'] != null) {
      existingClasses.add({
        'subject': data['enrolledSubject'],
        'section': data['section'],
        'time': data['classTime'],
        'day': data['classDay'],
        'lecturer': data['lecturer']
      });
    }

    String? newSubject;
    String? newSection;
    String? newTime;
    String? newDay;
    String? newLecturer;

    await showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('class_schedule').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));

            final docs = snapshot.data!.docs;
            final List<String> subjects = docs.map((doc) => doc.id).toList();

            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF203A43),
                  title: const Text("Manage Classes", style: TextStyle(color: Colors.white)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STUDENT DETAILS
                        TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.white70))),
                        TextField(controller: idCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Student ID", labelStyle: TextStyle(color: Colors.white70))),
                        const SizedBox(height: 20),

                        // EXISTING CLASSES LIST
                        const Text("Current Classes:", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        if (existingClasses.isEmpty)
                          const Text("No classes enrolled.", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))
                        else
                          ...existingClasses.map((cls) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cls['subject'] ?? "Unknown", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text("Sec ${cls['section']} • ${cls['day']} • ${cls['time']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  // --- REMOVE CLASS BUTTON ---
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                    onPressed: () async {
                                      // 1. Remove from DB
                                      await FirebaseFirestore.instance.collection('student_registrations').doc(docId).update({
                                        'registeredClasses': FieldValue.arrayRemove([cls])
                                      });
                                      
                                      // 2. Clear main fields if it was the primary subject
                                      if (data['enrolledSubject'] == cls['subject']) {
                                        await FirebaseFirestore.instance.collection('student_registrations').doc(docId).update({
                                          'enrolledSubject': null, 'section': null, 'classTime': null
                                        });
                                      }

                                      // 3. SEND NOTIFICATION (Added this missing part)
                                      await _sendNotification(
                                        docId,
                                        "Class Dropped",
                                        "You have been removed from ${cls['subject']}.",
                                        "Warning"
                                      );

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Class Removed & Alert Sent!")));
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),

                        // ADD NEW CLASS SECTION
                        const Text("Add New Class:", style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: subjects.contains(newSubject) ? newSubject : null,
                                dropdownColor: const Color(0xFF0F2027),
                                hint: const Text("Select Subject", style: TextStyle(color: Colors.white54)),
                                items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (val) => setStateDialog(() { newSubject = val; newSection = null; }),
                              ),
                            ),
                          ],
                        ),
                        
                        if (newSubject != null)
                          Builder(builder: (context) {
                            final selectedDoc = docs.firstWhere((d) => d.id == newSubject);
                            final subjectData = selectedDoc.data() as Map<String, dynamic>;
                            final sectionsList = List.from(subjectData['sections'] ?? []);
                            
                            String? currentDropdownValue;
                            if (newSection != null && newDay != null) {
                              final combinedKey = "${newSection}_$newDay";
                              if (sectionsList.any((s) => "${s['section']}_${s['day']}" == combinedKey)) {
                                currentDropdownValue = combinedKey;
                              }
                            }
                            
                            return DropdownButtonFormField<String>(
                              value: currentDropdownValue,
                              dropdownColor: const Color(0xFF0F2027),
                              hint: const Text("Select Section", style: TextStyle(color: Colors.white54)),
                              items: sectionsList.map<DropdownMenuItem<String>>((secData) {
                                final section = secData['section'].toString();
                                final day = secData['day'].toString();
                                final uniqueKey = "${section}_$day";
                                return DropdownMenuItem(
                                  value: uniqueKey,
                                  child: Text("Sec $section • $day", style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                final secData = sectionsList.firstWhere((e) => "${e['section']}_${e['day']}" == val);
                                setStateDialog(() {
                                  newSection = secData['section'];
                                  newTime = secData['time'];
                                  newDay = secData['day'];
                                  newLecturer = secData['lecturer'];
                                });
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                    
                    // --- SAVE & ADD BUTTON ---
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
                      onPressed: () async {
                        // 1. Update Basic Info
                        await FirebaseFirestore.instance.collection('student_registrations').doc(docId).update({
                          'name': nameCtrl.text.trim(),
                          'studentId': idCtrl.text.trim(),
                        });

                        // 2. Add New Class (if selected)
                        if (newSubject != null && newSection != null) {
                          final newClassMap = {
                            'subject': newSubject,
                            'section': newSection,
                            'time': newTime,
                            'day': newDay,
                            'lecturer': newLecturer,
                          };

                          await FirebaseFirestore.instance.collection('student_registrations').doc(docId).update({
                            'registeredClasses': FieldValue.arrayUnion([newClassMap]),
                            'enrolledSubject': newSubject,
                            'section': newSection, 
                          });

                          // 3. SEND NOTIFICATION (For Adding)
                          await _sendNotification(
                            docId, 
                            "New Class Enrolled", 
                            "You have been successfully enrolled in $newSubject (Section $newSection).", 
                            "Success"
                          );
                          
                          if (mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Class Added to List & Alert Sent!")));
                        } else {
                           if (mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text("Save & Add Class"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _resetDevice(String docId, String studentName) async {
      await FirebaseFirestore.instance.collection('student_registrations').doc(docId).update({'deviceId': null});
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Device unbound")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: Colors.teal.shade900,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => setState(() => _selectedIds.clear()),
              ),
              title: Text("${_selectedIds.length} Selected", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: _deleteSelected,
                )
              ],
            )
          : AppBar(
              title: Text("Student Database", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: Colors.tealAccent),
                  onSelected: (value) {
                    setState(() {
                      if (_sortBy == value) {
                        _isAscending = !_isAscending;
                      } else {
                        _sortBy = value;
                        _isAscending = true;
                      }
                    });
                  },
                  color: const Color(0xFF1B3B48),
                  itemBuilder: (context) => [
                    _buildPopupItem("Date", Icons.calendar_today),
                    _buildPopupItem("Name", Icons.sort_by_alpha),
                    _buildPopupItem("ID", Icons.numbers),
                  ],
                ),
              ],
            ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('student_registrations').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));

                final allDocs = snapshot.data!.docs;

                // Stats
                int totalStudents = allDocs.length;
                int activeCount = allDocs.where((doc) => (doc.data() as Map<String, dynamic>)['deviceId'] != null).length;
                int unclaimedCount = totalStudents - activeCount;

                // Filter & Sort
                var filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final id = (data['studentId'] ?? "").toString().toLowerCase();
                  final course = (data['course'] ?? "");
                  final isClaimed = data['deviceId'] != null;

                  bool matchesSearch = name.contains(_searchQuery) || id.contains(_searchQuery);
                  bool matchesFilter = true;
                  if (_selectedCategory == "Unclaimed Cards") {
                    matchesFilter = !isClaimed;
                  } else if (_selectedCategory != "All") {
                    matchesFilter = course == _selectedCategory;
                  }
                  return matchesSearch && matchesFilter;
                }).toList();

                filteredDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  int result = 0;
                  if (_sortBy == "Name") {
                    result = (dataA['name'] ?? "").toString().compareTo((dataB['name'] ?? "").toString());
                  } else if (_sortBy == "ID") {
                    result = (dataA['studentId'] ?? "").toString().compareTo((dataB['studentId'] ?? "").toString());
                  } else {
                    result = (dataA['registeredAt'] ?? "").toString().compareTo((dataB['registeredAt'] ?? "").toString());
                  }
                  return _isAscending ? result : -result;
                });

                return Column(
                  children: [
                    _buildStatsCard(totalStudents, activeCount, unclaimedCount),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search Name or ID...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),

                    _buildFilterChips(),

                    Expanded(
                      child: filteredDocs.isEmpty
                          ? Center(child: Text("No students found.", style: TextStyle(color: Colors.white.withOpacity(0.5))))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final isClaimed = data['deviceId'] != null;
                                final isSelected = _selectedIds.contains(doc.id);

                                return Dismissible(
                                  key: Key(doc.id),
                                  direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                                  ),
                                  confirmDismiss: (direction) async {
                                    await _deleteStudent(doc.id, data['name']);
                                    return false;
                                  },
                                  child: GestureDetector(
                                    onLongPress: () => _toggleSelection(doc.id),
                                    onTap: () {
                                      if (_isSelectionMode) {
                                        _toggleSelection(doc.id);
                                      } 
                                    },
                                    child: Card(
                                      color: isSelected ? Colors.teal.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: isSelected ? const BorderSide(color: Colors.tealAccent, width: 2) : BorderSide.none,
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isClaimed ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                              child: isSelected 
                                                ? const Icon(Icons.check, color: Colors.white)
                                                : Icon(Icons.person, color: isClaimed ? Colors.greenAccent : Colors.orangeAccent),
                                            ),
                                            title: Text(data['name'] ?? "Unknown", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${data['studentId']} • ${data['course']}", style: const TextStyle(color: Colors.white70)),
                                                if (data['enrolledSubject'] != null) ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.teal.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.teal.withOpacity(0.3)),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.book, size: 12, color: Colors.tealAccent),
                                                        const SizedBox(width: 5),
                                                        Flexible(
                                                          child: Text(
                                                            "${data['enrolledSubject']} (Sec ${data['section']})",
                                                            style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                          if (!_isSelectionMode) ...[
                                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                _buildActionBtn(Icons.edit, Colors.blue, "Edit", () => _editStudent(doc.id, data)),
                                                _buildActionBtn(Icons.phonelink_erase, Colors.orange, "Unbind", () => _resetDevice(doc.id, data['name'])),
                                                _buildActionBtn(Icons.delete, Colors.red, "Delete", () => _deleteStudent(doc.id, data['name'])),
                                              ],
                                            )
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final snapshot = await FirebaseFirestore.instance.collection('student_registrations').get();
          _exportToCSV(snapshot.docs);
        },
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.copy),
        label: const Text("Export CSV"),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 16),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (bool selected) => setState(() => _selectedCategory = category),
              backgroundColor: const Color(0xFF1B3B48),
              selectedColor: Colors.tealAccent.withOpacity(0.2),
              checkmarkColor: Colors.tealAccent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.tealAccent : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.tealAccent.withOpacity(0.5) : Colors.white10)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCard(int total, int active, int unclaimed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.tealAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSingleStat("Total", total.toString(), Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSingleStat("Active", active.toString(), Colors.greenAccent),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSingleStat("Unclaimed", unclaimed.toString(), Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildSingleStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon) {
    bool isSelected = _sortBy == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.tealAccent : Colors.white70, size: 20),
          const SizedBox(width: 10),
          Text(value, style: TextStyle(color: isSelected ? Colors.tealAccent : Colors.white)),
          if (isSelected) ...[
            const Spacer(),
            Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: Colors.tealAccent),
          ]
        ],
      ),
    );
  }
}
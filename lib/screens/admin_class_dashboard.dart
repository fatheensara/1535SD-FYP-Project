import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminClassDashboard extends StatefulWidget {
  const AdminClassDashboard({super.key});

  @override
  State<AdminClassDashboard> createState() => _AdminClassDashboardState();
}

class _AdminClassDashboardState extends State<AdminClassDashboard> {
  String _searchQuery = "";

  // --- HELPERS ---

  Future<int> _getStudentCount(String subject, String section) async {
    // Simplified count for UI responsiveness
    // In a real app, store 'enrolledCount' directly in the class document to avoid heavy queries
    final allStudents = await FirebaseFirestore.instance.collection('student_registrations').get();
    int count = 0;
    for (var doc in allStudents.docs) {
      final classes = List.from(doc.data()['registeredClasses'] ?? []);
      if (classes.any((c) => c['subject'] == subject && c['section'] == section)) {
        count++;
      }
    }
    return count;
  }

  Future<void> _updateClassStatus(String docId, List<dynamic> allSections, int sectionIndex, Map<String, dynamic> currentSection, String newStatus, String newVenue) async {
    currentSection['status'] = newStatus;
    currentSection['venue'] = newVenue;
    allSections[sectionIndex] = currentSection;

    await FirebaseFirestore.instance
        .collection('class_schedule')
        .doc(docId)
        .update({'sections': allSections});

    // Notify HOD logic (Same as before)
    if (newStatus != "Physical" || newVenue != "Default") {
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': "Class Change Alert",
        'message': "$docId (Sec ${currentSection['section']}) changed to $newStatus.",
        'type': newStatus == 'Cancelled' ? 'Urgent' : 'Info',
        'time': DateTime.now().toIso8601String(),
        'isRead': false,
        'target': 'HOD'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE), // Soft Blue-Grey
      appBar: AppBar(
        title: Text("Class Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Subject Code (e.g. CSCI)...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F7FE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('class_schedule').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter Logic
          final allDocs = snapshot.data!.docs.where((doc) {
            return doc.id.toLowerCase().contains(_searchQuery);
          }).toList();

          if (allDocs.isEmpty) {
            return Center(child: Text("No classes found", style: GoogleFonts.poppins(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allDocs.length,
            itemBuilder: (context, index) {
              final doc = allDocs[index];
              final sections = List<Map<String, dynamic>>.from(doc['sections'] ?? []);
              
              return _buildExpandableSubjectCard(doc.id, sections);
            },
          );
        },
      ),
    );
  }

  // --- NEW EXPANDABLE CARD DESIGN ---
  Widget _buildExpandableSubjectCard(String subjectName, List<Map<String, dynamic>> sections) {
    // Calculate Summary Stats
    int totalSections = sections.length;
    bool hasIssues = sections.any((s) => (s['status'] ?? "Physical") != "Physical");

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hasIssues ? Colors.orange.shade50 : Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.book, 
            color: hasIssues ? Colors.orange : Colors.blue
          ),
        ),
        title: Text(
          subjectName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "$totalSections Sections Enrolled",
          style: GoogleFonts.lato(color: Colors.grey.shade600),
        ),
        trailing: hasIssues 
          ? const Icon(Icons.warning_amber_rounded, color: Colors.orange)
          : const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        
        children: sections.asMap().entries.map((entry) {
          return _buildSectionRow(subjectName, subjectName, sections, entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildSectionRow(String docId, String subjectName, List<dynamic> allSections, int index, Map<String, dynamic> data) {
    String status = data['status'] ?? "Physical";
    Color statusColor;
    
    switch (status) {
      case 'Online': statusColor = Colors.blue; break;
      case 'Cancelled': statusColor = Colors.red; break;
      case 'Postponed': statusColor = Colors.orange; break;
      default: statusColor = Colors.green;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Section Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text("SEC", style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey)),
                Text("${data['section']}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${data['day']} • ${data['time']}", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(data['lecturer'] ?? "TBA", style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 12)),
                
                // Student Count
                FutureBuilder<int>(
                  future: _getStudentCount(subjectName, data['section']),
                  builder: (context, snap) => Text(
                    "${snap.data ?? '-'} Students", 
                    style: GoogleFonts.lato(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ),

          // Status & Edit
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showUpdateDialog(docId, allSections, index, data),
                child: const Icon(Icons.edit_note, color: Colors.grey),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showUpdateDialog(String docId, List<dynamic> allSections, int index, Map<String, dynamic> data) {
    final venueCtrl = TextEditingController(text: data['venue'] ?? "");
    String selectedStatus = data['status'] ?? "Physical";
    List<String> statuses = ["Physical", "Online", "Quiz", "Postponed", "Cancelled"];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Update Class"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: venueCtrl,
                decoration: const InputDecoration(labelText: "Venue / Link", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _updateClassStatus(docId, allSections, index, data, selectedStatus, venueCtrl.text);
                if (context.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Class Updated")));
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
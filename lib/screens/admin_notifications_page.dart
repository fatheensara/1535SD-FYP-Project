import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart'; // REQUIRED: Add rxdart: ^0.27.7 to pubspec.yaml

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  // --- STREAM MERGER ---
  // Combines Staff Broadcasts AND Admin Specific Alerts
  Stream<List<QueryDocumentSnapshot>> _getMergedStream() {
    // Stream 1: Staff Broadcasts (Filtered for Admin)
    var broadcasts = FirebaseFirestore.instance
        .collection('notifications')
        .where('visibleTo', arrayContains: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    // Stream 2: Admin Specific Alerts (Your original collection)
    var adminAlerts = FirebaseFirestore.instance
        .collection('admin_notifications')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    // Merge & Sort
    return Rx.combineLatest2(broadcasts, adminAlerts, (List<QueryDocumentSnapshot> a, List<QueryDocumentSnapshot> b) {
      var allDocs = [...a, ...b];
      // Sort by time (Newest first)
      allDocs.sort((doc1, doc2) {
        DateTime t1 = _parseTime(doc1.data() as Map<String, dynamic>);
        DateTime t2 = _parseTime(doc2.data() as Map<String, dynamic>);
        return t2.compareTo(t1);
      });
      return allDocs;
    });
  }

  // Helper to safely parse time from different formats
  DateTime _parseTime(Map<String, dynamic> data) {
    if (data['timestamp'] != null) return (data['timestamp'] as Timestamp).toDate();
    if (data['time'] != null) return DateTime.tryParse(data['time']) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F9),
      appBar: AppBar(
        title: Text("HOD Notifications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _getMergedStream(), // ✅ Using the merged stream
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          if (snapshot.data!.isEmpty) {
            return Center(child: Text("No alerts for HOD", style: GoogleFonts.poppins(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data![index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Handle Data Mapping (Broadcast uses 'body', Admin uses 'message')
              String title = data['title'] ?? "Notification";
              String message = data['body'] ?? data['message'] ?? "";
              String type = data['type'] ?? "Info";
              String sender = data['sender'] ?? "System";
              DateTime time = _parseTime(data);

              bool isUrgent = type == 'Urgent' || type == 'Warning' || type == 'Cancel';

              return Card(
                elevation: 0,
                color: isUrgent ? Colors.red.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isUrgent ? BorderSide(color: Colors.red.shade200) : BorderSide.none
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isUrgent ? Colors.red : Colors.blue,
                    child: Icon(isUrgent ? Icons.warning : Icons.info, color: Colors.white),
                  ),
                  title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(message, style: GoogleFonts.lato(color: Colors.black87)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("From: $sender", style: GoogleFonts.lato(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                          Text(
                            DateFormat('MMM d, h:mm a').format(time),
                            style: GoogleFonts.lato(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                    onPressed: () => doc.reference.delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
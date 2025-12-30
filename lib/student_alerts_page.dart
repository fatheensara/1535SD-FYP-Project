import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class StudentAlertsPage extends StatefulWidget {
  const StudentAlertsPage({super.key});

  @override
  State<StudentAlertsPage> createState() => _StudentAlertsPageState();
}

class _StudentAlertsPageState extends State<StudentAlertsPage> {
  // --- 1. GET STUDENT ID ---
  Future<String?> _getStudentDocId() async {
    final query = await FirebaseFirestore.instance
        .collection('student_registrations')
        .orderBy('registeredAt', descending: true)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) return query.docs.first.id;
    return null; 
  }

  // --- 2. MERGED STREAM (Personal + Broadcasts) ---
  Stream<List<Map<String, dynamic>>> _getNotificationsStream(String studentDocId) {
    
    // Stream A: Personal Alerts (from Admin)
    var personalStream = FirebaseFirestore.instance
        .collection('student_registrations')
        .doc(studentDocId)
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                'id': doc.id,
                'isBroadcast': false,
                'ref': doc.reference,
                'sender': 'Admin',
                // Normalize time
                'parsedTime': _parseTime(data['time']), 
              };
            }).toList());

    // Stream B: Global Broadcasts (from Lecturer)
    var broadcastStream = FirebaseFirestore.instance
        .collection('notifications')
        .where('visibleTo', arrayContains: 'student') // ✅ Filter Logic
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                'id': doc.id,
                'message': data['body'], // Map 'body' to 'message'
                'isBroadcast': true,
                'ref': doc.reference,
                // Normalize time
                'parsedTime': _parseTime(data['timestamp']),
              };
            }).toList());

    // Merge both streams
    return Rx.combineLatest2(personalStream, broadcastStream, 
      (List<Map<String, dynamic>> personal, List<Map<String, dynamic>> global) {
        var merged = [...personal, ...global];
        // Sort by time (Newest first)
        merged.sort((a, b) => b['parsedTime'].compareTo(a['parsedTime']));
        return merged;
      }
    );
  }

  // Helper to safely parse time
  DateTime _parseTime(dynamic timeData) {
    if (timeData is Timestamp) return timeData.toDate();
    if (timeData is String) return DateTime.tryParse(timeData) ?? DateTime.now();
    return DateTime.now();
  }

  // --- 3. DELETE LOGIC ---
  void _deleteNotification(Map<String, dynamic> item) async {
    if (item['isBroadcast'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Global broadcasts cannot be deleted")),
      );
      return; // Cannot delete global message
    }
    
    // Delete personal message
    if (item['ref'] != null) {
      await (item['ref'] as DocumentReference).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification removed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: FutureBuilder<String?>(
        future: _getStudentDocId(),
        builder: (context, idSnapshot) {
          if (idSnapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }

          if (!idSnapshot.hasData) {
            return const Center(child: Text("Student Profile Not Found"));
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getNotificationsStream(idSnapshot.data!), // Use the merged stream
            builder: (context, snapshot) {
              
              if (snapshot.hasError) {
                // ✅ DEBUGGING: Print error to console to see if Index is missing
                print("Stream Error: ${snapshot.error}");
                return Center(child: Text("Error loading alerts: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              var notifications = snapshot.data!;
              var newAlerts = notifications.where((n) => n['isRead'] == false).toList();
              
              // If broadcasts don't have 'isRead', treat as unread or read based on logic
              // For simplicity, we treat them as unread if 'isRead' is missing.

              return Column(
                children: [
                  _buildHeader(newAlerts.length),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(notifications[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGETS ---
  
  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Notifications", style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(count > 0 ? "$count New Alerts" : "All caught up", style: GoogleFonts.lato(color: Colors.white70)),
            ],
          ),
          const Icon(Icons.notifications_active, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text("No Notifications", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    Color color = Colors.blue;
    IconData icon = Icons.info;
    
    String type = (item['type'] ?? 'Info').toString();
    
    if (type == 'Warning' || type == 'Cancel') {
      color = Colors.red;
      icon = Icons.warning_amber_rounded;
    } else if (type == 'Success' || type.contains('Approved')) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (type == 'Room' || type == 'Broadcast') {
      color = Colors.orange;
      icon = Icons.campaign;
    }

    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(item),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? 'Notification', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item['message'] ?? '', style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("From: ${item['sender'] ?? 'System'}", style: GoogleFonts.lato(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic)),
                      Text(DateFormat('MMM d, h:mm a').format(item['parsedTime']), style: GoogleFonts.lato(color: Colors.grey[400], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

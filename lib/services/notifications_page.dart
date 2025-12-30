import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  // 'student' or 'admin' - passed from the main app
  final String userRole; 

  const NotificationsPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            // ✅ Only fetch notifications meant for this user role
            .where('visibleTo', arrayContains: userRole) 
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _buildNotificationCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text("No notifications yet", style: GoogleFonts.lato(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    // Icon logic
    IconData icon = Icons.notifications;
    Color color = Colors.blue;
    if (data['title'].toString().contains("Cancelled")) {
      icon = Icons.cancel;
      color = Colors.red;
    } else if (data['title'].toString().contains("Venue")) {
      icon = Icons.location_on;
      color = Colors.orange;
    }

    // Time formatting
    String timeStr = "Just now";
    if (data['timestamp'] != null) {
      DateTime dt = (data['timestamp'] as Timestamp).toDate();
      timeStr = DateFormat('MMM d, h:mm a').format(dt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(data['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15))),
                    Text(timeStr, style: GoogleFonts.lato(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(data['body'], style: GoogleFonts.lato(color: Colors.grey.shade700, fontSize: 13)),
                if (data['sender'] != null) ...[
                  const SizedBox(height: 8),
                  Text("From: ${data['sender']}", style: GoogleFonts.lato(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentScanActivityPage extends StatelessWidget {
  const StudentScanActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text("Scan Activity", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. NICE HEADER (From Demo File) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.history_toggle_off, color: Colors.blue.shade700, size: 24),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Activity",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      "Real-time attendance logs",
                      style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. REAL DATA STREAM ---
          Expanded(
            child: user == null
                ? const Center(child: Text("Please login first"))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('attendance_records')
                        .where('studentUid', isEqualTo: user.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      final records = snapshot.data!.docs;
                      
                      if (records.isEmpty) {
                         return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 10),
                                Text("No scans yet", style: GoogleFonts.poppins(color: Colors.grey)),
                              ],
                            ),
                         );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final data = records[index].data() as Map<String, dynamic>;
                          
                          // Convert Firestore Data to UI Data
                          return _buildTimelineItem(
                            subject: data['courseName'] ?? "Unknown Class",
                            status: data['status'] ?? "Present",
                            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                            method: data['method'] ?? "NFC",
                            isLast: index == records.length - 1,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- 3. BEAUTIFUL CARD DESIGN (From Demo File) ---
  Widget _buildTimelineItem({
    required String subject,
    required String status,
    required DateTime timestamp,
    required String method,
    required bool isLast,
  }) {
    bool isSuccess = status == 'Present' || status == 'Success';
    bool isLate = status == 'Late';
    
    // Color Logic
    Color statusColor;
    IconData statusIcon;
    
    if (isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isLate) {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. LEFT: TIME COLUMN
          SizedBox(
            width: 55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('d MMM').format(timestamp),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  textAlign: TextAlign.right,
                ),
                Text(
                  DateFormat('h:mm a').format(timestamp),
                  style: GoogleFonts.lato(fontSize: 11, color: Colors.grey.shade600),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // B. MIDDLE: TIMELINE LINE
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // The Dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // The Line
                Expanded(
                  child: isLast ? Container() : Container(width: 2, color: Colors.grey.shade300),
                ),
              ],
            ),
          ),

          // C. RIGHT: THE CARD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isSuccess
                      ? Border.all(color: Colors.transparent)
                      : Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Subject & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              subject,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  status.toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Details Row
                      Row(
                        children: [
                          Icon(
                            method == 'NFC' ? Icons.nfc : Icons.qr_code,
                            size: 14, 
                            color: Colors.grey.shade400
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Verified via $method",
                            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

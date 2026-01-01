import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml: intl: ^0.18.1

class StudentNotificationsPage extends StatelessWidget {
  // In a real app, pass the logged-in student's name or ID here
  final String currentStudentName;

  const StudentNotificationsPage({
    super.key,
    required this.currentStudentName, // e.g., "Aaron Lim"
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. LISTEN TO FIRESTORE REAL-TIME
        stream: FirebaseFirestore.instance
            .collection('student_notifications')
            .where(
              'studentName',
              isEqualTo: currentStudentName,
            ) // Filter for this student
            .orderBy('timestamp', descending: true) // Newest first
            .snapshots(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No notifications yet",
                    style: GoogleFonts.lato(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 2. DISPLAY DATA
          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String id = docs[index].id;
              final bool isRead = data['isRead'] ?? false;
              final Timestamp? ts = data['timestamp'];
              final String time = ts != null
                  ? DateFormat('dd MMM, hh:mm a').format(ts.toDate())
                  : "Just now";

              // Color coding based on type
              final bool isWarning = data['type'] == 'Warning';
              final Color accentColor = isWarning ? Colors.orange : Colors.red;
              final IconData icon = isWarning
                  ? Icons.warning_amber_rounded
                  : Icons.block;

              return Dismissible(
                key: Key(id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Allow student to delete notification
                  FirebaseFirestore.instance
                      .collection('student_notifications')
                      .doc(id)
                      .delete();
                },
                child: GestureDetector(
                  onTap: () {
                    // Mark as read when clicked
                    if (!isRead) {
                      FirebaseFirestore.instance
                          .collection('student_notifications')
                          .doc(id)
                          .update({'isRead': true});
                    }
                    _showDetailDialog(context, data, accentColor, icon);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.white
                          // ignore: deprecated_member_use
                          : accentColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: isRead
                          ? Border.all(color: Colors.grey.shade200)
                          // ignore: deprecated_member_use
                          : Border.all(
                              // ignore: deprecated_member_use
                              color: accentColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: accentColor, size: 24),
                        ),
                        const SizedBox(width: 15),

                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['title'] ?? "Notification",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "NEW",
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['message'] ?? "",
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                time,
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Helper: Show Full Details on Tap ---
  void _showDetailDialog(
    BuildContext context,
    Map<String, dynamic> data,
    Color color,
    IconData icon,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data['title'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Course: ${data['courseCode']}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data['message'],
              style: GoogleFonts.lato(fontSize: 15, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

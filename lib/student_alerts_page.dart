import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentAlertsPage extends StatefulWidget {
  const StudentAlertsPage({super.key});

  @override
  State<StudentAlertsPage> createState() => _StudentAlertsPageState();
}

class _StudentAlertsPageState extends State<StudentAlertsPage> {
  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": "1",
      "title": "Attendance Warning",
      "message":
          "Your attendance in Cryptography (CSCI 4333) has dropped to 82%. Please attend the next class.",
      "time": DateTime.now().subtract(const Duration(minutes: 45)),
      "type": "Warning", // Warning, Info, Success
      "isRead": false,
    },
    {
      "id": "2",
      "title": "Class Cancelled",
      "message":
          "Dr. Nurul Liyana has cancelled tomorrow's Computation class due to urgent matters.",
      "time": DateTime.now().subtract(const Duration(hours: 3)),
      "type": "Urgent",
      "isRead": false,
    },
    {
      "id": "3",
      "title": "Assignment Due Soon",
      "message":
          "Reminder: Digital Forensics Report is due this Friday at 11:59 PM.",
      "time": DateTime.now().subtract(const Duration(days: 1)),
      "type": "Info",
      "isRead": true,
    },
    {
      "id": "4",
      "title": "Submission Successful",
      "message":
          "Your MC submission for 24th Nov has been approved by the admin.",
      "time": DateTime.now().subtract(const Duration(days: 2)),
      "type": "Success",
      "isRead": true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read")),
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = _notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          // --- 1. GRADIENT HEADER ---
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
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
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
                        Text(
                          "Notifications",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          unreadCount > 0
                              ? "You have $unreadCount unread alerts"
                              : "You're all caught up!",
                          style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // "Mark Read" Button
                    if (unreadCount > 0)
                      InkWell(
                        onTap: _markAllAsRead,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.done_all,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. NOTIFICATION LIST ---
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    // Padding bottom 120 ensures content clears the floating nav bar
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return _buildNotificationItem(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            "No New Notifications",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "We'll let you know when something happens.",
            style: GoogleFonts.lato(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> item, int index) {
    // Determine Styles based on Type
    Color iconColor;
    Color bgColor;
    IconData iconData;

    switch (item['type']) {
      case 'Warning':
      case 'Urgent':
        iconColor = Colors.red;
        bgColor = Colors.red.shade50;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'Success':
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        iconData = Icons.check_circle_outline;
        break;
      default: // Info
        iconColor = Colors.blue;
        bgColor = Colors.blue.shade50;
        iconData = Icons.info_outline;
    }

    bool isUnread = item['isRead'] == false;

    // SWIPE TO DISMISS WIDGET
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Notification removed"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                // Logic to undo could go here (requires complex state management)
              },
            ),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isUnread
              // ignore: deprecated_member_use
              ? Border.all(color: iconColor.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                item['isRead'] = true; // Mark as read on tap
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Bubble
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "NEW",
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'],
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatTime(item['time']),
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
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }
}

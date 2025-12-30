import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  // --- METHOD 1: SEND BROADCAST (For StaffBroadcastPage) ---
  static Future<void> sendBroadcast({
    required String title,
    required String message,
    required String type, 
    required List<String> courseCodes, 
    required String senderName,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'body': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'audience': 'broadcast',
        'targetCourses': courseCodes,
        'visibleTo': ['student', 'admin'], 
        'sender': senderName,
        'isRead': false,
      });
    } catch (e) {
      print("Error sending broadcast: $e");
      throw e;
    }
  }

  // --- METHOD 2: ADMIN ADDS STUDENT (For Admin App) ---
  static Future<void> requestStudentRegistration({
    required String studentName,
    required String studentId,
    required String subjectCode,
    required String section,
    required String lecturerId,
  }) async {
    await FirebaseFirestore.instance.collection('lecturer_requests').add({
      'type': 'registration',
      'studentName': studentName,
      'studentId': studentId,
      'subject': subjectCode,
      'section': section,
      'lecturerId': lecturerId,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- METHOD 3: PROCESS REQUEST (For StaffStudentRequestsPage) ---
  // ✅ This is the method your error says is missing.
  static Future<void> processRegistrationRequest({
    required String requestId,
    required String studentName,
    required String subject,
    required bool isApproved,
  }) async {
    try {
      // 1. Update the Request Status
      await FirebaseFirestore.instance
          .collection('lecturer_requests')
          .doc(requestId)
          .update({
        'status': isApproved ? 'Approved' : 'Rejected',
      });

      // 2. Send Notification to Student & Admin
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Registration Update: $subject',
        'body': isApproved
            ? "✅ $studentName has been ACCEPTED into $subject."
            : "❌ $studentName's registration for $subject was REJECTED.",
        'type': 'status_update',
        'timestamp': FieldValue.serverTimestamp(),
        'audience': 'targeted',
        'visibleTo': ['student', 'admin'],
        'targetStudent': studentName,
        'sender': 'System',
        'isRead': false,
      });
    } catch (e) {
      print("Error processing request: $e");
      throw e;
    }
  }
}
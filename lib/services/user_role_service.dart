import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleService {
  static Future<String?> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return 'student'; // Default role
    } catch (e) {
      print('Error getting user role: $e');
      return 'student'; // Default role on error
    }
  }
}
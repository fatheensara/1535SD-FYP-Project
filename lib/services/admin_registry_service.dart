import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegistryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> isAdminPreRegistered(String matricNumber) async {
    try {
      final doc = await _firestore
          .collection('pre_registered_admins')
          .doc(matricNumber)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking admin pre-registration: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getPreRegisteredAdmin(String matricNumber) async {
    try {
      final doc = await _firestore
          .collection('pre_registered_admins')
          .doc(matricNumber)
          .get();
      return doc.data();
    } catch (e) {
      print('Error getting admin details: $e');
      return null;
    }
  }

  static Future<bool> createAdminUser(String uid, String email, String name, String matricNumber) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'matricNumber': matricNumber,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating admin user: $e');
      return false;
    }
  }
}
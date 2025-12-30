import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// KEEPING MOCK CRYPTO FOR YOUR ADMIN LOGIN LOGIC
class MockCrypto {
  static String hashPassword(String password) {
    if (password == 'admin123' || password == 'newpass123') {
      return 'hashed_${password.hashCode}';
    }
    final bytes = utf8.encode(password);
    return 'hashed_${bytes.length}_${bytes.last}';
  }
}

class CardRegistryService {
  // ✅ COLLECTION REFERENCE: This matches the Student App's lookup location
  static final CollectionReference _registryRef = 
      FirebaseFirestore.instance.collection('student_registrations');

  static const String _adminPasswordKey = 'admin_password_hash';
  static const String _defaultAdminPassword = "admin123";

  // ========== 1. ADMIN AUTH (Keep Local for MVP) ==========

  static Future<void> initializeAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_adminPasswordKey) == null) {
      final hashedPassword = MockCrypto.hashPassword(_defaultAdminPassword);
      await prefs.setString(_adminPasswordKey, hashedPassword);
      print('Admin initialized. Default: $_defaultAdminPassword');
    }
  }

  static Future<bool> verifyAdminPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHashedPassword = prefs.getString(_adminPasswordKey) ?? 
        MockCrypto.hashPassword(_defaultAdminPassword);
    
    final inputHashedPassword = MockCrypto.hashPassword(password);
    return inputHashedPassword == savedHashedPassword;
  }

  // ========== 2. CLOUD REGISTRATION (THE REAL DEAL) ==========

  /// Registers a student card directly to Firestore so Students can find it.
  static Future<Map<String, dynamic>> registerStudentCardWithVerification(Student student) async {
    try {
      // A. DUPLICATE CHECK: Card UID
      final cardQuery = await _registryRef
          .where('physicalCardUid', isEqualTo: student.physicalCardUid)
          .get();

      if (cardQuery.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Card UID ${student.physicalCardUid} is already registered.'
        };
      }

      // B. DUPLICATE CHECK: Matric Number (Student ID)
      final idQuery = await _registryRef
          .where('studentId', isEqualTo: student.studentId)
          .get();

      if (idQuery.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Student ID ${student.studentId} is already registered.'
        };
      }

      // C. SAVE TO FIRESTORE
      // We map the Student Model to JSON and add tracking fields
      final Map<String, dynamic> data = student.toJson();
      
      // Ensure specific fields exist for the Student App logic
      data['physicalCardUid'] = student.physicalCardUid; 
      data['studentId'] = student.studentId;
      data['isAssigned'] = false; // Important: No student has claimed this yet
      data['registeredAt'] = FieldValue.serverTimestamp();
      data['uid'] = null; // Will be filled when student links account

      await _registryRef.add(data);

      await logAdminAction('REGISTER', 'Added ${student.name} (${student.studentId})');

      return {
        'success': true,
        'message': 'Student ${student.name} synced to Cloud.'
      };

    } catch (e) {
      print('Firestore Error: $e');
      return {
        'success': false,
        'message': 'Cloud Error: $e'
      };
    }
  }

  /// LOOKUP: Find a student by their Physical Card UID (Used by NFC Scanner)
  static Future<Student?> getStudentForAutoFill(String cardUid) async {
    try {
      // Query Firestore for the card UID
      final query = await _registryRef
          .where('physicalCardUid', isEqualTo: cardUid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final data = query.docs.first.data() as Map<String, dynamic>;
      
      // Convert to Student object so the scanner can read it
      return Student.fromJson(data);
    } catch (e) {
      print("Error looking up card: $e");
      return null;
    }
  }

  // ========== 3. DATA RETRIEVAL (FROM CLOUD) ==========

  /// Fetches all registered cards to show in the Admin List
  static Future<Map<String, Student>> getRegisteredStudents() async {
    try {
      final snapshot = await _registryRef.get();
      
      final Map<String, Student> studentsMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convert Timestamp to String for local Model compatibility
        if (data['registeredAt'] is Timestamp) {
          data['registeredAt'] = (data['registeredAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }

        // Map Firestore document to Student Model
        // We use physicalCardUid as the key to match your old logic
        if (data['physicalCardUid'] != null) {
          studentsMap[data['physicalCardUid']] = Student.fromJson(data);
        }
      }
      return studentsMap;

    } catch (e) {
      print("Error fetching students: $e");
      return {};
    }
  }

  /// Deletes a student from the Cloud Registry
  static Future<bool> unregisterStudentCard(String cardUid) async {
    try {
      // 1. Find the document
      final query = await _registryRef
          .where('physicalCardUid', isEqualTo: cardUid)
          .get();

      if (query.docs.isEmpty) return false;

      // 2. Delete it
      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      await logAdminAction('DELETE', 'Removed card $cardUid');
      return true;

    } catch (e) {
      print("Error deleting: $e");
      return false;
    }
  }

  // ========== 4. HELPER METHODS ==========

  static Future<void> logAdminAction(String action, String details) async {
    // Ideally, save this to Firestore too in an 'admin_logs' collection
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp - $action - $details';
    
    final existingLogs = prefs.getStringList('admin_audit_log') ?? [];
    existingLogs.add(logEntry);
    if (existingLogs.length > 20) existingLogs.removeAt(0);
    
    await prefs.setStringList('admin_audit_log', existingLogs);
  }

  static Future<Map<String, dynamic>> getSystemStats() async {
    // Real-time count from Firestore
    final snapshot = await _registryRef.count().get();
    final count = snapshot.count;

    final prefs = await SharedPreferences.getInstance();
    final auditLogs = prefs.getStringList('admin_audit_log') ?? [];

    return {
      'totalStudents': count,
      'lastAdminAction': auditLogs.isNotEmpty ? auditLogs.last : 'None',
      'totalAdminActions': auditLogs.length,
      'systemInitialized': true
    };
  }

  // Search logic that queries Firestore (Client-side filtering for simplicity)
  static Future<List<Student>> searchStudents(String query) async {
    final allStudents = await getRegisteredStudents();
    final lowerQuery = query.toLowerCase();
    
    return allStudents.values.where((student) {
      return student.name.toLowerCase().contains(lowerQuery) ||
             student.studentId.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
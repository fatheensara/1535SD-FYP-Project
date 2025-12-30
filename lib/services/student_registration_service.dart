// lib/services/student_registration_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRegistrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if a student card is pre-registered
  static Future<Map<String, dynamic>?> getStudentByCardUid(String cardUid) async {
    try {
      // Query students collection by cardUid
      final query = await _firestore
          .collection('students')
          .where('PhysicalCardUid', isEqualTo: cardUid)
          .where('IsActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      print('Error checking student registration: $e');
      return null;
    }
  }

// This checks by DOCUMENT ID
static Future<bool> isStudentIdRegistered(String studentId) async {
  try {
    final query = await _firestore
        .collection('students')
        .where('studentId', isEqualTo: studentId) // ← Check by field
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  } catch (e) {
    print('Error checking student ID: $e');
    return false;
  }
}

  // Check if card UID is already registered
  static Future<bool> isCardUidRegistered(String cardUid) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('PhysicalCardUid', isEqualTo: cardUid)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking card UID: $e');
      return false;
    }
  }

static Future<bool> registerStudent({
    required String name,
    required String studentId,
    required String course,
    required String physicalCardUid,
    required String registeredByAdminId,
  }) async {
    try {
      print('🔥 Firestore: Starting registration...');

      // 1. Check if card is already registered
      // FIX: Used 'PhysicalCardUid' (Capitalized) to match the storage format
      final cardSnapshot = await _firestore
          .collection('students')
          .where('PhysicalCardUid', isEqualTo: physicalCardUid)
          .get();

      if (cardSnapshot.docs.isNotEmpty) {
        print('❌ Card already registered to another student!');
        return false;
      }

      // 2. Check if student ID exists
      // FIX: Used 'StudentID' (Capitalized) to match the storage format
      final studentSnapshot = await _firestore
          .collection('students')
          .where('StudentID', isEqualTo: studentId)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        print('❌ Student ID already exists!');
        return false;
      }

      // 3. Add to students collection
      await _firestore.collection('students').add({
        'Name': name,
        'StudentID': studentId,
        'Course': course,
        'PhysicalCardUid': physicalCardUid,
        'IsActive': true,
        'RegisteredAt': FieldValue.serverTimestamp(),
        'RegisteredBy': registeredByAdminId,
        'UpdatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Also register the card in separate collection
      await _firestore.collection('registered_student_cards').add({
        'cardUid': physicalCardUid,
        'studentId': studentId,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      print('✅ Registration complete!');
      return true;
    } catch (e) {
      print('💥 Firestore error: $e');
      return false;
    }
  }

 static Future<bool> deactivateStudent(String studentId) async {
  try {
    // Find document by StudentID field (not document ID)
    final query = await _firestore
        .collection('students')
        .where('StudentID', isEqualTo: studentId) // ← Capitalized
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) {
      print('❌ Student not found: $studentId');
      return false;
    }
    
    final docId = query.docs.first.id;
    await _firestore.collection('students').doc(docId).update({
      'IsActive': false, // ← Capitalized
      'DeactivatedAt': FieldValue.serverTimestamp(), // ← Capitalized
      'UpdatedAt': FieldValue.serverTimestamp(), // ← Capitalized
    });
    
    print('✅ Student $studentId deactivated');
    return true;
  } catch (e) {
    print('❌ Error deactivating student: $e');
    return false;
  }
}

 static Future<bool> reactivateStudent(String studentId) async {
  try {
    // Find document by StudentID field
    final query = await _firestore
        .collection('students')
        .where('StudentID', isEqualTo: studentId) // ← Capitalized
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) {
      print('❌ Student not found: $studentId');
      return false;
    }
    
    final docId = query.docs.first.id;
    await _firestore.collection('students').doc(docId).update({
      'IsActive': true, // ← Capitalized
      'ReactivatedAt': FieldValue.serverTimestamp(), // ← Capitalized
      'UpdatedAt': FieldValue.serverTimestamp(), // ← Capitalized
    });
    
    print('✅ Student $studentId reactivated');
    return true;
  } catch (e) {
    print('❌ Error reactivating student: $e');
    return false;
  }
}

  // Admin: Update student details
  static Future<bool> updateStudent({
  required String studentId,
  required String name,
  required String course,
  required String physicalCardUid,
}) async {
  try {
    // Find document by StudentID field
    final query = await _firestore
        .collection('students')
        .where('StudentID', isEqualTo: studentId) // ← Capitalized
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) {
      print('❌ Student not found: $studentId');
      return false;
    }
    
    final docId = query.docs.first.id;
    await _firestore.collection('students').doc(docId).update({
      'Name': name, // ← Capitalized
      'Course': course, // ← Capitalized
      'PhysicalCardUid': physicalCardUid, // ← Capitalized
      'UpdatedAt': FieldValue.serverTimestamp(), // ← Capitalized
    });
    
    print('✅ Student $studentId updated');
    return true;
  } catch (e) {
    print('❌ Error updating student: $e');
    return false;
  }
}

  // Get student by ID
  static Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    try {
      final doc = await _firestore
          .collection('students')
          .doc(studentId)
          .get();

      if (doc.exists) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting student by ID: $e');
      return null;
    }
  }
  

static Future<List<Map<String, dynamic>>> getAllRegisteredStudents() async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('IsActive', isEqualTo: true)
          .orderBy('RegisteredAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // FIX: Handle Timestamp conversion safely
        String dateStr = DateTime.now().toIso8601String();
        if (data['RegisteredAt'] != null) {
          if (data['RegisteredAt'] is Timestamp) {
            dateStr = (data['RegisteredAt'] as Timestamp).toDate().toIso8601String();
          }
        }

        // FIX: Map Capitalized Firestore keys to lowercase App keys
        return {
          'id': doc.id,
          'name': data['Name'] ?? '',
          'studentId': data['StudentID'] ?? '',
          'course': data['Course'] ?? '',
          'physicalCardUid': data['PhysicalCardUid'] ?? '', // Crucial Fix
          'registeredAt': dateStr, // Crucial Fix: Returns a String now
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting all students: $e');
      return [];
    }
  }

  // Search students by name or ID
  static Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    try {
      if (query.isEmpty) return await getAllRegisteredStudents();

      final students = await getAllRegisteredStudents();
      return students.where((student) {
        final name = student['Name'].toString().toLowerCase();
        final studentId = student['studentID'].toString().toLowerCase();
        final searchTerm = query.toLowerCase();
        
        return name.contains(searchTerm) || studentId.contains(searchTerm);
      }).toList();
    } catch (e) {
      print('❌ Error searching students: $e');
      return [];
    }
  }
}
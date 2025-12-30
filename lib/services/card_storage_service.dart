// lib/services/card_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CardStorageService {
  static const String _studentUidKey = 'student_uid';
  static const String _virtualCardPrefix = 'virtual_card_';
  static const String _currentCardKey = 'virtual_card_current';

static Future<void> saveVirtualCard({
  required Map<String, dynamic> cardData,
  required String physicalCardUid,
  required String studentId,
}) async {
  // Ensure required fields
  final completeCardData = {
    ...cardData,
    'physicalCardUid': physicalCardUid,
    'nfcId': physicalCardUid,
    'matricNo': studentId,
    'skinIndex': cardData['skinIndex'] ?? 0,
    'createdAt': cardData['createdAt'] ?? DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  // Save to SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final studentUid = 'student_$studentId';
  final cardJson = json.encode(completeCardData);

  print('💾 Saving virtual card:');
  print('   Student UID: $studentUid');
  print('   Name: ${completeCardData['name']}');
  print('   Physical Card UID: $physicalCardUid');

  // Save all keys for redundancy
  await prefs.setString(_studentUidKey, studentUid);
  await prefs.setString('$_virtualCardPrefix$physicalCardUid', cardJson);
  await prefs.setString(_currentCardKey, cardJson);

  // Also save with student UID as key
  await prefs.setString('$_virtualCardPrefix$studentUid', cardJson);

  // Save to Firestore (optional)
  try {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentUid)
        .set(completeCardData);
    print('✅ Firestore save successful');
  } catch (firestoreError) {
    print('⚠️ Firestore save failed (but continuing): $firestoreError');
  }

  print('✅ Virtual card saved successfully');
}

// In card_storage_service.dart
static Future<({
  Map<String, dynamic>? cardData,
  bool hasCard,
  String? studentUid,
})> loadVirtualCard() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Check ALL possible locations in order
    
    // 1. Check current card key
    final currentCardJson = prefs.getString(_currentCardKey);
    if (currentCardJson != null && currentCardJson.isNotEmpty) {
      try {
        final card = json.decode(currentCardJson) as Map<String, dynamic>;
        final studentUid = prefs.getString(_studentUidKey);
        return (cardData: card, hasCard: true, studentUid: studentUid);
      } catch (e) {
        print('Error parsing current card: $e');
      }
    }
    
    // 2. Check for any virtual_card_* keys
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_virtualCardPrefix)) {
        final cardJson = prefs.getString(key);
        if (cardJson != null && cardJson.isNotEmpty) {
          try {
            final card = json.decode(cardJson) as Map<String, dynamic>;
            final studentUid = prefs.getString(_studentUidKey);
            
            // Update current key for next time
            await prefs.setString(_currentCardKey, cardJson);
            
            return (cardData: card, hasCard: true, studentUid: studentUid);
          } catch (e) {
            print('Error parsing card from $key: $e');
          }
        }
      }
    }
    
    // 3. Check if student_uid exists (might be orphaned)
    final studentUid = prefs.getString(_studentUidKey);
    if (studentUid != null) {
      // Check if there's a corresponding card
      final cardKey = '$_virtualCardPrefix$studentUid';
      final cardJson = prefs.getString(cardKey);
      if (cardJson != null && cardJson.isNotEmpty) {
        try {
          final card = json.decode(cardJson) as Map<String, dynamic>;
          await prefs.setString(_currentCardKey, cardJson);
          return (cardData: card, hasCard: true, studentUid: studentUid);
        } catch (e) {
          print('Error parsing student card: $e');
        }
      }
    }
    
    // No card found
    return (cardData: null, hasCard: false, studentUid: studentUid);
    
  } catch (e) {
    print('Error in loadVirtualCard: $e');
    return (cardData: null, hasCard: false, studentUid: null);
  }
}

static Future<void> deleteVirtualCard() async {
  print('🗑️ Deleting local virtual card data...');
  final prefs = await SharedPreferences.getInstance();
  
  // 1. Clear "Auto-Login" ID (Critical for the loop issue)
  await prefs.remove('current_student_id');

  // 2. Get all keys to clean up everything
  final keys = prefs.getKeys();
  
  for (final key in keys) {
    // Check for your specific prefixes/keys
    if (key.startsWith('virtual_card') || 
        key == 'student_uid' || 
        key == 'current_card_data') { // specific keys depend on your constants
      
      await prefs.remove(key);
      print('   Deleted local key: $key');
    }
  }
  
  print('✅ Local data cleared. Student is now logged out of this phone.');
}

  static Future<List<Map<String, dynamic>>> getAllLocalCards() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final List<Map<String, dynamic>> cards = [];

    for (final key in keys) {
      if (key.startsWith(_virtualCardPrefix)) {
        final cardData = prefs.getString(key);
        if (cardData != null) {
          try {
            final card = json.decode(cardData) as Map<String, dynamic>;
            card['storageKey'] = key;
            cards.add(card);
          } catch (e) {
            print('Error parsing card: $e');
          }
        }
      }
    }

    return cards;
  }
}
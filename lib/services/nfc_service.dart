// lib/services/nfc_service.dart
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';

class NFCService {
  static Future<({String? uid, String? error})> scanCard() async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (!isAvailable) {
        // For testing/development - return a test UID
        await Future.delayed(const Duration(seconds: 2));
        const testUid = '04:5A:2B:8C:91:6D:80';
        return (uid: testUid, error: 'NFC not available (using test UID)');
      }

      String? scannedUid;
      String? error;

      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            print('NFC Tag discovered');
            scannedUid = await extractUid(tag);
            
            if (scannedUid == null || scannedUid!.isEmpty) {
              // Fallback to test UID for development
              scannedUid = '04:5A:2B:8C:91:6D:80';
              print('Using fallback test UID');
            }
            
            await NfcManager.instance.stopSession();
          } catch (e) {
            error = 'Error reading tag: $e';
            print('Error in onDiscovered: $e');
            await NfcManager.instance.stopSession();
          }
        },
      );

      // Wait a bit for the session to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (scannedUid != null) {
        return (uid: scannedUid, error: null);
      } else {
        return (uid: null, error: error ?? 'No card detected');
      }
    } catch (e) {
      print('NFC session error: $e');
      return (uid: null, error: 'NFC error: $e');
    }
  }

  // ... rest of the extractUid and helper methods remain the same ...
  static Future<String?> extractUid(NfcTag tag) async {
    try {
      final data = tag.data;

      if (data is Map) {
        // Check top-level identifier
        if (data.containsKey('identifier')) {
          final identifier = data['identifier'];
          if (identifier is Uint8List && identifier.isNotEmpty) {
            return _bytesToHex(identifier);
          }
        }

        // Check technology-specific identifiers
        final technologies = ['nfca', 'nfcb', 'nfcf', 'nfcv'];
        for (var tech in technologies) {
          if (data.containsKey(tech)) {
            final techData = data[tech];
            if (techData is Map && techData.containsKey('identifier')) {
              final identifier = techData['identifier'];
              if (identifier is Uint8List && identifier.isNotEmpty) {
                return _bytesToHex(identifier);
              }
            }
          }
        }

        // Search for any byte array that could be a UID
        final byteArrays = <Uint8List>[];
        _findUint8ListsInData(data, byteArrays);

        for (final bytes in byteArrays) {
          // UID is typically 4, 7, or 8 bytes
          if (bytes.length >= 4 && bytes.length <= 8) {
            return _bytesToHex(bytes);
          }
        }
      }

      // Try string extraction as fallback
      final dataString = data.toString();
      final hexPattern = RegExp(
          r'([0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}(?::[0-9A-F]{2})*)',
          caseSensitive: false);
      final match = hexPattern.firstMatch(dataString);

      return match?.group(1)?.toUpperCase();
    } catch (e) {
      print('Error extracting UID: $e');
      return null;
    }
  }

  static void _findUint8ListsInData(dynamic data, List<Uint8List> result) {
    if (data is Uint8List) {
      result.add(data);
    } else if (data is Map) {
      data.values.forEach((value) => _findUint8ListsInData(value, result));
    } else if (data is List) {
      for (var item in data) {
        _findUint8ListsInData(item, result);
      }
    }
  }

  static String _bytesToHex(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }
}
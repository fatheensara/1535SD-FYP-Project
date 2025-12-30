import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert'; 
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 


import '../services/card_registry_service.dart';
import '../models/student_model.dart';

class NFCScanScreen extends StatefulWidget {
  final Function(String)? onNFCSuccess;
  const NFCScanScreen({super.key, this.onNFCSuccess});

  @override
  State<NFCScanScreen> createState() => _NFCScanScreenState();
}

class _NFCScanScreenState extends State<NFCScanScreen> {
  static const _initialMessage = 'Ready to scan student cards';
  static const _nfcNotAvailableMessage = 'NFC not available';
  
  String _statusMessage = _initialMessage;
  bool _isScanning = false;
  List<String> _attendanceRecords = []; // Add this line for attendance tracking

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Person A's background
      appBar: AppBar(
        title: Text(
          'Scan Student Cards',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green, // Lecturer role color
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: _showAttendanceRecords,
            tooltip: 'View Attendance Records',
          ),
        ],
      ),
      body: _buildScanningInterface(),
    );
  }

  Widget _buildScanningInterface() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700, // Lecturer green theme
            Colors.green.shade600,
            Colors.green.shade800,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing NFC Icon (Person A's style)
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_isScanning)
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _statusMessage.startsWith('Attendance recorded') 
                              ? [Colors.green, Colors.lightGreen]
                              : [Colors.white, Colors.white.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        size: 50,
                        color: _statusMessage.startsWith('Attendance recorded') 
                            ? Colors.white 
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Status Message
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(height: 8),

              if (!_statusMessage.startsWith('Attendance recorded') && !_isScanning)
                Text(
                  "Ask students to tap their phones",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

              const SizedBox(height: 40),

              // Scan Button (Person A's button style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isScanning ? null : _startNfcSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 5,
                  ),
                  child: _isScanning
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.green.shade800),
                            const SizedBox(width: 12),
                            Text(
                              'Scanning...',
                              style: GoogleFonts.poppins(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text('Start Scanning'),
                ),
              ),

              const SizedBox(height: 30),

              // Today's Stats (Person A's card style)
              Card(
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            _attendanceRecords.length.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Today',
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.people, size: 30, color: Colors.white),
                          const SizedBox(height: 4),
                          Text(
                            'Students',
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Quick Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Students should open their virtual cards before tapping',
                        style: GoogleFonts.lato(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
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
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        Icon(
          _getStatusIcon(),
          size: 64,
          color: _getStatusColor(),
        ),
        const SizedBox(height: 16),
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getStatusColor(),
              ),
        ),
        if (_isScanning) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton(
      onPressed: _isScanning ? null : _startNfcSession,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: const Text('Scan NFC Card'),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  _attendanceRecords.length.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text('Today'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_isScanning) return Icons.nfc;
    if (_statusMessage.startsWith('Attendance recorded')) return Icons.check_circle;
    if (_statusMessage == _nfcNotAvailableMessage) return Icons.error;
    return Icons.nfc;
  }

  Color _getStatusColor() {
    if (_statusMessage.startsWith('Attendance recorded')) return Colors.green;
    if (_statusMessage.contains('Error') || _statusMessage == _nfcNotAvailableMessage) {
      return Colors.red.shade200;
    }
    return Colors.white;
  }

Future<void> _startNfcSession() async {
  if (_isScanning) return;

  _updateState(
    statusMessage: 'Checking NFC availability...',
    isScanning: true,
  );

  try {
    final bool isAvailable = await NfcManager.instance.isAvailable();
    
    if (!isAvailable) {
      _updateState(
        statusMessage: _nfcNotAvailableMessage,
        isScanning: false,
      );
      return;
    }

    _updateState(statusMessage: 'Ready to scan...\nAsk student to tap their phone');

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (tag) async {
        try {
          await _onTagDiscovered(tag); // Call your handler
        } catch (e) {
          _updateState(
            statusMessage: 'Error reading tag: $e',
            isScanning: false,
          );
          await NfcManager.instance.stopSession();
        }
      },
    );
  } catch (e) {
    // Add catch clause for the outer try block
    _updateState(
      statusMessage: 'Failed to start NFC session: $e',
      isScanning: false,
    );
  }
}

// NfcPollingOption.iso14443 - For NFC-A/B (most common cards)
// NfcPollingOption.iso15693 - For NFC-V (vicinity cards)
// NfcPollingOption.iso18092 - For NFC-F (Felica cards)

Future<void> _onTagDiscovered(NfcTag tag) async {
  try {
    // First, try to read NDEF data (virtual cards)
    // Cast tag.data to Map first
    final tagData = tag.data as Map<String, dynamic>;
    _debugPrintTagData(tag);
    
    // Check for NDEF data
    if (tagData.containsKey('ndef')) {
      final ndefData = tagData['ndef'] as Map<String, dynamic>?;
      if (ndefData != null) {
        // Check for cached message
        if (ndefData.containsKey('cachedMessage')) {
          final message = ndefData['cachedMessage'] as Map<String, dynamic>?;
          if (message != null && message.containsKey('records')) {
            final records = message['records'] as List<dynamic>?;
            if (records != null) {
              for (final record in records) {
                final recordMap = record as Map<String, dynamic>?;
                if (recordMap != null && recordMap['type'] == "T") {
                  // This is a text record (virtual card)
                  final payload = recordMap['payload'] as Uint8List?;
                  if (payload != null) {
                    final text = String.fromCharCodes(payload);
                    _handleVirtualCard(text);
                    return;
                  }
                }
              }
            }
          }
        }
      }
    }

    // If no NDEF data, try to read UID (physical cards)
    final String? uid = _extractUidFromTag(tag);
    
    if (uid == null) {
      _updateState(statusMessage: 'Error: Could not read card data');
    } else {
      _updateState(statusMessage: 'Physical Card UID: $uid');
      _recordAttendance('Physical Card: $uid');
    }
  } catch (e) {
    _updateState(statusMessage: 'Error reading card: $e');
  } finally {
    await NfcManager.instance.stopSession();
    _updateState(isScanning: false);
  }
}

  void _handleVirtualCard(String data) async { // Make async
    try {
      final virtualCardData = json.decode(data);
      final studentId = virtualCardData['studentId'] ?? 'Unknown ID';
      final physicalCardUid = virtualCardData['physicalCardUid'];

      if (physicalCardUid == null || physicalCardUid.isEmpty) {
        _updateState(statusMessage: 'SECURITY ALERT: Card UID missing.');
        return;
      }
      
      // 1. Validate the card UID against the master registry (CardRegistryService)
      final Student? registeredStudent = await CardRegistryService.getStudentForAutoFill(physicalCardUid);

      if (registeredStudent == null) {
        // SECURITY ALERT: Card UID is valid format but UNREGISTERED
        _updateState(statusMessage: 'SECURITY ALERT: Unregistered Card UID detected.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 SECURITY: Card not registered in system.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      // 2. Cross-check internal student ID matches the registered data
      if (registeredStudent.studentId != studentId) {
          _updateState(statusMessage: 'SECURITY ALERT: ID mismatch. Virtual card corrupted.');
          return;
      }
      
      // 3. Check for duplicate attendance (using studentId for uniqueness)
      final now = DateTime.now();
      final todayKey = DateFormat('yyyy-MM-dd').format(now);
      
      if (_attendanceRecords.any((record) => record.contains(studentId) && record.contains(todayKey))) {
          _updateState(statusMessage: 'Attendance already recorded for ${registeredStudent.name} today');
          // ... (Show orange snackbar) ...
          return;
      }
      
      // SUCCESS: Validated and Recording attendance
      final timeStr = DateFormat('HH:mm').format(now);
      final record = '$timeStr - ${registeredStudent.name} (ID: ${registeredStudent.studentId})';
      
      _updateState(statusMessage: 'Attendance recorded for ${registeredStudent.name}');
      _recordAttendance(record);
      
      // ... (Show green success snackbar) ...

    } catch (e) {
      _updateState(statusMessage: 'SECURITY ERROR: Invalid card data format.');
      // ... (Show red error snackbar) ...
    }
  }

  void _recordAttendance(String record) {
  setState(() {
    _attendanceRecords.add(record);
  });
}


String? _extractUidFromTag(NfcTag tag) {
  try {
    print('=== NFC TAG DEBUG ===');
    
    // 1. Check the tag type and properties
    print('Tag type: ${tag.runtimeType}');
    print('Tag data type: ${tag.data.runtimeType}');
    print('Tag data: $tag');
    
    // 2. Try to access tag properties directly
    
    // Method 1: Try to access tag.data as a Map with string keys
    try {
      if (tag.data is Map) {
        final dataMap = tag.data as Map;
        print('Tag data as Map keys: ${dataMap.keys.toList()}');
        
        // Try common key names for UID
        final uidKeys = ['identifier', 'uid', 'id', 'tagId', 'cardId'];
        
        for (final key in uidKeys) {
          if (dataMap.containsKey(key)) {
            final value = dataMap[key];
            print('Found $key: $value (type: ${value.runtimeType})');
            
            if (value is List<int> || value is Uint8List) {
              final bytes = value is List<int> 
                  ? Uint8List.fromList(value)
                  : value as Uint8List;
              
              if (bytes.isNotEmpty) {
                final uid = _bytesToHex(bytes);
                print('✅ Extracted UID from $key: $uid');
                return uid;
              }
            } else if (value is String && value.isNotEmpty) {
              print('✅ Extracted UID as String: $value');
              return value;
            }
          }
        }
      }
    } catch (e) {
      print('Error accessing as Map: $e');
    }
    
    // Method 2: Use reflection to access properties (if TagPigeon)
    try {
      // Try to access TagPigeon properties
      final tagData = tag.data;
      
      // Check for common TagPigeon properties
      final properties = ['identifier', 'uid', 'id', 'tagId'];
      
      for (final prop in properties) {
        try {
          // Use dynamic access since we don't know the exact type
          final value = (tagData as dynamic)[prop];
          if (value != null) {
            print('Found property $prop: $value (type: ${value.runtimeType})');
            
            if (value is List<int> || value is Uint8List) {
              final bytes = value is List<int> 
                  ? Uint8List.fromList(value)
                  : value as Uint8List;
              
              if (bytes.isNotEmpty) {
                final uid = _bytesToHex(bytes);
                print('✅ Extracted UID from property $prop: $uid');
                return uid;
              }
            }
          }
        } catch (_) {
          // Property doesn't exist, continue
        }
      }
    } catch (e) {
      print('Error accessing TagPigeon properties: $e');
    }
    
    // Method 3: Try to serialize and decode
    try {
      final jsonString = tag.toString();
      print('Tag toString(): $jsonString');
      
      // Look for UID patterns in the string representation
      if (jsonString.contains('identifier')) {
        final start = jsonString.indexOf('identifier');
        final end = jsonString.indexOf(',', start);
        if (end > start) {
          final identifierStr = jsonString.substring(start, end);
          print('Found identifier in string: $identifierStr');
          
          // Try to extract bytes from string representation
          final regex = RegExp(r'\[([0-9, ]+)\]');
          final match = regex.firstMatch(identifierStr);
          if (match != null) {
            final bytesStr = match.group(1)!;
            final bytes = bytesStr.split(',').map((s) => int.tryParse(s.trim())).where((i) => i != null).cast<int>().toList();
            if (bytes.isNotEmpty) {
              final uid = _bytesToHex(Uint8List.fromList(bytes));
              print('✅ Extracted UID from string regex: $uid');
              return uid;
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing string: $e');
    }
    
    // Method 4: Debug - print all available methods/properties
    print('=== DEBUGGING TAG OBJECT ===');
    print('Tag: $tag');
    print('Tag data: ${tag.data}');
    
    // Try to get all properties via reflection
    try {
      final tagData = tag.data;
      print('Tag data runtimeType: ${tagData.runtimeType}');
      
      // Try to convert to JSON if possible
      try {
        final json = jsonEncode(tagData); // This uses the import from top of file
        print('Tag data as JSON: $json');
        
        // Parse JSON and look for UID
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          print('Decoded JSON keys: ${decoded.keys.toList()}');
          for (final key in decoded.keys) {
            print('  $key: ${decoded[key]} (${decoded[key].runtimeType})');
          }
        }
      } catch (e) {
        print('Cannot encode as JSON: $e');
      }
    } catch (e) {
      print('Error in reflection: $e');
    }
    
    print('❌ Could not find UID in tag data');
    return null;
    
  } catch (e) {
    print('Error extracting UID: $e');
    print('Stack trace: ${e.toString()}');
    return null;
  }
}

  String _bytesToHex(dynamic bytes) {
    try {
      if (bytes == null) return '';
      
      if (bytes is Uint8List) {
        return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
      }
      
      if (bytes is List<int>) {
        return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
      }
      
      return bytes.toString();
    } catch (e) {
      return bytes?.toString() ?? '';
    }
  }

  void _debugPrintTagData(NfcTag tag) {
  try {
    final tagData = tag.data as Map<String, dynamic>;
    print('=== DEBUG: Tag Data Structure ===');
    print('All keys: ${tagData.keys.toList()}');
    
    for (final key in tagData.keys) {
      final value = tagData[key];
      print('$key: ${value.runtimeType} = $value');
      if (value is Map) {
        print('  Sub-keys: ${value.keys.toList()}');
      }
    }
    print('=== END DEBUG ===');
  } catch (e) {
    print('Debug error: $e');
  }
}

  void _updateState({
    String? statusMessage,
    bool? isScanning,
  }) {
    if (mounted) {
      setState(() {
        if (statusMessage != null) _statusMessage = statusMessage;
        if (isScanning != null) _isScanning = isScanning;
      });
    }
  }

  void _showAttendanceRecords() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade50,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Today's Attendance",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                _attendanceRecords.isEmpty
                    ? Column(
                        children: [
                          Icon(Icons.list_alt, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance records yet',
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.maxFinite,
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _attendanceRecords.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _attendanceRecords[index],
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class CreateVirtualCardScreen extends StatefulWidget {
  final String nfcUid;
  final VoidCallback onCardCreated;
  
  const CreateVirtualCardScreen({
    super.key,
    required this.nfcUid,
    required this.onCardCreated,
  });

  @override
  State<CreateVirtualCardScreen> createState() => _CreateVirtualCardScreenState();
}

class _CreateVirtualCardScreenState extends State<CreateVirtualCardScreen> {
  String status = "Tap 'Check NFC' to start";
  bool _isLoading = false;
  String _scannedUid = "";

  @override
  void initState() {
    super.initState();
    // Auto-start NFC session if UID is provided
    if (widget.nfcUid.isNotEmpty) {
      _createVirtualCardWithExistingUID();
    }
  }

  Future<void> _createVirtualCardWithExistingUID() async {
    setState(() {
      _isLoading = true;
      status = "Creating virtual card...";
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          status = "Error: User not logged in";
          _isLoading = false;
        });
        return;
      }

      // Save NFC tag to student document
      await FirebaseFirestore.instance.collection('students').doc(userId).set({
        'nfcTag': widget.nfcUid,
        'virtualCardCreated': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nfcTag', widget.nfcUid);
      await prefs.setBool('hasVirtualCard', true);

      setState(() {
        status = "✅ Virtual card created successfully!\nNFC UID: ${widget.nfcUid.substring(0, 8)}...";
      });

      // Call the callback to notify parent
      widget.onCardCreated();

    } catch (e) {
      setState(() {
        status = "Failed to create virtual card: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNfcAvailability() async {
    try {
      bool available = await NfcManager.instance.isAvailable();
      setState(() {
        status = available ? "NFC is available. Tap a tag!" : "NFC not available on this device";
      });
    } catch (e) {
      setState(() {
        status = "Error checking NFC availability: $e";
      });
    }
  }

Future<void> _startNfcSession() async {
  try {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        status = "NFC not available on this device";
      });
      return;
    }

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          final userId = FirebaseAuth.instance.currentUser?.uid ?? "Anonymous";

          // Extract tag ID
          String? tagId = _extractUidFromTag(tag);
          
          if (tagId == null) {
            setState(() {
              status = "Could not read NFC tag UID";
            });
            return;
          }

          // Save NFC tag to student document
          await FirebaseFirestore.instance.collection('students').doc(userId).set({
            'nfcTag': tagId,
            'virtualCardCreated': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          // Also record attendance
          await FirebaseFirestore.instance.collection('attendance').add({
            'tagId': tagId,
            'userId': userId,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Save locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nfcTag', tagId);
          await prefs.setBool('hasVirtualCard', true);

          setState(() {
            status = "✅ NFC tag saved and virtual card created!\nUID: ${tagId.substring(0, 8)}...";
          });

          // Call the callback to notify parent
          widget.onCardCreated();

        } catch (e) {
          setState(() {
            status = "Failed to save NFC tag: $e";
          });
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );
  } catch (e) {
    setState(() {
      status = "Error starting NFC session: $e";
    });
  }

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

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
  }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Virtual Card"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.nfcUid.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.nfc, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NFC Card Scanned',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          Text(
                            'UID: ${widget.nfcUid.substring(0, 8)}...',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: status.contains('✅') ? Colors.green : 
                       status.contains('Error') ? Colors.red : Colors.black,
              ),
            ),
            
            const SizedBox(height: 30),
            
            if (_isLoading)
              const CircularProgressIndicator(),
            
            if (!_isLoading && widget.nfcUid.isEmpty) ...[
              ElevatedButton(
                onPressed: _checkNfcAvailability,
                child: const Text("Check NFC Availability"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _startNfcSession,
                child: const Text("Scan NFC Tag"),
              ),
            ],
            
            if (!_isLoading && widget.nfcUid.isNotEmpty)
              ElevatedButton(
                onPressed: _createVirtualCardWithExistingUID,
                child: const Text("Create Virtual Card"),
              ),
          ],
        ),
      ),
    );
  }
}

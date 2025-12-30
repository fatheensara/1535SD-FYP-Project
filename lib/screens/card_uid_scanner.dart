
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class CardUidScanner extends StatefulWidget {
  const CardUidScanner({super.key});

  @override
  State<CardUidScanner> createState() => _CardUidScannerState();
}

class _CardUidScannerState extends State<CardUidScanner> {
  String _cardUid = 'Not scanned yet';
  bool _isScanning = false;
  List<String> _scannedCards = [];

  Future<void> _scanCard() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _cardUid = 'Scanning...';
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      
      if (!isAvailable) {
        setState(() {
          _cardUid = 'NFC not available on this device';
          _isScanning = false;
        });
        return;
      }

      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          final uid = await _extractUid(tag);
          
          if (uid != null) {
            await NfcManager.instance.stopSession();
            
            if (mounted) {
              setState(() {
                _cardUid = uid;
                _scannedCards.add(uid);
                _isScanning = false;
              });
            }
          } else {
            await NfcManager.instance.stopSession();
            if (mounted) {
              setState(() {
                _cardUid = 'Could not extract UID';
                _isScanning = false;
              });
            }
          }
        },
      );
    } catch (e) {
      setState(() {
        _cardUid = 'Error: $e';
        _isScanning = false;
      });
    }
  }

  Future<String?> _extractUid(NfcTag tag) async {
    try {
      final data = tag.data;
      
      if (data is Map) {
        if (data.containsKey('identifier')) {
          final identifier = data['identifier'];
          if (identifier is Uint8List && identifier.isNotEmpty) {
            return identifier
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();
          }
        }
        
        // Check for NFC-A
        if (data.containsKey('nfca')) {
          final nfca = data['nfca'];
          if (nfca is Map && nfca.containsKey('identifier')) {
            final identifier = nfca['identifier'];
            if (identifier is Uint8List && identifier.isNotEmpty) {
              return identifier
                  .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                  .join(':')
                  .toUpperCase();
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error extracting UID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card UID Scanner'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Scan Button
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _scanCard,
              icon: const Icon(Icons.nfc),
              label: Text(_isScanning ? 'Scanning...' : 'Scan Card'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            
            // Current UID Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Card UID:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _cardUid,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Monospace',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_cardUid != 'Not scanned yet' && _cardUid != 'Scanning...')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _cardUid));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('UID copied to clipboard!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Copy to Clipboard'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Format for Firestore
                              final json = '''
                                {
                                  "physicalCardUid": "$_cardUid",
                                  "name": "STUDENT_NAME_HERE",
                                  "studentId": "STUDENT_ID_HERE",
                                  "course": "COURSE_HERE",
                                  "isActive": true,
                                  "registeredAt": "${DateTime.now().toIso8601String()}",
                                  "registeredBy": "admin"
                                }
                              ''';
                              Clipboard.setData(ClipboardData(text: json));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('JSON template copied!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Copy JSON Template'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Previously Scanned Cards
            if (_scannedCards.isNotEmpty) ...[
              const Text(
                'Previously Scanned:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _scannedCards.length,
                  itemBuilder: (context, index) {
                    final uid = _scannedCards[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text(uid),
                        subtitle: Text('Tap to copy'),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: uid));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('UID copied!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
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
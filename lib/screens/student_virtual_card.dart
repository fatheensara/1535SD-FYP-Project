import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart'; 

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  String studentSavedUid = FirebaseAuth.instance.currentUser?.uid ?? "ERROR_NO_USER";
  String _state = "Initializing...";

  @override
  void initState() {
    super.initState();
    startEmulation();
  }

  void startEmulation() async {
    bool nfcEnabled = false;
    try {
      NfcState nfcState = await NfcHce.checkDeviceNfcState();
      if (nfcState == NfcState.enabled) {
        nfcEnabled = true;
      }
    } catch (e) {
      if (mounted) setState(() { _state = "Error checking NFC: $e"; });
      return;
    }

    if (!nfcEnabled) {
      if (mounted) setState(() { _state = "NFC is OFF. Please enable it in Settings."; });
      return;
    }

    // AID: F0 01 02 03 04 05 06
    List<int> aid = [0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06];

    try {
      await NfcHce.init(
        aid: Uint8List.fromList(aid),
        permanentApduResponses: true,
        listenOnlyConfiguredPorts: false,
      );

      List<int> uidBytes = utf8.encode(studentSavedUid);
      await NfcHce.addApduResponse(0, Uint8List.fromList(uidBytes));
      
      if (mounted) {
        setState(() {
          _state = "Beaming Active";
        });
      }
    } catch (e) {
      if (mounted) setState(() { _state = "Error starting HCE: $e"; });
    }
  }

  @override
  void dispose() {
    NfcHce.removeApduResponse(0);
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, 
    appBar: AppBar(
      title: const Text("Virtual Card"),
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. EXISTING NFC SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.nfc, size: 60, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 20),
            
            // Status Text
            Text(
              _state, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.blue.shade900
              )
            ),
            
            const SizedBox(height: 10),
            const Text(
              "Hold phone near lecturer's device",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // --- 2. NEW QR CODE SECTION ---
            const Text(
              "OR SCAN QR CODE",
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey,
                letterSpacing: 1.5
              ),
            ),
            const SizedBox(height: 20),
            
            // The QR Widget
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: QrImageView(
                data: studentSavedUid, // <--- Generates QR from your ID
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
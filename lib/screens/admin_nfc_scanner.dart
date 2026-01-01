import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class AdminScannerPage extends StatefulWidget {
  @override
  State<AdminScannerPage> createState() => _AdminScannerPageState();
}

class _AdminScannerPageState extends State<AdminScannerPage> {
  String _log = "Ready to scan student phone...";

  void _startScanning() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // 1. Check for HCE support (IsoDep)
        var isoDep = IsoDep.from(tag);

        if (isoDep == null) {
          _updateLog("Found a tag, but it's not a smart phone (IsoDep).");
          // We don't stop the session, so you can try again immediately
          return;
        }

        try {
          // Note: We DO NOT need isoDep.connect() here. The plugin does it.

          // 2. Send the "Select AID" Command
          // This tells the student phone: "Open the AttenDID app"
          List<int> command = [
            0x00, 0xA4, 0x04, 0x00, 0x07, // Header
            0xF0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, // The AID
            0x00, // Footer
          ];

          // 3. Send command and get Response
          Uint8List response = await isoDep.transceive(
            data: Uint8List.fromList(command),
          );

          // 4. Decode the Student UID
          String studentUid = String.fromCharCodes(response);

          _updateLog("SUCCESS! Student UID: $studentUid");

          // Verify with database here...

          // 5. Done. Stop scanning.
          NfcManager.instance.stopSession();
        } catch (e) {
          _updateLog("Error: $e");
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  void _updateLog(String msg) {
    setState(() {
      _log = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Scanner")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _log,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startScanning,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text("Start Scan", style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}

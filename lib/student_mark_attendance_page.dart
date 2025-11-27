import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:async'; // For timers

class MarkAttendancePage extends StatefulWidget {
  final String className;

  const MarkAttendancePage({super.key, required this.className});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  // Options
  final List<String> _attendanceOptions = [
    'Present',
    'Late',
    'Absent',
    'Excused',
  ];
  String _selectedStatus = 'Present';

  // NFC States
  String _nfcStatus = "Ready to Scan";
  bool _isScanning = false;
  bool _scanSuccess = false;

  // File Upload State
  String? _attachedFileName;

  // Animation Controller for "Pulsing" effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setup Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initial Logic
    _updateStatusLogic(_selectedStatus);
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    _pulseController.dispose();
    super.dispose();
  }

  // --- LOGIC HANDLERS ---

  void _updateStatusLogic(String status) {
    setState(() {
      _selectedStatus = status;
      _attachedFileName = null; // Reset file
      _scanSuccess = false;
    });

    if (status == 'Present' || status == 'Late') {
      _startNfcScan();
    } else {
      _stopNfcScan();
    }
  }

  void _startNfcScan() async {
    // ignore: deprecated_member_use
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      if (mounted) {
        setState(() {
          _nfcStatus = "NFC Not Supported";
          _isScanning = false;
        });
      }
      return;
    }

    setState(() {
      _nfcStatus = "Hold near lecturer's device";
      _isScanning = true;
      _pulseController.repeat(reverse: true); // Start pulsing
    });

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          // Success Logic
          setState(() {
            _nfcStatus = "Attendance Verified!";
            _isScanning = false;
            _scanSuccess = true;
            _pulseController.stop();
          });

          await NfcManager.instance.stopSession();

          // Auto-close after success
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop();
          });
        },
      );
    } catch (e) {
      setState(() {
        _nfcStatus = "Error: $e";
        _isScanning = false;
        _pulseController.stop();
      });
      NfcManager.instance.stopSession();
    }
  }

  void _stopNfcScan() {
    NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
      _pulseController.stop();
    });
  }

  // Helper to get theme color based on status
  Color _getThemeColor() {
    switch (_selectedStatus) {
      case 'Present':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      case 'Excused':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    Color themeColor = _getThemeColor();
    bool requiresNfc =
        (_selectedStatus == 'Present' || _selectedStatus == 'Late');
    // ignore: unused_local_variable
    bool requiresFile =
        (_selectedStatus == 'Absent' || _selectedStatus == 'Excused');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          // --- 1. HEADER SECTION ---
          _buildHeader(themeColor),

          // --- 2. MAIN CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // STATUS SELECTOR
                  _buildStatusSelector(themeColor),
                  const SizedBox(height: 40),

                  // DYNAMIC CONTENT (NFC or FILE)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: requiresNfc
                        ? _buildNfcScannerUI(themeColor)
                        : _buildFileUploadUI(themeColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [themeColor.withOpacity(0.8), themeColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: themeColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Text(
                  "Mark Attendance",
                  style: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.className,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: themeColor),
          items: _attendanceOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Logic for dot color in dropdown
                      color: value == 'Present'
                          ? Colors.green
                          : value == 'Late'
                          ? Colors.orange
                          : value == 'Absent'
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) _updateStatusLogic(val);
          },
        ),
      ),
    );
  }

  Widget _buildNfcScannerUI(Color themeColor) {
    return Column(
      key: const ValueKey('NFC'),
      children: [
        // PULSING ICON
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glow (Animated)
            if (_isScanning)
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: themeColor.withOpacity(0.1),
                  ),
                ),
              ),
            // Middle Glow
            if (_isScanning)
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: themeColor.withOpacity(0.2),
                ),
              ),
            // The Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _scanSuccess
                      ? [Colors.green, Colors.lightGreen]
                      // ignore: deprecated_member_use
                      : [themeColor, themeColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                _scanSuccess ? Icons.check_circle_outline : Icons.nfc_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          _nfcStatus,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _scanSuccess ? Colors.green : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        if (!_scanSuccess)
          Text(
            "Bring your phone close to the tag",
            style: GoogleFonts.lato(color: Colors.grey.shade500),
          ),
      ],
    );
  }

  Widget _buildFileUploadUI(Color themeColor) {
    return Column(
      key: const ValueKey('FILE'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 50,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _selectedStatus == 'Absent'
                    ? "Upload MC / Certificate"
                    : "Upload Letter",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "PDF or Image (Max 5MB)",
                style: GoogleFonts.lato(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              // File Selection Logic
              if (_attachedFileName == null)
                OutlinedButton(
                  onPressed: () {
                    // Simulate picking file
                    setState(() {
                      _attachedFileName = "medical_cert_nov2025.pdf";
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Browse Files"),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.description,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _attachedFileName!,
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            setState(() => _attachedFileName = null),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _attachedFileName != null
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Document Submitted Successfully"),
                        backgroundColor: themeColor,
                      ),
                    );
                    Navigator.pop(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              elevation: 5,
              // ignore: deprecated_member_use
              shadowColor: themeColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Submit Document",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import '../services/nfc_service.dart';
import '../services/card_storage_service.dart';
import 'my_virtual_card.dart';
import '../services/student_registration_service.dart';

class StudentCardScreen extends StatefulWidget {
  const StudentCardScreen({super.key});

  @override
  State<StudentCardScreen> createState() => _StudentCardScreenState();
}

class _StudentCardScreenState extends State<StudentCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _courseController = TextEditingController();

  String? _selectedCourse;
  String _status = 'initial';
  String _statusMessage = "Tap to scan your card";
  bool _isScanning = false;
  bool _isWriting = false;
  Map<String, dynamic>? _studentData;
  String? _physicalCardUid;
  bool _hasExistingVirtualCard = false;
  
  List<Map<String, dynamic>> _allCards = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCard();
    _loadAllCards();
    _checkExistingRequestStatus();
  }

  Future<String> _getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Unique Android ID
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? 'unknown_ios'; // Unique iOS ID
  }
  return 'unknown_device';
}

  Future<void> _checkExistingRequestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedStudentId = prefs.getString('current_student_id');
    String currentDeviceId = await _getDeviceId();

    try {
      DocumentSnapshot? foundDoc;
      
      // ---------------------------------------------------------
      // STRATEGY 1: Check by Saved Student ID (Fastest)
      // ---------------------------------------------------------
      if (savedStudentId != null) {
        final docById = await FirebaseFirestore.instance
            .collection('student_registrations')
            .where('studentId', isEqualTo: savedStudentId)
            .limit(1)
            .get();
            
        if (docById.docs.isNotEmpty) {
          foundDoc = docById.docs.first;
        }
      }

      // ---------------------------------------------------------
      // STRATEGY 2: Check by Device ID (Fallback - Finds "Lost" Cards)
      // ---------------------------------------------------------
      if (foundDoc == null) {
        print("🔍 checking by Device ID: $currentDeviceId");
        final docByDevice = await FirebaseFirestore.instance
            .collection('student_registrations')
            .where('deviceId', isEqualTo: currentDeviceId) // Check if this phone owns anyone
            .limit(1)
            .get();

        if (docByDevice.docs.isNotEmpty) {
          foundDoc = docByDevice.docs.first;
          // Heal the broken session
          savedStudentId = foundDoc['studentId'];
          await prefs.setString('current_student_id', savedStudentId!);
        }
      }

      // ---------------------------------------------------------
      // HANDLE RESULT
      // ---------------------------------------------------------
      if (foundDoc != null) {
        final data = foundDoc.data() as Map<String, dynamic>;

        // Security Check: Ensure Device ID matches (if set)
        if (data['deviceId'] != null && data['deviceId'] != currentDeviceId) {
           setState(() {
             _statusMessage = "⛔ SECURITY ALERT: Card linked to another device.";
             _status = "blocked";
             _physicalCardUid = null;
           });
           return;
        }

        // ✅ Success!
        setState(() => _status = 'approved');
        await _saveToLocalAndNavigate(data);
        return;
      }

      // 3. If still nothing, check Pending Requests
      if (savedStudentId != null) {
        final pendingDoc = await FirebaseFirestore.instance
            .collection('student_requests')
            .where('studentId', isEqualTo: savedStudentId)
            .get();

        if (pendingDoc.docs.isNotEmpty) {
          setState(() => _status = 'pending');
        } else {
          setState(() => _status = 'initial');
        }
      } else {
        setState(() => _status = 'initial');
      }

    } catch (e) {
      print("Error checking status: $e");
      if (mounted) setState(() => _status = 'initial');
    }
  }

  Future<void> _loadAllCards() async {
    _allCards = await CardStorageService.getAllLocalCards();
    if (mounted) setState(() {});
  }

  Future<void> _loadSavedCard() async {
    final result = await CardStorageService.loadVirtualCard();
    
    if (mounted) {
      setState(() {
        _hasExistingVirtualCard = result.hasCard;
        _studentData = result.cardData;
        _physicalCardUid = result.cardData?['physicalCardUid'];
      });
    }
  }

  void _scanPhysicalCard() async {
    if (_isScanning) return;

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() => _statusMessage = "❌ NFC Not Available");
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning... Hold card against phone';
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Read UID (v3.3.0 style)
            final data = tag.data;
            List<int>? idBytes;

            if (data.containsKey('isodep')) {
               idBytes = List<int>.from(data['isodep']['identifier']);
            } else if (data.containsKey('nfca')) {
               idBytes = List<int>.from(data['nfca']['identifier']);
            } else if (data.containsKey('mifareclassic')) {
               idBytes = List<int>.from(data['mifareclassic']['identifier']);
            }

            if (idBytes == null) {
               await NfcManager.instance.stopSession(errorMessage: "Read Failed"); 
               return;
            }

            String scannedUid = idBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();

            // Success! Stop NFC first.
            await NfcManager.instance.stopSession();

            if (mounted) {
              setState(() {
                _physicalCardUid = scannedUid;
                _isScanning = false;
                _statusMessage = "✅ Card Detected: $scannedUid";
              });
              
              // ⚡ TRIGGER THE AUTO-FILL
              _checkIfCardIsRegistered(scannedUid);
            }

          } catch (e) {
            await NfcManager.instance.stopSession(errorMessage: "Error");
          }
        },
      );
    } catch (e) {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _checkIfCardIsRegistered(String cardUid) async {
    setState(() => _statusMessage = "Checking database for $cardUid...");

    try {
      final query = await FirebaseFirestore.instance
          .collection('student_registrations')
          .where('physicalCardUid', isEqualTo: cardUid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // ❌ ERROR: Admin hasn't registered this card yet
        setState(() {
          _statusMessage = "❌ Card not found.\nPlease ask Admin to register this card first.";
          _nameController.clear();
          _studentIdController.clear();
          _courseController.clear();
          _physicalCardUid = null; // Prevent submission
        });
      } else {
        final data = query.docs.first.data();
        
        // 🔒 SECURITY CHECK: Is this card already taken?
        if (data['deviceId'] != null) {
           setState(() {
             _statusMessage = "⛔ SECURITY ALERT: This card is already registered to another phone.";
             _physicalCardUid = null; // Block access
           });
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Card already used on another device!"), backgroundColor: Colors.red),
           );
           return;
        }

        // ✅ Success: Auto-fill details
        setState(() {
          _nameController.text = data['name'] ?? '';
          _studentIdController.text = data['studentId'] ?? '';
          _courseController.text = data['course'] ?? '';
          _selectedCourse = data['course'];
          
          _statusMessage = "✅ Card Verified! Click Activate to finish.";
        });
      }
    } catch (e) {
      setState(() => _statusMessage = "❌ Database Error: $e");
    }
  }

// Update the _submitRequest function
  Future<void> _submitRequest() async {
    if (_physicalCardUid == null) return;

    setState(() {
      _isWriting = true;
      _statusMessage = 'Activating Card...';
    });

    try {
      String deviceId = await _getDeviceId();
      final studentId = _studentIdController.text.trim();

      // Find the Admin's record
      final query = await FirebaseFirestore.instance
          .collection('student_registrations')
          .where('physicalCardUid', isEqualTo: _physicalCardUid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        String docId = query.docs.first.id;
        
        // 1. Prepare updates
        final updates = {
          'isActive': true,
          'deviceId': deviceId,
          'activatedAt': DateTime.now(), // This is a DateTime
        };

        // 2. Update Firestore
        await FirebaseFirestore.instance
            .collection('student_registrations')
            .doc(docId)
            .update(updates);

        // 3. Save local session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_student_id', studentId);

        // ---------------------------------------------------------
        // 🔧 FIX: Get data and use the sanitizer function
        // ---------------------------------------------------------
        Map<String, dynamic> rawData = query.docs.first.data();
        
        // Merge the new updates into rawData so the local file is fresh
        rawData['isActive'] = true;
        rawData['deviceId'] = deviceId;
        rawData['activatedAt'] = updates['activatedAt'];

        // ✨ MAGIC LINE: This cleans ALL timestamps automatically
        final safeData = _sanitizeForLocalSave(rawData);

        // 4. Save to storage
        await CardStorageService.saveVirtualCard(
            cardData: safeData, 
            physicalCardUid: _physicalCardUid!,
            studentId: studentId
        );

        // 5. Success!
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyVirtualCard()),
          );
        }
      } else {
        setState(() {
           _isWriting = false; 
           _statusMessage = "❌ Error: Registration not found.";
        });
      }
    } catch (e) {
      print("Error in submit: $e");
      setState(() { _isWriting = false; _statusMessage = "Error: $e"; });
    }
  }

  bool get _phoneHasCard {
    return _allCards.isNotEmpty || _hasExistingVirtualCard;
  }

  Future<void> _saveToLocalAndNavigate(Map<String, dynamic> data) async {
    try {
      // -------------------------------------------------------
      // 🔧 FIX: Convert all Timestamps to Strings before saving
      // -------------------------------------------------------
      Map<String, dynamic> safeData = Map<String, dynamic>.from(data);

      // Check specific timestamp fields and convert them
      if (safeData['registeredAt'] is Timestamp) {
        safeData['registeredAt'] = (safeData['registeredAt'] as Timestamp).toDate().toIso8601String();
      }
      if (safeData['activatedAt'] is Timestamp) {
        safeData['activatedAt'] = (safeData['activatedAt'] as Timestamp).toDate().toIso8601String();
      }
      if (safeData['createdAt'] is Timestamp) {
        safeData['createdAt'] = (safeData['createdAt'] as Timestamp).toDate().toIso8601String();
      }

      // Now save the "safe" version
      await CardStorageService.saveVirtualCard(
        cardData: safeData,
        physicalCardUid: safeData['physicalCardUid'],
        studentId: safeData['studentId'],
      );

      // Navigate to virtual card screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyVirtualCard()),
        );
      }
    } catch (e) {
      print('Error saving to local: $e');
      if (mounted) {
        setState(() {
          _status = 'initial';
          _statusMessage = "Error saving card: $e";
        });
      }
    }
  }

  Map<String, dynamic> _sanitizeForLocalSave(Map<String, dynamic> data) {
    final Map<String, dynamic> cleanData = {};
    
    data.forEach((key, value) {
      if (value is Timestamp) {
        cleanData[key] = value.toDate().toIso8601String();
      } else if (value is DateTime) {
        cleanData[key] = value.toIso8601String();
      } else if (value is Map) {
        cleanData[key] = _sanitizeForLocalSave(Map<String, dynamic>.from(value));
      } else {
        cleanData[key] = value;
      }
    });
    
    return cleanData;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Handle different statuses
    switch (_status) {
      case 'pending':
        return _buildPendingScreen();
      case 'approved':
        return const Center(child: CircularProgressIndicator()); // Redirecting...
      default:
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              "Student Virtual Card",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.blue.shade700,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _buildMainContent(),
        );
    }
  }

  Widget _buildPendingScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context), // Goes back to Home
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "Waiting for Approval", 
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Your request has been sent to the admin. Please wait for them to approve your card.", 
                textAlign: TextAlign.center
              ),
            ),
            ElevatedButton(
              onPressed: _checkExistingRequestStatus, 
              child: const Text("Refresh Status")
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_phoneHasCard) {
      return _buildPhoneHasCardWarning();
    } else if (_physicalCardUid == null) {
      return _buildScanPhase();
    } else {
      return _buildRegistrationForm();
    }
  }

  // ✅ Step 1: Scan Phase
  Widget _buildScanPhase() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Card Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100, width: 2),
              ),
              child: const Icon(
                Icons.credit_card,
                size: 60,
                color: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              "Scan Physical Card",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              "Hold your student ID card near the back of your phone to scan",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Scan Button
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.nfc,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    _isScanning ? 'Scanning...' : 'Tap to Scan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : _scanPhysicalCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isScanning
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Scanning...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.nfc, size: 20),
                                SizedBox(width: 8),
                                Text('Scan Card'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Status Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusMessage.contains('✅')
                    ? Colors.green.shade50
                    : _statusMessage.contains('❌')
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusMessage.contains('✅')
                      ? Colors.green.shade100
                      : _statusMessage.contains('❌')
                        ? Colors.red.shade100
                        : Colors.blue.shade100,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusMessage.contains('✅')
                        ? Icons.check_circle
                        : _statusMessage.contains('❌')
                          ? Icons.error
                          : Icons.info,
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : _statusMessage.contains('❌')
                          ? Colors.red
                          : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Step 2: Registration Form
  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 4,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              "Verify Your Details",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              "Review and confirm your information",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Scanned Card Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.nfc, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Scanned',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UID: ${_physicalCardUid!.substring(0, min(12, _physicalCardUid!.length))}...',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Monospace',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  _buildFormField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Student ID Field
                  _buildFormField(
                    label: 'Student ID',
                    controller: _studentIdController,
                    icon: Icons.badge,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your student ID'
                        : null,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Course Dropdown
                  _buildCourseDropdown(),
                  
                  const SizedBox(height: 40),
                  
                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isWriting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isWriting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Submit for approval',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isWriting ? null : () {
                        setState(() {
                          _physicalCardUid = null;
                          _statusMessage = 'Tap to scan your card';
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Rescan Card',
                        style: GoogleFonts.poppins(
                          color: Colors.blue.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildCourseDropdown() {
    // ✅ FIX: Match this list EXACTLY with your Admin Registration screen
    const List<String> validCourses = [
      'Computer Science',
      'Information Technology',
      'Software Engineering', // <--- Added this to match Admin
    ];

    // Safety Check: Prevents the red screen crash
    final bool isValueValid = _selectedCourse != null && validCourses.contains(_selectedCourse);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course/Program',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          // ✅ SAFE VALUE: uses null if the value isn't in the list
          value: isValueValid ? _selectedCourse : null,
          
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.school, color: Color.fromARGB(255, 49, 133, 207)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
          items: validCourses.map((course) {
            return DropdownMenuItem(
              value: course,
              child: Text(course),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCourse = value;
              _courseController.text = value ?? '';
            });
          },
          validator: (value) => value == null || value.isEmpty
              ? 'Please select your course'
              : null,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
}
  // ✅ Warning when phone already has a card
  Widget _buildPhoneHasCardWarning() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade100, width: 2),
            ),
            child: Icon(
              Icons.credit_card,
              size: 60,
              color: Colors.orange.shade600,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            "Virtual Card Found",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            "This phone already has a virtual card.\n"
            "You can view or manage your existing card.",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyVirtualCard()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: Text(
                'View My Card',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Go Back',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
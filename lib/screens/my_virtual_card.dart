import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

// Import necessary internal components
import '../services/card_registry_service.dart'; 
import '../models/student_model.dart';          
import 'nfc_scan_screen.dart'; 
import 'student_card_screen.dart'; 
import '../services/card_storage_service.dart'; 

// Note: Direct FirebaseFirestore import and usage removed as CardRegistryService
// manages persistence via SharedPreferences.

class MyVirtualCard extends StatefulWidget {
  final VoidCallback? onTabSelected;

  const MyVirtualCard({super.key, this.onTabSelected});

  @override
  State<MyVirtualCard> createState() => _MyVirtualCardState();
}

class _MyVirtualCardState extends State<MyVirtualCard> with WidgetsBindingObserver {
  String? _studentUid;
  Map<String, dynamic>? _studentData;
  bool _isLoading = true;

  final List<List<Color>> _cardGradients = [
    [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)], // 0: Royal Purple
    [const Color(0xFF000428), const Color(0xFF004e92)], // 1: Midnight Blue
    [const Color(0xFF11998e), const Color(0xFF38ef7d)], // 2: Fresh Mint
    [const Color(0xFFcb2d3e), const Color(0xFFef473a)], // 3: Fire Red
    [const Color(0xFF232526), const Color(0xFF414345)], // 4: Sleek Black
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStudentData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.onTabSelected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadStudentData();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStudentData();
    }
  }

  // Public method to reload data
  void reloadData() {
    print('🔄 MyVirtualCard: Manual reload triggered');
    _loadStudentData();
  }

  // Adjusted loading logic to rely solely on SharedPreferences, matching the final service layer.
  Future<void> _loadStudentData() async {
    print('🔄 MyVirtualCard: _loadStudentData called');
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final prefs = await SharedPreferences.getInstance();

    // 1. Try to load the currently active virtual card data
    final cardDataJson = prefs.getString('virtual_card_current');
    final studentUid = prefs.getString('student_uid');

    if (cardDataJson != null && studentUid != null) {
      try {
        final decodedData = json.decode(cardDataJson) as Map<String, dynamic>;
        
        // Sanity check if the data contains core fields
        if (decodedData.containsKey('name') && decodedData.containsKey('studentId')) {
          if (mounted) {
            setState(() {
              _studentUid = studentUid;
              _studentData = decodedData;
              _isLoading = false;
            });
          }
          print('✅ MyVirtualCard: SUCCESS - Loaded from virtual_card_current');
          return;
        }
      } catch (e) {
        print('❌ MyVirtualCard: Local storage parse error: $e');
      }
    }

    // 2. If initial load fails, clean up state
    if (mounted) {
      setState(() {
        _isLoading = false;
        _studentData = null;
        _studentUid = null;
      });
    }
    print('❌ MyVirtualCard: FAILED - No valid card found in local storage.');
  }


// In my_virtual_card.dart

void _handleDeleteCard() async {
  // 1. Show Confirmation Dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove Card?'),
      content: const Text(
        'This will remove the virtual card from this phone.\n\n'
        'You will need to scan your physical card again to access it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  // 2. Show Loading Indicator
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Removing card...')),
  );

  try {
    // 3. Call the SAFE Service (Local delete only)
    await CardStorageService.deleteVirtualCard();

    // 4. THE FIX: Navigate to "Start" Screen and clear history
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const StudentCardScreen()),
        (route) => false, // This removes the "Black Screen" history
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

  Future<void> _debugStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    print('🔍 DEBUG STORAGE:');
    print('📋 All keys: $keys');
    
    final studentUid = prefs.getString('student_uid');
    print('📱 student_uid: $studentUid');
    
    final virtualCardKeys = keys.where((key) => key.startsWith('virtual_card_')).toList();
    print('🎫 virtual_card keys: $virtualCardKeys');
    
    for (final key in virtualCardKeys) {
      final data = prefs.getString(key);
      print('📄 $key: $data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'My Virtual Card',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              reloadData();
            },
            tooltip: 'Refresh Card',
          ),
        ],
      ),
      body: _buildVirtualCardView(),
    );
  }

 Widget _buildNoCardView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.purple.shade600,
            Colors.purple.shade900,
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.credit_card_off, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 32),
              
              Text(
                "No Virtual Card Found",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                "Create your virtual card to start using NFC attendance.\nEach phone can only store ONE virtual card.",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigates to the creation flow (StudentCardScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentCardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 5,
                  ),
                  child: const Text('Create Virtual Card'),
                ),
              ),
              const SizedBox(height: 20),
              
              // Additional info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You need to scan your physical student card first to create a virtual card',
                        style: GoogleFonts.lato(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Added padding for debug button
              OutlinedButton(
                onPressed: _debugStorage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Show Debug Storage'),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildVirtualCardView() {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade600,
              Colors.purple.shade900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Loading your virtual card...',
                style: GoogleFonts.lato(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_studentData == null) {
      return _buildNoCardView();
    }

    // CRITICAL: Load the skin index from the SAVED student data (which was set during creation)
    final int skinIndex = _studentData!['skinIndex'] ?? 0;
    
    // Ensure index is safe
    final safeIndex = skinIndex.clamp(0, _cardGradients.length - 1);
    final List<Color> currentGradient = _cardGradients[safeIndex];

    return RefreshIndicator(
      onRefresh: _loadStudentData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          // Padding bottom 100 to clear the main StudentHomePage floating bar.
          padding: const EdgeInsets.only(bottom: 100), 
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.purple.shade600,
                Colors.purple.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Virtual Card Display (Person A's card style)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.purple.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 45,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    // ignore: deprecated_member_use
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.memory,
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.8),
                                      size: 24,
                                    ),
                                  ),
                                ),
                                Icon(Icons.wifi, color: Colors.white.withOpacity(0.6), size: 28),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Student Information
                            Text(
                              _studentData!['name'] ?? 'Unknown Name',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 16),

                            Text(
                              'Student ID: ${_studentData!['studentId'] ?? 'Unknown'}',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Course: ${_studentData!['course'] ?? 'Unknown'}',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // NFC ID / Physical Card UID (Masked)
                            Text(
                              'NFC ID: ${_studentData!['physicalCardUid']?.substring(0, 8) ?? 'Unknown'}...',
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 12,
                                color: Colors.green.shade200,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Active Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                // ignore: deprecated_member_use
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green.shade200, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Virtual Card Active',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Instructions Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.nfc, size: 40, color: Colors.blue.shade600),
                          const SizedBox(height: 16),
                          Text(
                            'How to use for attendance:',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Lecturer starts scanning on their phone\n'
                            '2. Tap your phone on lecturer\'s phone\n'
                            '3. Your virtual card will be read automatically',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons 
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NFCScanScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Test NFC Scan'),
                      ),
                      OutlinedButton(
                        onPressed: _handleDeleteCard,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Delete Card'),
                      ),
                      OutlinedButton(
                        onPressed: _debugStorage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Show Debug Storage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
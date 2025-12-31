import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'welcome.dart';
import 'fade_page_route.dart';
import 'student_nfc_page.dart';
import 'student_security_page.dart';
import 'student_scan_activity_page.dart';
import 'screens/my_virtual_card.dart';
import 'screens/student_card_screen.dart';
import '../services/card_storage_service.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  // --- REAL STATE VARIABLES ---
  bool _hasVirtualCard = false;
  Map<String, dynamic>? _virtualCardData;
  bool _isLoadingCard = false;
  bool _hasShowedNoCardWarning = false;

  // --- CUSTOMIZATION STATE (From Demo) ---
  Color _cardColor = const Color(0xFF4A00E0); // Default Purple
  bool _useGradient = true;

  // Rainbow Palette
  final List<Color> _rainbowColors = [
    const Color(0xFF4A00E0), // Original Purple
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    // Load card immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVirtualCard();
    });
  }

  // --- 1. LOAD DATA LOGIC ---
  Future<void> _loadVirtualCard() async {
    setState(() => _isLoadingCard = true);

    try {
      var result = await CardStorageService.loadVirtualCard();

      // If no card locally, try repair from Firestore
      if (!result.hasCard && result.studentUid != null) {
        result = await _repairCardData(result.studentUid!);
      }

      if (mounted) {
        setState(() {
          _virtualCardData = result.cardData;
          _hasVirtualCard = result.hasCard;
          _isLoadingCard = false;

          // RESTORE SAVED COLOR PREFERENCES
          if (_virtualCardData != null) {
            if (_virtualCardData!['cardColor'] != null) {
              _cardColor = Color(_virtualCardData!['cardColor']);
            }
            if (_virtualCardData!['useGradient'] != null) {
              _useGradient = _virtualCardData!['useGradient'];
            }
          }
        });
      }

      if (!result.hasCard && !_hasShowedNoCardWarning) {
        _hasShowedNoCardWarning = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No virtual card found. Create one now!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCard = false);
    }
  }

  Future<({Map<String, dynamic>? cardData, bool hasCard, String? studentUid})>
  _repairCardData(String studentUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentUid)
          .get();
      if (doc.exists && doc.data() != null) {
        final cardData = doc.data()!;
        await CardStorageService.saveVirtualCard(
          cardData: cardData,
          physicalCardUid: cardData['physicalCardUid'] ?? '',
          studentId: cardData['studentId'] ?? '',
        );
        return (cardData: cardData, hasCard: true, studentUid: studentUid);
      }
    } catch (e) {
      print('Repair failed: $e');
    }
    return (cardData: null, hasCard: false, studentUid: studentUid);
  }

  // --- 2. SAVE CUSTOMIZATION LOGIC ---
  Future<void> _saveCardCustomization() async {
    if (_virtualCardData == null) return;

    try {
      // Create updated map
      final updatedData = Map<String, dynamic>.from(_virtualCardData!);

      // Save Color as Integer and Gradient as Bool
      updatedData['cardColor'] = _cardColor.value;
      updatedData['useGradient'] = _useGradient;
      updatedData['updatedAt'] = DateTime.now().toIso8601String();

      // Save to Storage
      await CardStorageService.saveVirtualCard(
        cardData: updatedData,
        physicalCardUid: updatedData['physicalCardUid'] ?? '',
        studentId: updatedData['studentId'] ?? '',
      );

      // Save to SharedPrefs for MyVirtualCard page to read easily
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('virtual_card_current', json.encode(updatedData));

      setState(() {
        _virtualCardData = updatedData;
      });
    } catch (e) {
      print("Error saving color: $e");
    }
  }

  Future<void> _createVirtualCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentCardScreen()),
    );
    if (result == true) {
      await _loadVirtualCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: _loadVirtualCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // --- HEADER ---
              _buildProfileHeader(),

              // --- CONTENT ---
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 1. THE VIRTUAL CARD (Interactive)
                      if (_isLoadingCard)
                        const ShimmerBox(width: double.infinity, height: 220)
                      else if (_hasVirtualCard)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyVirtualCard(),
                              ),
                            );
                          },
                          child:
                              _buildVirtualCard(), // Uses the fancy demo design
                        )
                      else
                        _buildCreateCardButton(),

                      const SizedBox(height: 30),

                      // 2. RAINBOW COLOR PICKER (Only if card exists)
                      if (_hasVirtualCard) ...[
                        _buildSectionTitle("Customize Card Skin"),
                        _buildCardCustomizer(), // The widget you liked!
                        const SizedBox(height: 30),
                      ],

                      // 3. SETTINGS
                      _buildSectionTitle("Device & Account"),
                      _buildMenuTile(
                        icon: Icons.nfc_rounded,
                        title: "NFC Sensitivity",
                        subtitle: "Calibrate for faster scanning",
                        onTap: () => Navigator.push(
                          context,
                          FadePageRoute(page: const StudentNfcPage()),
                        ),
                      ),
                      _buildMenuTile(
                        icon: Icons.lock_outline,
                        title: "Security",
                        subtitle: "Biometrics & App Lock",
                        onTap: () => Navigator.push(
                          context,
                          FadePageRoute(page: const StudentSecurityPage()),
                        ),
                      ),
                      _buildMenuTile(
                        icon: Icons.history_rounded,
                        title: "Scan Activity",
                        subtitle: "View recent device handshakes",
                        onTap: () => Navigator.push(
                          context,
                          FadePageRoute(page: const StudentScanActivityPage()),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 4. LOGOUT
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              FadePageRoute(page: const WelcomeScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.red.shade100),
                            ),
                          ),
                          child: Text(
                            "Log Out",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    final name = _virtualCardData?['name'] ?? 'Student';
    final id = _virtualCardData?['studentId'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 80, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3436),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/300?img=12',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (id.isNotEmpty)
            Text(
              id,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateCardButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.add_card_rounded, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(
            "No Card Found",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _createVirtualCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Create Student Card"),
          ),
        ],
      ),
    );
  }

  // --- THE FANCY CARD WIDGET (Ported from Demo but using REAL DATA) ---
  Widget _buildVirtualCard() {
    BoxDecoration cardDecoration;

    if (_useGradient) {
      cardDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardColor,
            HSVColor.fromColor(_cardColor)
                .withValue(0.8)
                .withHue((HSVColor.fromColor(_cardColor).hue + 20) % 360)
                .toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(
            color: _cardColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
    } else {
      cardDecoration = BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(
            color: _cardColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
    }

    // Use Real Data
    final name = _virtualCardData?['name'] ?? "STUDENT NAME";
    final id = _virtualCardData?['studentId'] ?? "XXXXXXX";

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                // ignore: deprecated_member_use
                child: Center(
                  child: Icon(
                    Icons.memory,
                    color: Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
              ),
              // ignore: deprecated_member_use
              Icon(Icons.wifi, color: Colors.white.withOpacity(0.6), size: 28),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id,
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "STUDENT NAME",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        name.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "VALID THRU",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "12/26",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- THE RAINBOW PICKER (Ported from Demo) ---
  Widget _buildCardCustomizer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Solid vs Gradient Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Effect Style",
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Solid",
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: !_useGradient ? Colors.black : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: _useGradient,
                    activeThumbColor: _cardColor,
                    onChanged: (val) {
                      setState(() => _useGradient = val);
                      _saveCardCustomization(); // Save immediately
                    },
                  ),
                  Text(
                    "Gradient",
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: _useGradient ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 20),

          // 2. Rainbow Color Picker
          Text(
            "Base Color",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _rainbowColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                Color c = _rainbowColors[index];
                bool isSelected = _cardColor.value == c.value;
                return GestureDetector(
                  onTap: () {
                    setState(() => _cardColor = c);
                    _saveCardCustomization(); // Save immediately
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          // ignore: deprecated_member_use
                          BoxShadow(
                            color: c.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.purple.shade400, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 0.6).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

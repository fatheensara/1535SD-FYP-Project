import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome.dart';
import 'fade_page_route.dart';
import 'student_nfc_page.dart'; // <--- Import NFC Page
import 'student_security_page.dart'; // <--- Import Security Page
import 'student_scan_activity_page.dart'; // <--- Import Scan Page

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  // State for selected card design
  int _selectedSkinIndex = 0;

  // Available Card Designs (Gradients)
  final List<List<Color>> _cardGradients = [
    [
      const Color(0xFF4A00E0),
      const Color(0xFF8E2DE2),
    ], // Royal Purple (Default)
    [const Color(0xFF000428), const Color(0xFF004e92)], // Midnight Blue
    [const Color(0xFF11998e), const Color(0xFF38ef7d)], // Fresh Mint
    [const Color(0xFFcb2d3e), const Color(0xFFef473a)], // Fire Red
    [const Color(0xFF232526), const Color(0xFF414345)], // Sleek Black
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        // Extra padding at bottom for floating nav bar
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // --- 1. HEADER (Simple Avatar) ---
            _buildProfileHeader(),

            // --- 2. VIRTUAL ID CARD SECTION ---
            Transform.translate(
              offset: const Offset(0, -40), // Pull card up to overlap header
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // The Card Itself
                    _buildVirtualCard(),

                    const SizedBox(height: 30),

                    // --- 3. CUSTOMIZATION OPTIONS ---
                    _buildSectionTitle("Customize Card Skin"),
                    _buildSkinSelector(),

                    const SizedBox(height: 30),

                    // --- 4. SETTINGS MENU ---
                    _buildSectionTitle("Device & Account"),

                    _buildMenuTile(
                      icon: Icons.nfc_rounded,
                      title: "NFC Sensitivity",
                      subtitle: "Calibrate for faster scanning",
                      onTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(page: const StudentNfcPage()),
                        );
                      },
                    ),
                    _buildMenuTile(
                      icon: Icons.lock_outline,
                      title: "Security",
                      subtitle: "Biometrics & App Lock",
                      onTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(page: const StudentSecurityPage()),
                        );
                      },
                    ),
                    _buildMenuTile(
                      icon: Icons.history_rounded,
                      title: "Scan Activity",
                      subtitle: "View recent device handshakes",
                      onTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(page: const StudentScanActivityPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // --- 5. LOGOUT BUTTON ---
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
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 80, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3436), // Dark background for contrast
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/300?img=12',
            ), // Mock Img
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            "Student Profile",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualCard() {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cardGradients[_selectedSkinIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _cardGradients[_selectedSkinIndex][0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Chip + NFC Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mock Chip
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
                  // ignore: deprecated_member_use
                  child: Icon(
                    Icons.memory,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
              ),
              // ignore: deprecated_member_use
              Icon(Icons.wifi, color: Colors.white.withOpacity(0.6), size: 28),
            ],
          ),

          // Student Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "211XXXX", // Matric ID
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
                        "Nurul Iman", // Mock Name
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

  Widget _buildSkinSelector() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cardGradients.length,
        // ignore: unnecessary_underscores
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          bool isSelected = _selectedSkinIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSkinIndex = index;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _cardGradients[index],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: isSelected
                    ? Border.all(color: Colors.purple.shade900, width: 3)
                    : null,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
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

  // --- UPDATED MENU TILE: ACCEPTS ONTAP ---
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
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
        onTap: onTap, // Hooked up the onTap
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome.dart';
import 'fade_page_route.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. DARK BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- PROFILE HEADER ---
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.cyanAccent, Colors.purpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.purpleAccent.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFF0F0C29),
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/300?img=11',
                            ), // Mock ID
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Dr. Takumi Sase",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Senior Lecturer • Dept of Computer Science",
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // STATS ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStat("Classes", "3"),
                            _buildDivider(),
                            _buildStat("Students", "142"),
                            _buildDivider(),
                            _buildStat("Rating", "4.8"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SETTINGS SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ACCOUNT SETTINGS",
                          style: GoogleFonts.lato(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingsTile(
                          Icons.person_outline,
                          "Personal Information",
                          "Update name & contact",
                        ),
                        _buildSettingsTile(
                          Icons.notifications_none,
                          "Notifications",
                          "Manage alerts & emails",
                        ),
                        _buildSettingsTile(
                          Icons.lock_outline,
                          "Privacy & Security",
                          "Biometrics & Password",
                        ),
                        _buildSettingsTile(
                          Icons.language,
                          "Language",
                          "English (US)",
                        ),

                        const SizedBox(height: 30),

                        Text(
                          "SUPPORT",
                          style: GoogleFonts.lato(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSettingsTile(
                          Icons.help_outline,
                          "Help Center",
                          "FAQ & Guides",
                        ),
                        _buildSettingsTile(
                          Icons.info_outline,
                          "About AttenDID",
                          "Version 1.0.0",
                        ),

                        const SizedBox(height: 40),

                        // --- LOGOUT BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                FadePageRoute(page: const WelcomeScreen()),
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.white12);
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(color: Colors.white38, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white24,
        ),
        onTap: () {},
      ),
    );
  }
}

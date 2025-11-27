import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentSecurityPage extends StatefulWidget {
  const StudentSecurityPage({super.key});

  @override
  State<StudentSecurityPage> createState() => _StudentSecurityPageState();
}

class _StudentSecurityPageState extends State<StudentSecurityPage> {
  bool _biometricEnabled = true;
  bool _appLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "Security",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle("Access Control"),
          _buildSwitchTile(
            Icons.fingerprint,
            "Biometric Login",
            "Use FaceID or Fingerprint to sign in",
            _biometricEnabled,
            (val) => setState(() => _biometricEnabled = val),
          ),
          _buildSwitchTile(
            Icons.lock_clock_outlined,
            "App Lock Timeout",
            "Lock app immediately when closed",
            _appLockEnabled,
            (val) => setState(() => _appLockEnabled = val),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle("Credentials"),
          _buildActionTile(
            Icons.password,
            "Change Password",
            "Last changed 30 days ago",
          ),
          _buildActionTile(
            Icons.pin,
            "Change PIN",
            "Used for high-value transactions",
          ),

          const SizedBox(height: 30),
          _buildSectionTitle("Devices"),
          _buildActionTile(
            Icons.devices,
            "Trusted Devices",
            "iPhone 13 Pro, iPad Air",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
        trailing: Switch(
          value: value,
          // ignore: deprecated_member_use
          activeColor: Colors.blue,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.grey.shade700, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}

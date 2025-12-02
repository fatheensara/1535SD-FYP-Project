// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  // State variables for toggles
  bool _systemMaintenance = false;
  bool _allowNewRegistrations = true;
  bool _emailNotifications = true;
  bool _twoFactorAuth = true;

  @override
  Widget build(BuildContext context) {
    // Note: Background is provided by the parent AdminHomePage stack
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                "System Configuration",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Manage global parameters & security",
                style: GoogleFonts.lato(fontSize: 14, color: Colors.tealAccent),
              ),
              const SizedBox(height: 30),

              // SECTIONS
              _buildSectionHeader("General"),
              _buildSwitchTile(
                "Maintenance Mode",
                "Suspend all non-admin access",
                _systemMaintenance,
                (val) => setState(() => _systemMaintenance = val),
                Icons.build_circle_outlined,
                activeColor: Colors.orangeAccent,
              ),
              _buildSwitchTile(
                "Allow New Registrations",
                "Enable sign-ups for staff/students",
                _allowNewRegistrations,
                (val) => setState(() => _allowNewRegistrations = val),
                Icons.person_add_alt_1_outlined,
              ),

              const SizedBox(height: 25),
              _buildSectionHeader("Security & Access"),
              _buildSwitchTile(
                "Force 2FA",
                "Require Two-Factor Authentication for admins",
                _twoFactorAuth,
                (val) => setState(() => _twoFactorAuth = val),
                Icons.security_outlined,
                activeColor: Colors.redAccent,
              ),
              _buildActionTile(
                "Password Policy",
                "Configure complexity requirements",
                Icons.password,
                () {},
              ),
              _buildActionTile(
                "Session Timeout",
                "Set auto-logout duration (Current: 30m)",
                Icons.timer_outlined,
                () {},
              ),

              const SizedBox(height: 25),
              _buildSectionHeader("Notifications"),
              _buildSwitchTile(
                "System Alerts",
                "Receive critical emails",
                _emailNotifications,
                (val) => setState(() => _emailNotifications = val),
                Icons.notifications_active_outlined,
              ),

              const SizedBox(height: 25),
              _buildSectionHeader("Data Management"),
              _buildActionTile(
                "Backup Database",
                "Last backup: 2 hours ago",
                Icons.cloud_upload_outlined,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Backup started...")),
                  );
                },
                iconColor: Colors.tealAccent,
              ),
              _buildActionTile(
                "System Logs",
                "View activity history",
                Icons.list_alt_outlined,
                () {},
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  "AttenDID Admin Console v2.1.0",
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lato(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon, {
    Color activeColor = Colors.tealAccent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(color: Colors.white54, fontSize: 12),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: activeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: activeColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = Colors.blueAccent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white24,
        ),
      ),
    );
  }
}

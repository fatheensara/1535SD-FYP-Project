import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fade_page_route.dart'; // REQUIRED
import 'staff_forgot_password_page.dart'; // REQUIRED

class StaffProfileSettingsPage extends StatefulWidget {
  final String currentName;
  final String currentRole;
  final String currentDept;

  const StaffProfileSettingsPage({
    super.key,
    required this.currentName,
    required this.currentRole,
    required this.currentDept,
  });

  @override
  State<StaffProfileSettingsPage> createState() =>
      _StaffProfileSettingsPageState();
}

class _StaffProfileSettingsPageState extends State<StaffProfileSettingsPage> {
  // Text Controllers
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _deptController;
  final TextEditingController _emailController = TextEditingController(
    text: "andi.fitriah@iium.edu.my",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "+60 12-345 6789",
  );

  // Toggle States
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _roleController = TextEditingController(text: widget.currentRole);
    _deptController = TextEditingController(text: widget.currentDept);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _deptController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // Return updated data to the previous screen
    Navigator.pop(context, {
      'name': _nameController.text,
      'role': _roleController.text,
      'department': _deptController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings Saved Successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: PROFILE INFO ---
              _buildSectionHeader("Profile Information"),
              const SizedBox(height: 15),
              _buildTextField(
                "Full Name",
                _nameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Role / Position",
                _roleController,
                Icons.work_outline,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Department",
                _deptController,
                Icons.business_outlined,
              ),

              const SizedBox(height: 30),

              // --- SECTION 2: CONTACT ---
              _buildSectionHeader("Contact Details"),
              const SizedBox(height: 15),
              _buildTextField(
                "Email Address",
                _emailController,
                Icons.email_outlined,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Phone Number",
                _phoneController,
                Icons.phone_outlined,
              ),

              const SizedBox(height: 30),

              // --- SECTION 3: PREFERENCES & SECURITY ---
              _buildSectionHeader("Preferences & Security"),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      "Push Notifications",
                      "Receive updates about leave & courses",
                      _notificationsEnabled,
                      (val) => setState(() => _notificationsEnabled = val),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildSwitchTile(
                      "Biometric Login",
                      "Use FaceID / Fingerprint",
                      _biometricEnabled,
                      (val) => setState(() => _biometricEnabled = val),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildSwitchTile(
                      "Dark Mode",
                      "Switch app theme",
                      _darkMode,
                      (val) => setState(() => _darkMode = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Change Password Button (UPDATED)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to Forgot Password Page
                    Navigator.push(
                      context,
                      FadePageRoute(page: const StaffForgotPasswordPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF4A00E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Change Password",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A00E0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),

      // Floating Save Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: _saveSettings,
            backgroundColor: const Color(0xFF4A00E0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            label: Text(
              "Save Changes",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            icon: const Icon(Icons.save_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.lato(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: Colors.grey.shade500),
          prefixIcon: Icon(
            icon,
            // ignore: deprecated_member_use
            color: const Color(0xFF4A00E0).withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF4A00E0),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade500),
      ),
    );
  }
}

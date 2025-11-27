import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_hello.dart';
import 'staff_hello.dart';
import 'admin_hello.dart';

// Import your new custom fade transition
import 'fade_page_route.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 1. The Gradient Background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700, // Blue
              Colors.purple.shade600, // Purple
              Colors.purple.shade900, // Dark Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Spacer to push content down from the status bar
                const Spacer(flex: 2),

                // 2. The Welcome Text
                Text(
                  "Hello! Welcome back to",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  "AttenDID!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Spacer to separate text from buttons
                const Spacer(flex: 3),

                // 3. The Clickable Buttons

                // STUDENT Button
                RoleButton(
                  icon: Icons.person_outline,
                  label: "STUDENT",
                  onPressed: () {
                    // 2. Use FadePageRoute
                    Navigator.push(
                      context,
                      FadePageRoute(
                        page: const StudentHelloPage(),
                      ), // <-- Changed
                    );
                  },
                ),

                const SizedBox(height: 16), // Spacing
                // STAFF Button
                RoleButton(
                  icon: Icons.badge_outlined,
                  label: "STAFF",
                  onPressed: () {
                    // 3. Use FadePageRoute
                    Navigator.push(
                      context,
                      FadePageRoute(
                        page: const StaffHelloPage(),
                      ), // <-- Changed
                    );
                  },
                ),

                const SizedBox(height: 16), // Spacing
                // ADMIN Button
                RoleButton(
                  icon: Icons.admin_panel_settings_outlined,
                  label: "ADMIN",
                  onPressed: () {
                    // 4. Use FadePageRoute
                    Navigator.push(
                      context,
                      FadePageRoute(
                        page: const AdminHelloPage(),
                      ), // <-- Changed
                    );
                  },
                ),

                // Spacer to add padding at the bottom
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A helper widget to create the styled buttons, to avoid repeating code
class RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  // ignore: use_super_parameters
  const RoleButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Button interior color
        // ignore: deprecated_member_use
        backgroundColor: Colors.white.withOpacity(0.95),
        // Text and icon color
        foregroundColor: Colors.purple.shade900,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

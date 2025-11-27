import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentNfcPage extends StatefulWidget {
  const StudentNfcPage({super.key});

  @override
  State<StudentNfcPage> createState() => _StudentNfcPageState();
}

class _StudentNfcPageState extends State<StudentNfcPage> {
  double _sensitivity = 0.7; // 0.0 to 1.0
  bool _hapticFeedback = true;
  bool _backgroundScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          "NFC Settings",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SIGNAL STRENGTH CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.nfc, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NFC Sensor Active",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Signal Strength: Strong",
                          style: GoogleFonts.lato(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- SENSITIVITY SLIDER ---
            Text(
              "Scanning Sensitivity",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Short Range",
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Long Range",
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sensitivity,
                    activeColor: Colors.purple,
                    inactiveColor: Colors.purple.shade100,
                    onChanged: (val) {
                      setState(() => _sensitivity = val);
                    },
                  ),
                  Text(
                    "Current Level: ${(_sensitivity * 100).toInt()}%",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- TOGGLES ---
            Text(
              "Preferences",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _buildToggleTile(
              "Haptic Feedback",
              "Vibrate when connection is established",
              _hapticFeedback,
              (val) => setState(() => _hapticFeedback = val),
            ),
            _buildToggleTile(
              "Background Scanning",
              "Allow scanning while app is minimized (Uses more battery)",
              _backgroundScanning,
              (val) => setState(() => _backgroundScanning = val),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Test signal sent!")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: Colors.purple.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Test Sensor Connection",
                  style: GoogleFonts.poppins(color: Colors.purple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
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
      child: SwitchListTile(
        value: value,
        // ignore: deprecated_member_use
        activeColor: Colors.purple,
        onChanged: onChanged,
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

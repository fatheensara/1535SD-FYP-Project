import 'dart:ui'; // Required for Glassmorphism
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Required for Fonts
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../student_home_page.dart'; 
import '../fade_page_route.dart';

class StudentSetupScreen extends StatefulWidget {
  final bool isFromGoogle;
  
  // Added isFromGoogle to constructor
  const StudentSetupScreen({super.key, this.isFromGoogle = false});

  @override
  _StudentSetupScreenState createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final _matricController = TextEditingController();
  String _status = "";
  bool _isLoading = false;

  Future<void> _linkAccount() async {
    setState(() { _isLoading = true; _status = "Searching database..."; });

    // FIX 1: FORCE UPPERCASE to match database format
    String matricInput = _matricController.text.trim().toUpperCase();
    print("DEBUG: Searching for studentId: '$matricInput'");

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _status = "❌ You are not logged in.");
      return;
    }

    try {
      // 1. Search in the CORRECT collection
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('student_registrations') 
          .where('studentId', isEqualTo: matricInput) 
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _status = "❌ Matric '$matricInput' not found.\nCheck spelling.";
        });
        return;
      }

      // 2. Found the document!
      DocumentSnapshot doc = query.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      
      // 3. Check if already claimed
      if (data.containsKey('uid') && data['uid'] != null && data['uid'] != "") {
         if (data['uid'] != currentUser.uid) {
             setState(() {
              _isLoading = false;
              _status = "❌ This ID is already owned by another user!";
             });
             return;
         }
      }

      // 4. Link Success!
      await FirebaseFirestore.instance
          .collection('student_registrations')
          .doc(doc.id)
          .update({
            'uid': currentUser.uid, 
            'email': currentUser.email,
            'linkedAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        _isLoading = false;
        _status = "✅ Success! Profile Linked.";
      });

      // 5. Navigate to Home
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
             context,
             FadePageRoute(page: const StudentHomePage()), 
             (route) => false,
          );
        });
      }

    } catch (e) {
      print("DEBUG ERROR: $e");
      setState(() {
        _isLoading = false;
        _status = "❌ System Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Link Profile", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND
          _buildBackground(),

          // 2. GLASS CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.link_rounded, size: 60, color: Colors.white),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Dynamic Text based on Source
                  Text(
                    widget.isFromGoogle ? "Google Sign-In Successful!" : "One-Time Setup",
                    style: GoogleFonts.poppins(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isFromGoogle 
                        ? "Please link your Matric Number to finish setting up your account."
                        : "Enter your Matric No to link your app account\nto your student records.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Glass Form
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          // ignore: deprecated_member_use
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildGlassTextField(
                              controller: _matricController,
                              hint: "e.g. 2212186",
                              icon: Icons.badge_outlined,
                            ),
                            
                            const SizedBox(height: 30),
                            
                            if (_isLoading) 
                              const CircularProgressIndicator(color: Colors.white) 
                            else 
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _linkAccount,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.purple.shade900,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    "ACTIVATE PROFILE", 
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    )
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status Message
                  if (_status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _status, 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold, 
                          color: _status.contains("❌") ? Colors.red.shade300 : Colors.green.shade300
                        )
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

  // --- MISSING HELPER METHODS ADDED BELOW ---

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            const Color(0xFF6A0572), // Deep Purple
            Colors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Blob 1 Top Right
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.blue.shade600.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.blue.shade600.withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // Blob 2 Center Left
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ignore: deprecated_member_use
                color: Colors.purple.shade600.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.purple.shade600.withOpacity(0.3),
                    blurRadius: 100,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.lato(color: Colors.white),
        decoration: InputDecoration(
          labelText: "Matric Number",
          labelStyle: GoogleFonts.lato(color: Colors.white70),
          hintText: hint,
          hintStyle: GoogleFonts.lato(color: Colors.white30),
          prefixIcon: Icon(icon, color: Colors.white70, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
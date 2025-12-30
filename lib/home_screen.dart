import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import 'student_home_page.dart'; 
import 'staff_home.dart';
import 'screens/admin_registration_screen.dart';
import '../services/auth_service.dart';
import '../models/student_model.dart';

class HomeScreen extends StatelessWidget {
  final String userRole;

  const HomeScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, show the appropriate home page
        if (snapshot.hasData && snapshot.data != null) {
          if (userRole == 'staff') {
            return const StaffHomePage();
          } else if (userRole == 'admin') {
            return const AdminRegistrationScreen();
          } else {
            return const StudentHomePage();
          }
        }

        // If user is not authenticated, IMMEDIATELY show the appropriate screen
        // Don't wait for Firebase - just use the provided userRole
        if (userRole == 'staff') {
          return const StaffHomePage();
        } else if (userRole == 'admin') {
          return const AdminRegistrationScreen();
        } else {
          return const StudentHomePage();
        }
      },
    );
  }
}
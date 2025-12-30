// Create this file to debug navigation issues
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Screen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
            child: const Text('Test Welcome Screen'),
          ),
          // Add more test buttons for each screen
        ],
      ),
    );
  }
}
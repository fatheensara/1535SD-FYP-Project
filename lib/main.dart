import 'package:flutter/material.dart';

import 'welcome.dart'; // <-- Import your welcome screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttenDID',
      theme: ThemeData(primarySwatch: Colors.purple),
      // Set the home property to your new WelcomeScreen
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const LenslyApp());
}

class LenslyApp extends StatelessWidget {
  const LenslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lensly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEDEAE4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D3530),
        ),
      ),
      home: const HomeScreen(),
            );
    
  }
}
import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(const ProRentApp());
}

class ProRentApp extends StatelessWidget {
  const ProRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProRent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF161B22),
          elevation: 2,
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'home_page.dart';

void main() {
  runApp(const RoutinyApp());
}

class RoutinyApp extends StatelessWidget {
  const RoutinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routiny Manager',
      theme: AppTheme.darkTheme, // تفعيل الثيم المطور
      home: const HomePage(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart'; // استيراد شاشة الانطلاق

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoutinyApp());
}

class RoutinyApp extends StatelessWidget {
  const RoutinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routiny Pro Max',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFC0C0C0),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        // استخدام الخط الاحترافي بدون ملفات خارجية لضمان نجاح البناء
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
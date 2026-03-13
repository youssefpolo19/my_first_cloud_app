import 'package:flutter/material.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6A1B9A), // الأرجواني الملكي
        scaffoldBackgroundColor: Colors.black, // الأسود الفخم
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routiny Manager'),
        backgroundColor: const Color(0xFF6A1B9A),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 100, color: Color(0xFF6A1B9A)),
            const SizedBox(height: 20),
            const Text(
              'أهلاً بك  يوسف في تطبيقك الجديد',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text('جاري بناء نسخة الويب بنجاح...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
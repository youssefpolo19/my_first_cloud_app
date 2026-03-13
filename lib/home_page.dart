import 'package:flutter/material.dart';
import 'app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routiny'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("أهلاً، يوسف 👋", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("إليك ملخص إنتاجيتك لليوم", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            
            // قسم البطاقات الإحصائية
            Row(
              children: [
                _buildStatCard("مكتملة", "08", AppTheme.primaryPurple),
                const SizedBox(width: 15),
                _buildStatCard("متبقية", "03", Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 35),
            
            const Text("المهام الحالية", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            _buildModernTask("برمجة واجهة التطبيق", "منذ ساعتين", Icons.auto_awesome),
            _buildModernTask("مراجعة دروس المحاسبة", "منذ 4 ساعات", Icons.menu_book_rounded),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppTheme.primaryPurple,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTask(String title, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryPurple, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.check_circle_outline, color: Colors.white24),
        ],
      ),
    );
  }
}
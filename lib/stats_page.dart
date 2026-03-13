import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const StatsPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    int completed = tasks.where((t) => t['isDone'] == true).length;
    int pending = tasks.length - completed;
    double progress = tasks.isEmpty ? 0 : completed / tasks.length;

    return Scaffold(
      appBar: AppBar(title: const Text("تحليل الأداء"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: Colors.white10,
              color: const Color(0xFFC0C0C0),
            ),
            const SizedBox(height: 30),
            _buildStatTile("المهام المكتملة", completed.toString(), Colors.greenAccent),
            _buildStatTile("المهام المتبقية", pending.toString(), Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
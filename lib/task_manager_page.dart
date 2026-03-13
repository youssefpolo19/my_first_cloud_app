import 'package:flutter/material.dart';

class TaskManagerPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String userName;
  final VoidCallback onToggle;
  final Function(int) onDelete;
  final Function(String, String) onAdd;

  const TaskManagerPage({super.key, required this.tasks, required this.userName, required this.onToggle, required this.onDelete, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("أهلاً بك، $userName"), backgroundColor: Colors.transparent),
      body: tasks.isEmpty 
          ? const Center(child: Text("لا توجد مهام حالياً"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(tasks[index]['title']),
                leading: Checkbox(value: tasks[index]['isDone'], onChanged: (v) { tasks[index]['isDone'] = v; onToggle(); }),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(index)),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAdd("مهمة جديدة", "متوسط"),
        child: const Icon(Icons.add),
      ),
    );
  }
}
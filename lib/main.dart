import 'package:flutter/material.dart';

void main() => runApp(const RoutinyApp());

class RoutinyApp extends StatelessWidget {
  const RoutinyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routiny Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6A1B9A),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  // قائمة المهام الأولية
  final List<String> _tasks = ["الاستيقاظ مبكراً", "مراجعة كود فلاتر"];
  final TextEditingController _taskController = TextEditingController();

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("إضافة مهمة جديدة", style: TextStyle(color: Color(0xFF9C27B0))),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "ماذا تريد أن تفعل؟",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6A1B9A))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                setState(() {
                  _tasks.add(_taskController.text);
                  _taskController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routiny Manager'),
        backgroundColor: const Color(0xFF6A1B9A),
        centerTitle: true,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text("لا توجد مهام حالياً"))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.circle_outlined, color: Color(0xFF9C27B0)),
                    title: Text(_tasks[index], style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => setState(() => _tasks.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
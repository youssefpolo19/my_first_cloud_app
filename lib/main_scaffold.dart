import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task_manager_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _tasks = [];
  String _userName = "يوسف";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    String? savedName = prefs.getString('userName');
    if (tasksJson != null) setState(() => _tasks = List<Map<String, dynamic>>.from(json.decode(tasksJson)));
    if (savedName != null) setState(() => _userName = savedName);
  }

  _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask(String title, String priority) {
    setState(() => _tasks.insert(0, {"title": title, "isDone": false, "priority": priority}));
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TaskManagerPage(tasks: _tasks, userName: _userName, onToggle: _saveTasks, onDelete: _deleteTask, onAdd: _addTask),
      StatsPage(tasks: _tasks),
      SettingsPage(userName: _userName, onNameChanged: (name) => setState(() => _userName = name), onClearData: () => setState(() => _tasks.clear())),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFC0C0C0),
        backgroundColor: const Color(0xFF0D0D0D),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'الإحصائيات'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
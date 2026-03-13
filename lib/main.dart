import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(android: androidSettings));
  }
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
        cardColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
        fontFamily: 'SF Pro',
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// 1. شاشة الانطلاق
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScaffold()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(
                '''<svg width="120" height="120" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="10" y="10" width="80" height="80" rx="20" stroke="#C0C0C0" stroke-width="4"/><path d="M30 50L45 65L70 35" stroke="#C0C0C0" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/></svg>''',
                width: 120, height: 120,
              ),
              const SizedBox(height: 30),
              const Text("Routiny Pro", style: TextStyle(fontSize: 28, color: Color(0xFFC0C0C0), fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 10),
              const Text("Ultimate CEO Edition", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. الهيكل الرئيسي وإدارة الحالة (State)
// ==========================================
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

  _saveName(String newName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', newName);
    setState(() => _userName = newName);
  }

  void _addTask(String title, String priority) {
    setState(() => _tasks.insert(0, {"title": title, "isDone": false, "priority": priority}));
    _saveTasks();
    if (!kIsWeb) _showNotification(title);
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
    _saveTasks();
  }

  void _clearAllData() {
    setState(() => _tasks.clear());
    _saveTasks();
  }

  void _showNotification(String taskTitle) async {
    const AndroidNotificationDetails androidSpecs = AndroidNotificationDetails('routiny_channel', 'Tasks', importance: Importance.max, priority: Priority.high);
    await flutterLocalNotificationsPlugin.show(0, 'مهمة جديدة تمت إضافتها', taskTitle, const NotificationDetails(android: androidSpecs));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TaskManagerPage(tasks: _tasks, userName: _userName, onToggle: _saveTasks, onDelete: _deleteTask, onAdd: _addTask),
      StatsPage(tasks: _tasks),
      SettingsPage(userName: _userName, onNameChanged: _saveName, onClearData: _clearAllData),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFC0C0C0),
          unselectedItemColor: Colors.white24,
          backgroundColor: const Color(0xFF0D0D0D),
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'الإحصائيات'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. صفحة المهام المتطورة
// ==========================================
class TaskManagerPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final String userName;
  final VoidCallback onToggle;
  final Function(int) onDelete;
  final Function(String, String) onAdd;

  const TaskManagerPage({super.key, required this.tasks, required this.userName, required this.onToggle, required this.onDelete, required this.onAdd});

  Color _getPriorityColor(String priority) {
    if (priority == 'عالي') return Colors.redAccent;
    if (priority == 'متوسط') return Colors.orangeAccent;
    return Colors.green;
  }

  void _showAddDialog(BuildContext context) {
    String newTitle = "";
    String selectedPriority = "متوسط";
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("إضافة مهمة استراتيجية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              TextField(
                autofocus: true, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "اكتب المهمة هنا...", hintStyle: TextStyle(color: Colors.white24), border: OutlineInputBorder()),
                onChanged: (val) => newTitle = val,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['عالي', 'متوسط', 'عادي'].map((p) => ChoiceChip(
                  label: Text(p), selected: selectedPriority == p,
                  selectedColor: _getPriorityColor(p).withOpacity(0.3),
                  onSelected: (val) => setStateSheet(() => selectedPriority = p),
                )).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0C0C0), minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  if (newTitle.isNotEmpty) {
                    onAdd(newTitle, selectedPriority);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("حفظ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC0C0C0),
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0, pinned: true, backgroundColor: const Color(0xFF0D0D0D),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("أهلاً بك، $userName", style: const TextStyle(color: Color(0xFFC0C0C0), fontWeight: FontWeight.bold)),
              background: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2A2A), Color(0xFF0D0D0D)]))),
            ),
          ),
          tasks.isEmpty 
            ? SliverFillRemaining(child: Center(child: Text("يوم جديد، إنجازات جديدة! أضف مهمتك الأولى.", style: TextStyle(color: Colors.grey[700]))))
            : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = tasks[index];
                  return Dismissible(
                    key: Key(task['title'] + index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                      color: Colors.redAccent, child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => onDelete(index),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      color: const Color(0xFF1A1A1A), elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white10)),
                      child: ListTile(
                        leading: Checkbox(
                          value: task['isDone'], activeColor: const Color(0xFFC0C0C0), checkColor: Colors.black,
                          onChanged: (val) { task['isDone'] = val; onToggle(); },
                        ),
                        title: Text(task['title'], style: TextStyle(decoration: task['isDone'] ? TextDecoration.lineThrough : null, color: task['isDone'] ? Colors.white24 : Colors.white, fontWeight: FontWeight.w500)),
                        subtitle: Text("الأولوية: ${task['priority'] ?? 'عادي'}", style: TextStyle(color: _getPriorityColor(task['priority'] ?? 'عادي'), fontSize: 12)),
                      ),
                    ),
                  );
                }, childCount: tasks.length,
              ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. صفحة الإحصائيات (Dashboard)
// ==========================================
class StatsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const StatsPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    int total = tasks.length;
    int done = tasks.where((t) => t['isDone'] == true).length;
    double progress = total == 0 ? 0 : done / total;

    return Scaffold(
      appBar: AppBar(title: const Text("مؤشرات الأداء"), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  SizedBox(
                    width: 80, height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(value: progress, backgroundColor: Colors.white10, color: const Color(0xFFC0C0C0), strokeWidth: 8),
                        Center(child: Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("معدل الإنجاز", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text("$done من $total مهام مكتملة", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. صفحة الإعدادات (Settings)
// ==========================================
class SettingsPage extends StatelessWidget {
  final String userName;
  final Function(String) onNameChanged;
  final VoidCallback onClearData;

  const SettingsPage({super.key, required this.userName, required this.onNameChanged, required this.onClearData});

  void _editName(BuildContext context) {
    String newName = userName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A), title: const Text("تعديل الملف الشخصي", style: TextStyle(color: Colors.white)),
        content: TextField(style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "الاسم الجديد"), onChanged: (val) => newName = val),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () { onNameChanged(newName); Navigator.pop(ctx); }, child: const Text("حفظ", style: TextStyle(color: Color(0xFFC0C0C0)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.person, color: Color(0xFFC0C0C0)), title: const Text("الملف الشخصي"), subtitle: Text(userName), trailing: const Icon(Icons.edit, size: 18), onTap: () => _editName(context)),
          const Divider(color: Colors.white10),
          ListTile(leading: const Icon(Icons.notifications, color: Color(0xFFC0C0C0)), title: const Text("الإشعارات"), subtitle: const Text("مفعلة محلياً"), trailing: Switch(value: true, onChanged: (val){}, activeColor: const Color(0xFFC0C0C0))),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent), title: const Text("مسح جميع البيانات", style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A), title: const Text("تحذير", style: TextStyle(color: Colors.redAccent)),
                content: const Text("هل أنت متأكد من مسح جميع المهام؟ لا يمكن التراجع عن هذا الإجراء."),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
                  TextButton(onPressed: () { onClearData(); Navigator.pop(ctx); }, child: const Text("نعم، امسح", style: TextStyle(color: Colors.redAccent))),
                ],
              ));
            },
          ),
        ],
      ),
    );
  }
}
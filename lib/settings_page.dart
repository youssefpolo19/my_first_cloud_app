import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final String userName;
  final Function(String) onNameChanged;
  final VoidCallback onClearData;

  const SettingsPage({super.key, required this.userName, required this.onNameChanged, required this.onClearData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("اسم المستخدم"),
            subtitle: Text(userName),
            onTap: () {
              // هنا يمكنك إضافة Dialog لتغيير الاسم
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text("مسح جميع البيانات", style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              // تأكيد المسح
              onClearData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم مسح البيانات")));
            },
          ),
        ],
      ),
    );
  }
}
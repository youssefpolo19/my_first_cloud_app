import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskScreen({super.key, this.taskToEdit});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskCategory _selectedCategory = TaskCategory.personal;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedCategory = widget.taskToEdit!.category;
      _dueDate = widget.taskToEdit!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'مهمة جديدة' : 'تعديل المهمة'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان المهمة',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال العنوان' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'الوصف',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final task = Task(
        id: widget.taskToEdit?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _selectedPriority,
        category: _selectedCategory,
        dueDate: _dueDate,
      );
      
      if (widget.taskToEdit == null) {
        taskProvider.addTask(task);
      } else {
        taskProvider.updateTask(task);
      }
      Navigator.pop(context);
    }
  }
}

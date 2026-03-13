import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  Box<Task>? _taskBox;
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSortBy _sortBy = TaskSortBy.createdDate;
  String _searchQuery = '';

  List<Task> get tasks {
    List<Task> filteredTasks = _getFilteredTasks();
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply sorting
    filteredTasks = _sortTasks(filteredTasks);
    
    return filteredTasks;
  }

  List<Task> get allTasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  TaskSortBy get sortBy => _sortBy;
  String get searchQuery => _searchQuery;

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((t) => t.isDone).length;
  int get pendingTasks => _tasks.where((t) => !t.isDone).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;
  int get todayTasks => _tasks.where((t) => t.isDueToday).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / totalTasks;
  }

  // Initialize Hive and load tasks
  Future<void> initializeHive() async {
    try {
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskPriorityAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TaskCategoryAdapter());
      
      _taskBox = await Hive.openBox<Task>('tasks');
      // الإصلاح: تحديد النوع صراحةً لضمان عمله في الويب والـ APK
      _tasks = _taskBox!.values.cast<Task>().toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  // Setters
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSortBy(TaskSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // CRUD Operations
  Future<void> addTask(Task task) async {
    await _taskBox!.put(task.id, task);
    _tasks = _taskBox!.values.cast<Task>().toList();
    
    // Schedule notification if task has reminder
    if (task.hasReminder && task.reminderTime != null) {
      await NotificationService().showScheduledNotification(
        id: task.id.hashCode,
        title: 'تذكير بمهمة',
        body: task.title,
        scheduledDate: task.reminderTime!,
      );
    }
    
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await task.save();
    _tasks = _taskBox!.values.cast<Task>().toList();
    
    // Update notification
    if (task.hasReminder && task.reminderTime != null) {
      await NotificationService().showScheduledNotification(
        id: task.id.hashCode,
        title: 'تذكير بمهمة',
        body: task.title,
        scheduledDate: task.reminderTime!,
      );
    } else {
      await NotificationService().cancelNotification(task.id.hashCode);
    }
    
    notifyListeners();
  }

  Future<void> toggleTaskStatus(Task task) async {
    task.isDone = !task.isDone;
    task.completedAt = task.isDone ? DateTime.now() : null;
    await task.save();
    
    if (task.isDone) {
      await NotificationService().cancelNotification(task.id.hashCode);
    }
    
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    await NotificationService().cancelNotification(task.id.hashCode);
    await task.delete();
    _tasks = _taskBox!.values.cast<Task>().toList();
    notifyListeners();
  }

  Future<void> deleteAllTasks() async {
    await NotificationService().cancelAllNotifications();
    await _taskBox!.clear();
    _tasks = [];
    notifyListeners();
  }

  // Filtering Logic
  List<Task> _getFilteredTasks() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return List.from(_tasks);
      case TaskFilter.active:
        return _tasks.where((t) => !t.isDone).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.isDone).toList();
      case TaskFilter.today:
        return _tasks.where((t) => t.isDueToday).toList();
      case TaskFilter.overdue:
        return _tasks.where((t) => t.isOverdue).toList();
      case TaskFilter.highPriority:
        return _tasks.where((t) => t.priority == TaskPriority.high || t.priority == TaskPriority.urgent).toList();
    }
  }

  // Sorting Logic - الإصلاح الجوهري هنا
  List<Task> _sortTasks(List<Task> taskList) {
    switch (_sortBy) {
      case TaskSortBy.createdDate:
        taskList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortBy.dueDate:
        taskList.sort((a, b) {
          // استخدام Casting صريح لتجنب خطأ Object? في GitHub Actions
          final taskA = a as Task;
          final taskB = b as Task;
          if (taskA.dueDate == null && taskB.dueDate == null) return 0;
          if (taskA.dueDate == null) return 1;
          if (taskB.dueDate == null) return -1;
          return taskA.dueDate!.compareTo(taskB.dueDate!);
        });
        break;
      case TaskSortBy.priority:
        taskList.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case TaskSortBy.title:
        taskList.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return taskList;
  }

  // Helper Methods
  List<Task> getTasksByCategory(TaskCategory category) {
    return _tasks.where((t) => t.category == category).toList();
  }

  List<Task> getTasksForToday() {
    return _tasks.where((t) => t.isDueToday).toList();
  }

  List<Task> getTasksForWeek() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(now) && t.dueDate!.isBefore(weekFromNow);
    }).toList();
  }

  Map<TaskPriority, int> getTasksByPriorityCount() {
    Map<TaskPriority, int> counts = {
      TaskPriority.low: 0,
      TaskPriority.medium: 0,
      TaskPriority.high: 0,
      TaskPriority.urgent: 0,
    };
    for (var task in _tasks) {
      counts[task.priority] = (counts[task.priority] ?? 0) + 1;
    }
    return counts;
  }
}

enum TaskFilter { all, active, completed, today, overdue, highPriority }
enum TaskSortBy { createdDate, dueDate, priority, title }
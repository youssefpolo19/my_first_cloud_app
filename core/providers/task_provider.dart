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
  double get completionRate => _tasks.isEmpty ? 0 : (completedTasks / totalTasks) * 100;

  // Category Statistics
  Map<TaskCategory, int> get tasksByCategory {
    Map<TaskCategory, int> categoryMap = {};
    for (var category in TaskCategory.values) {
      categoryMap[category] = _tasks.where((t) => t.category == category).length;
    }
    return categoryMap;
  }

  // Priority Statistics
  Map<TaskPriority, int> get tasksByPriority {
    Map<TaskPriority, int> priorityMap = {};
    for (var priority in TaskPriority.values) {
      priorityMap[priority] = _tasks.where((t) => t.priority == priority && !t.isDone).length;
    }
    return priorityMap;
  }

  Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskCategoryAdapter());
    }
    
    _taskBox = await Hive.openBox<Task>('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    if (_taskBox != null) {
      _tasks = _taskBox!.values.toList();
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    if (_taskBox != null) {
      await _taskBox!.put(task.id, task);
      _tasks.add(task);
      
      // Schedule notification if reminder is set
      if (task.hasReminder && task.reminderTime != null) {
        await NotificationService().scheduleNotification(
          id: task.id.hashCode,
          title: 'تذكير: ${task.title}',
          body: task.description.isNotEmpty ? task.description : 'حان وقت إنجاز هذه المهمة',
          scheduledDate: task.reminderTime!,
        );
      }
      
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    if (_taskBox != null) {
      await _taskBox!.put(task.id, task);
      int index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        
        // Update notification
        if (task.hasReminder && task.reminderTime != null) {
          await NotificationService().scheduleNotification(
            id: task.id.hashCode,
            title: 'تذكير: ${task.title}',
            body: task.description.isNotEmpty ? task.description : 'حان وقت إنجاز هذه المهمة',
            scheduledDate: task.reminderTime!,
          );
        } else {
          await NotificationService().cancelNotification(task.id.hashCode);
        }
        
        notifyListeners();
      }
    }
  }

  Future<void> toggleTask(String taskId) async {
    int index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      Task task = _tasks[index];
      Task updatedTask = task.copyWith(
        isDone: !task.isDone,
        completedAt: !task.isDone ? DateTime.now() : null,
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_taskBox != null) {
      await _taskBox!.delete(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      
      // Cancel notification
      await NotificationService().cancelNotification(taskId.hashCode);
      
      notifyListeners();
    }
  }

  Future<void> deleteAllTasks() async {
    if (_taskBox != null) {
      await _taskBox!.clear();
      _tasks.clear();
      await NotificationService().cancelAllNotifications();
      notifyListeners();
    }
  }

  Future<void> deleteCompletedTasks() async {
    if (_taskBox != null) {
      List<Task> completedTasksList = _tasks.where((t) => t.isDone).toList();
      for (var task in completedTasksList) {
        await _taskBox!.delete(task.id);
        await NotificationService().cancelNotification(task.id.hashCode);
      }
      _tasks.removeWhere((t) => t.isDone);
      notifyListeners();
    }
  }

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

  List<Task> _getFilteredTasks() {
    switch (_currentFilter) {
      case TaskFilter.all:
        return List.from(_tasks);
      case TaskFilter.active:
        return _tasks.where((t) => !t.isDone).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.isDone).toList();
      case TaskFilter.today:
        return _tasks.where((t) => t.isDueToday && !t.isDone).toList();
      case TaskFilter.overdue:
        return _tasks.where((t) => t.isOverdue).toList();
      case TaskFilter.high:
        return _tasks.where((t) => t.priority == TaskPriority.high || t.priority == TaskPriority.urgent).toList();
    }
  }

  List<Task> _sortTasks(List<Task> taskList) {
    switch (_sortBy) {
      case TaskSortBy.createdDate:
        taskList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortBy.dueDate:
        taskList.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
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
}

enum TaskFilter {
  all,
  active,
  completed,
  today,
  overdue,
  high,
}

enum TaskSortBy {
  createdDate,
  dueDate,
  priority,
  title,
}

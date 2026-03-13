import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  TaskPriority priority;

  @HiveField(5)
  TaskCategory category;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? dueDate;

  @HiveField(8)
  DateTime? completedAt;

  @HiveField(9)
  List<String> tags;

  @HiveField(10)
  bool hasReminder;

  @HiveField(11)
  DateTime? reminderTime;

  @HiveField(12)
  String? notes;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    DateTime? createdAt,
    this.dueDate,
    this.completedAt,
    List<String>? tags,
    this.hasReminder = false,
    this.reminderTime,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        tags = tags ?? [];

  Task copyWith({
    String? title,
    String? description,
    bool? isDone,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? tags,
    bool? hasReminder,
    DateTime? reminderTime,
    String? notes,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueSoon {
    if (dueDate == null || isDone) return false;
    final diff = dueDate!.difference(DateTime.now());
    return diff.inHours > 0 && diff.inHours <= 24;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'priority': priority.index,
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isDone: json['isDone'] ?? false,
      priority: TaskPriority.values[json['priority'] ?? 1],
      category: TaskCategory.values[json['category'] ?? 0],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      hasReminder: json['hasReminder'] ?? false,
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
      notes: json['notes'],
    );
  }
}

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 2)
enum TaskCategory {
  @HiveField(0)
  personal,
  
  @HiveField(1)
  work,
  
  @HiveField(2)
  shopping,
  
  @HiveField(3)
  health,
  
  @HiveField(4)
  finance,
  
  @HiveField(5)
  education,
  
  @HiveField(6)
  social,
  
  @HiveField(7)
  other,
}

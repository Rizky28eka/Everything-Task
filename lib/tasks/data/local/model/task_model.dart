import 'package:task_manager/tasks/data/local/model/sub_task_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';

class TaskModel {
  String id;
  String title;
  String description;
  DateTime? startDateTime;
  DateTime? stopDateTime;
  bool completed;
  TaskPriority priority;
  List<SubTaskModel> subtasks;
  List<String> categoryIds;
  bool reminder;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.stopDateTime,
    this.completed = false,
    this.priority = TaskPriority.medium,
    this.subtasks = const [],
    this.categoryIds = const [],
    this.reminder = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'startDateTime': startDateTime?.toIso8601String(),
      'stopDateTime': stopDateTime?.toIso8601String(),
      'priority': priority.name,
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'categoryIds': categoryIds,
      'reminder': reminder,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      startDateTime: DateTime.parse(json['startDateTime']),
      stopDateTime: DateTime.parse(json['stopDateTime']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((subtaskJson) => SubTaskModel.fromJson(subtaskJson))
          .toList(),
      categoryIds: (json['categoryIds'] as List<dynamic>? ?? []).cast<String>(),
      reminder: json['reminder'] ?? false,
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, description: $description, '
        'startDateTime: $startDateTime, stopDateTime: $stopDateTime, '
        'completed: $completed, priority: $priority, subtasks: $subtasks, categoryIds: $categoryIds, reminder: $reminder}';
  }
}

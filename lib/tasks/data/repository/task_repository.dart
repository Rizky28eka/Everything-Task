import 'package:task_manager/notifications/notification_service.dart';
import 'package:task_manager/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/task_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';

class TaskRepository {
  final TaskDataProvider taskDataProvider;
  final NotificationService notificationService;

  TaskRepository({
    required this.taskDataProvider,
    required this.notificationService,
  });

  Future<List<TaskModel>> getTasks() async {
    return await taskDataProvider.getTasks();
  }

  Future<void> createNewTask(TaskModel taskModel) async {
    await taskDataProvider.createTask(taskModel);
    if (taskModel.reminder) {
      await notificationService.scheduleNotification(taskModel);
    }
  }

  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    await notificationService.cancelNotification(taskModel);
    if (taskModel.reminder) {
      await notificationService.scheduleNotification(taskModel);
    }
    return await taskDataProvider.updateTask(taskModel);
  }

  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    final tasks = await taskDataProvider.deleteTask(taskModel);
    await notificationService.cancelNotification(taskModel);
    return tasks;
  }

  Future<List<TaskModel>> sortTasks(int sortOption) async {
    return await taskDataProvider.sortTasks(sortOption);
  }

  Future<List<TaskModel>> searchTasks(String search) async {
    return await taskDataProvider.searchTasks(search);
  }

  Future<List<CategoryModel>> getCategories() async {
    return await taskDataProvider.getCategories();
  }

  Future<void> createCategory(CategoryModel category) async {
    return await taskDataProvider.createCategory(category);
  }

  Future<List<CategoryModel>> updateCategory(CategoryModel category) async {
    return await taskDataProvider.updateCategory(category);
  }

  Future<List<CategoryModel>> deleteCategory(CategoryModel category) async {
    return await taskDataProvider.deleteCategory(category);
  }

  Future<List<TaskModel>> filterTasks({
    TaskPriority? priority,
    String? categoryId,
  }) async {
    return await taskDataProvider.filterTasks(
      priority: priority,
      categoryId: categoryId,
    );
  }
}

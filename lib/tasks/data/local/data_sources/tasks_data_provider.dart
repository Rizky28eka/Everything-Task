import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/task_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';
import 'package:task_manager/utils/exception_handler.dart';

import '../../../../utils/constants.dart';

class TaskDataProvider {
  List<TaskModel> tasks = [];
  List<CategoryModel> categories = [];
  SharedPreferences? prefs;

  TaskDataProvider(this.prefs);

  Future<List<TaskModel>> getTasks() async {
    try {
      final List<String>? savedTasks = prefs!.getStringList(Constants.taskKey);
      if (savedTasks != null) {
        tasks = savedTasks
            .map((taskJson) => TaskModel.fromJson(json.decode(taskJson)))
            .toList();
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
      }
      return tasks;
    }catch(e){
      throw Exception(handleException(e));
    }
  }

  Future<List<TaskModel>> sortTasks(int sortOption) async {
    switch (sortOption) {
      case 0:
        tasks.sort((a, b) {
          // Sort by date
          if (a.startDateTime!.isAfter(b.startDateTime!)) {
            return 1;
          } else if (a.startDateTime!.isBefore(b.startDateTime!)) {
            return -1;
          }
          return 0;
        });
        break;
      case 1:
        //sort by completed tasks
        tasks.sort((a, b) {
          if (!a.completed && b.completed) {
            return 1;
          } else if (a.completed && !b.completed) {
            return -1;
          }
          return 0;
        });
        break;
      case 2:
      //sort by pending tasks
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
        break;
      case 3:
        //sort by priority
        tasks.sort((a, b) {
          return b.priority.index.compareTo(a.priority.index);
        });
        break;
    }
    return tasks;
  }

  Future<void> createTask(TaskModel taskModel) async {
    try {
      tasks.add(taskModel);
      final List<String> taskJsonList =
          tasks.map((task) => json.encode(task.toJson())).toList();
      await prefs!.setStringList(Constants.taskKey, taskJsonList);
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    try {
      tasks[tasks.indexWhere((element) => element.id == taskModel.id)] =
          taskModel;
      tasks.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    try {
      tasks.remove(taskModel);
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> searchTasks(String keywords) async {
    var searchText = keywords.toLowerCase();
    List<TaskModel> matchedTasked = tasks;
    return matchedTasked.where((task) {
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final List<String>? savedCategories = prefs!.getStringList(Constants.categoryKey);
      if (savedCategories != null) {
        categories = savedCategories
            .map((categoryJson) => CategoryModel.fromJson(json.decode(categoryJson)))
            .toList();
      }
      return categories;
    } catch (e) {
      throw Exception(handleException(e));
    }
  }

  Future<void> createCategory(CategoryModel category) async {
    try {
      categories.add(category);
      final List<String> categoryJsonList =
          categories.map((cat) => json.encode(cat.toJson())).toList();
      await prefs!.setStringList(Constants.categoryKey, categoryJsonList);
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<CategoryModel>> updateCategory(CategoryModel category) async {
    try {
      categories[categories.indexWhere((element) => element.id == category.id)] =
          category;
      final List<String> categoryJsonList = categories.map((cat) =>
          json.encode(cat.toJson())).toList();
      prefs!.setStringList(Constants.categoryKey, categoryJsonList);
      return categories;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<CategoryModel>> deleteCategory(CategoryModel category) async {
    try {
      categories.remove(category);
      final List<String> categoryJsonList = categories.map((cat) =>
          json.encode(cat.toJson())).toList();
      prefs!.setStringList(Constants.categoryKey, categoryJsonList);
      return categories;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> filterTasks({
    TaskPriority? priority,
    String? categoryId,
  }) async {
    List<TaskModel> filteredTasks = await getTasks();
    if (priority != null) {
      filteredTasks = filteredTasks.where((task) => task.priority == priority).toList();
    }
    if (categoryId != null) {
      filteredTasks = filteredTasks.where((task) => task.categoryIds.contains(categoryId)).toList();
    }
    return filteredTasks;
  }
}

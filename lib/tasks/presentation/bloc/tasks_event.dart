part of 'tasks_bloc.dart';

@immutable
sealed class TasksEvent {}

class AddNewTaskEvent extends TasksEvent {
  final TaskModel taskModel;

  AddNewTaskEvent({required this.taskModel});
}

class FetchTaskEvent extends TasksEvent {}

class SortTaskEvent extends TasksEvent {
  final int sortOption;

  SortTaskEvent({required this.sortOption});
}

class UpdateTaskEvent extends TasksEvent {
  final TaskModel taskModel;

  UpdateTaskEvent({required this.taskModel});
}

class DeleteTaskEvent extends TasksEvent {
  final TaskModel taskModel;

  DeleteTaskEvent({required this.taskModel});
}

class SearchTaskEvent extends TasksEvent{
  final String keywords;

  SearchTaskEvent({required this.keywords});
}

class FetchCategoriesEvent extends TasksEvent {}

class AddCategoryEvent extends TasksEvent {
  final CategoryModel category;

  AddCategoryEvent({required this.category});
}

class UpdateCategoryEvent extends TasksEvent {
  final CategoryModel category;

  UpdateCategoryEvent({required this.category});
}

class DeleteCategoryEvent extends TasksEvent {
  final CategoryModel category;

  DeleteCategoryEvent({required this.category});
}

class FilterTasksEvent extends TasksEvent {
  final TaskPriority? priority;
  final String? categoryId;
  final int? sortOption;

  FilterTasksEvent({
    this.priority,
    this.categoryId,
    this.sortOption,
  });
}

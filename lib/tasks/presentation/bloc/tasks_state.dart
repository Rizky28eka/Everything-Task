part of 'tasks_bloc.dart';

@immutable
sealed class TasksState {}

final class FetchTasksSuccess extends TasksState {
  final List<TaskModel> tasks;
  final List<CategoryModel> categories;
  final bool isSearching;
  final TaskPriority? selectedPriority;
  final String? selectedCategoryId;

  FetchTasksSuccess({
    required this.tasks,
    this.categories = const [],
    this.isSearching = false,
    this.selectedPriority,
    this.selectedCategoryId,
  });
}

final class AddTasksSuccess extends TasksState {}

final class LoadTaskFailure extends TasksState {
  final String error;

  LoadTaskFailure({required this.error});
}

final class AddTaskFailure extends TasksState {
  final String error;

  AddTaskFailure({required this.error});
}

final class TasksLoading extends TasksState {}

final class UpdateTaskFailure extends TasksState {
  final String error;

  UpdateTaskFailure({required this.error});
}

final class UpdateTaskSuccess extends TasksState {}

final class CategoriesLoading extends TasksState {}

final class FetchCategoriesSuccess extends TasksState {
  final List<CategoryModel> categories;

  FetchCategoriesSuccess({required this.categories});
}

final class CategoryOperationFailure extends TasksState {
  final String error;

  CategoryOperationFailure({required this.error});
}

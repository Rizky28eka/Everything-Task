import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';

import '../../data/local/model/task_model.dart';
import '../../data/repository/task_repository.dart';

part 'tasks_event.dart';

part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;

  TasksBloc(this.taskRepository) : super(FetchTasksSuccess(tasks: const [])) {
    on<AddNewTaskEvent>(_addNewTask);
    on<FetchTaskEvent>(_fetchTasks);
    on<UpdateTaskEvent>(_updateTask);
    on<DeleteTaskEvent>(_deleteTask);
    on<SortTaskEvent>(_sortTasks);
    on<SearchTaskEvent>(_searchTasks);
    on<FetchCategoriesEvent>(_fetchCategories);
    on<AddCategoryEvent>(_addCategory);
    on<UpdateCategoryEvent>(_updateCategory);
    on<DeleteCategoryEvent>(_deleteCategory);
    on<FilterTasksEvent>(_filterTasks);
  }

  _addNewTask(AddNewTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      if (event.taskModel.title.trim().isEmpty) {
        return emit(AddTaskFailure(error: 'Task title cannot be blank'));
      }
      if (event.taskModel.description.trim().isEmpty) {
        return emit(AddTaskFailure(error: 'Task description cannot be blank'));
      }
      if (event.taskModel.startDateTime == null) {
        return emit(AddTaskFailure(error: 'Missing task start date'));
      }
      if (event.taskModel.stopDateTime == null) {
        return emit(AddTaskFailure(error: 'Missing task stop date'));
      }
      await taskRepository.createNewTask(event.taskModel);
      emit(AddTasksSuccess());
      final tasks = await taskRepository.getTasks();
      final categories = await taskRepository.getCategories();
      return emit(FetchTasksSuccess(tasks: tasks, categories: categories));
    } catch (exception) {
      emit(AddTaskFailure(error: exception.toString()));
    }
  }

  void _fetchTasks(FetchTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await taskRepository.getTasks();
      final categories = await taskRepository.getCategories();
      return emit(FetchTasksSuccess(tasks: tasks, categories: categories));
    } catch (exception) {
      emit(LoadTaskFailure(error: exception.toString()));
    }
  }

  _updateTask(UpdateTaskEvent event, Emitter<TasksState> emit) async {
    try {
      if (event.taskModel.title.trim().isEmpty) {
        return emit(UpdateTaskFailure(error: 'Task title cannot be blank'));
      }
      if (event.taskModel.description.trim().isEmpty) {
        return emit(
            UpdateTaskFailure(error: 'Task description cannot be blank'));
      }
      if (event.taskModel.startDateTime == null) {
        return emit(UpdateTaskFailure(error: 'Missing task start date'));
      }
      if (event.taskModel.stopDateTime == null) {
        return emit(UpdateTaskFailure(error: 'Missing task stop date'));
      }
      emit(TasksLoading());
      final tasks = await taskRepository.updateTask(event.taskModel);
      final categories = await taskRepository.getCategories();
      emit(UpdateTaskSuccess());
      return emit(FetchTasksSuccess(tasks: tasks, categories: categories));
    } catch (exception) {
      emit(UpdateTaskFailure(error: exception.toString()));
    }
  }

  _deleteTask(DeleteTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await taskRepository.deleteTask(event.taskModel);
      final categories = await taskRepository.getCategories();
      return emit(FetchTasksSuccess(tasks: tasks, categories: categories));
    } catch (exception) {
      emit(LoadTaskFailure(error: exception.toString()));
    }
  }

  _sortTasks(SortTaskEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.sortTasks(event.sortOption);
    final categories = await taskRepository.getCategories();
    return emit(FetchTasksSuccess(tasks: tasks, categories: categories));
  }

  _searchTasks(SearchTaskEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.searchTasks(event.keywords);
    final categories = await taskRepository.getCategories();
    return emit(FetchTasksSuccess(tasks: tasks, categories: categories, isSearching: true));
  }

  void _fetchCategories(FetchCategoriesEvent event, Emitter<TasksState> emit) async {
    emit(CategoriesLoading());
    try {
      final categories = await taskRepository.getCategories();
      return emit(FetchCategoriesSuccess(categories: categories));
    } catch (exception) {
      emit(CategoryOperationFailure(error: exception.toString()));
    }
  }

  _addCategory(AddCategoryEvent event, Emitter<TasksState> emit) async {
    try {
      await taskRepository.createCategory(event.category);
      add(FetchCategoriesEvent());
    } catch (exception) {
      emit(CategoryOperationFailure(error: exception.toString()));
    }
  }

  _updateCategory(UpdateCategoryEvent event, Emitter<TasksState> emit) async {
    try {
      await taskRepository.updateCategory(event.category);
      add(FetchCategoriesEvent());
    } catch (exception) {
      emit(CategoryOperationFailure(error: exception.toString()));
    }
  }

  _deleteCategory(DeleteCategoryEvent event, Emitter<TasksState> emit) async {
    try {
      await taskRepository.deleteCategory(event.category);
      add(FetchCategoriesEvent());
    } catch (exception) {
      emit(CategoryOperationFailure(error: exception.toString()));
    }
  }

  _filterTasks(FilterTasksEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.filterTasks(
      priority: event.priority,
      categoryId: event.categoryId,
    );
    if (event.sortOption != null) {
      await taskRepository.sortTasks(event.sortOption!);
    }
    final categories = await taskRepository.getCategories();
    return emit(FetchTasksSuccess(
      tasks: tasks,
      categories: categories,
      selectedPriority: event.priority,
      selectedCategoryId: event.categoryId,
    ));
  }
}

import 'package:task_manager/analytics/analytics_screen.dart';
import 'package:task_manager/calendar/calendar_screen.dart';
import 'package:task_manager/settings/category_management_screen.dart';
import 'package:task_manager/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/routes/pages.dart';
import 'package:task_manager/splash_screen.dart';
import 'package:task_manager/tasks/data/local/model/task_model.dart';
import 'package:task_manager/tasks/presentation/pages/new_task_screen.dart';
import 'package:task_manager/tasks/presentation/pages/tasks_screen.dart';
import 'package:task_manager/tasks/presentation/pages/update_task_screen.dart';

import '../page_not_found.dart';

Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Pages.initial:
      return MaterialPageRoute(builder: (context) => const SplashScreen());
    case Pages.home:
      return MaterialPageRoute(builder: (context) => const TasksScreen());
    case Pages.createNewTask:
      return MaterialPageRoute(builder: (context) => const NewTaskScreen());
    case Pages.updateTask:
      final args = routeSettings.arguments as TaskModel;
      return MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskModel: args),
      );
    case Pages.settings:
      return MaterialPageRoute(builder: (context) => const SettingsScreen());
    case Pages.calendar:
      return MaterialPageRoute(builder: (context) => const CalendarScreen());
    case Pages.analytics:
      return MaterialPageRoute(builder: (context) => const AnalyticsScreen());
    case Pages.categoryManagement:
      return MaterialPageRoute(
        builder: (context) => const CategoryManagementScreen(),
      );
    default:
      return MaterialPageRoute(builder: (context) => const PageNotFound());
  }
}

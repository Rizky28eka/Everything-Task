import 'package:task_manager/notifications/notification_service.dart';
import 'package:task_manager/theme/dark_theme.dart';
import 'package:task_manager/theme/theme_cubit.dart';
import 'package:task_manager/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/bloc_state_observer.dart';
import 'package:task_manager/routes/app_router.dart';
import 'package:task_manager/routes/pages.dart';
import 'package:task_manager/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:task_manager/tasks/data/repository/task_repository.dart';
import 'package:task_manager/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task_manager/utils/color_palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocStateOberver();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(
    MyApp(preferences: preferences, notificationService: notificationService),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.preferences,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => TaskRepository(
            taskDataProvider: TaskDataProvider(preferences),
            notificationService: notificationService,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TasksBloc(context.read<TaskRepository>()),
          ),
          BlocProvider(create: (context) => ThemeCubit(preferences)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Task Manager',
              debugShowCheckedModeBanner: false,
              initialRoute: Pages.initial,
              onGenerateRoute: onGenerateRoute,
              theme: ThemeData(
                fontFamily: 'Sora',
                visualDensity: VisualDensity.adaptivePlatformDensity,
                canvasColor: Colors.transparent,
                colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
                useMaterial3: true,
              ),
              darkTheme: darkTheme,
              themeMode: state.themeMode,
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_manager/tasks/data/local/model/task_model.dart';
import 'package:task_manager/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task_manager/tasks/presentation/widget/task_item_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<TaskModel> _tasksForSelectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tasksForSelectedDay = [];
  }

  List<TaskModel> _getTasksForDay(DateTime day, List<TaskModel> tasks) {
    return tasks.where((task) {
      if (task.startDateTime == null || task.stopDateTime == null) {
        return false;
      }
      return (day.isAfter(task.startDateTime!) || day.isAtSameMomentAs(task.startDateTime!)) &&
             (day.isBefore(task.stopDateTime!) || day.isAtSameMomentAs(task.stopDateTime!));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is FetchTasksSuccess) {
            _tasksForSelectedDay = _getTasksForDay(_selectedDay!, state.tasks);
            return Column(
              children: [
                TableCalendar(
                  calendarFormat: _calendarFormat,
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _tasksForSelectedDay = _getTasksForDay(selectedDay, state.tasks);
                    });
                  },
                  eventLoader: (day) => _getTasksForDay(day, state.tasks),
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.week: 'Week',
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _tasksForSelectedDay.length,
                    itemBuilder: (context, index) {
                      return TaskItemView(
                        taskModel: _tasksForSelectedDay[index],
                        allCategories: state.categories,
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

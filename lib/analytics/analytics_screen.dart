import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/task_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';
import 'package:task_manager/tasks/presentation/bloc/tasks_bloc.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is FetchTasksSuccess) {
            final tasks = state.tasks;
            final categories = state.categories;

            final totalTasks = tasks.length;
            final completedTasks = tasks.where((task) => task.completed).length;

            final priorityData = _getPriorityData(tasks);
            final categoryData = _getCategoryData(tasks, categories);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text('Total Tasks: $totalTasks', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Completed Tasks: $completedTasks', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                const Text('Tasks by Priority', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(
                    sections: priorityData,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  )),
                ),
                const SizedBox(height: 24),
                const Text('Tasks by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 200,
                  child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: categoryData,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < categories.length) {
                              return Text(categories[index].name);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                  )),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<PieChartSectionData> _getPriorityData(List<TaskModel> tasks) {
    final lowPriority = tasks.where((task) => task.priority == TaskPriority.low).length;
    final mediumPriority = tasks.where((task) => task.priority == TaskPriority.medium).length;
    final highPriority = tasks.where((task) => task.priority == TaskPriority.high).length;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: lowPriority.toDouble(),
        title: 'Low',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: mediumPriority.toDouble(),
        title: 'Medium',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: highPriority.toDouble(),
        title: 'High',
        radius: 50,
      ),
    ];
  }

  List<BarChartGroupData> _getCategoryData(List<TaskModel> tasks, List<CategoryModel> categories) {
    return categories.map((category) {
      final tasksInCategory = tasks.where((task) => task.categoryIds.contains(category.id)).length;
      return BarChartGroupData(
        x: categories.indexOf(category),
        barRods: [
          BarChartRodData(toY: tasksInCategory.toDouble(), color: Colors.blue),
        ],
      );
    }).toList();
  }
}

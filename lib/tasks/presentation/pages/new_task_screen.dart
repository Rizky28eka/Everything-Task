import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/sub_task_model.dart';
import 'package:task_manager/tasks/presentation/widget/category_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_manager/components/widgets.dart';
import 'package:task_manager/tasks/data/local/model/task_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';
import 'package:task_manager/utils/font_sizes.dart';
import 'package:task_manager/utils/util.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  List<CategoryModel> _allCategories = [];
  final List<String> _selectedCategoryIds = [];
  bool _reminderEnabled = false;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void initState() {
    _selectedDay = _focusedDay;
    context.read<TasksBloc>().add(FetchCategoriesEvent());
    super.initState();
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSubtask() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  void _showCategoryDialog() async {
    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return CategorySelectionDialog(
          allCategories: _allCategories,
          selectedCategoryIds: _selectedCategoryIds,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategoryIds.clear();
        _selectedCategoryIds.addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: kWhiteColor,
        appBar: const CustomAppBar(title: 'Create New Task'),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<TasksBloc, TasksState>(
              listener: (context, state) {
                if (state is AddTaskFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(getSnackBar(state.error, kRed));
                }
                if (state is AddTasksSuccess) {
                  Navigator.pop(context);
                }
                if (state is FetchCategoriesSuccess) {
                  setState(() {
                    _allCategories = state.categories;
                  });
                }
                if (state is CategoryOperationFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(getSnackBar(state.error, kRed));
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        calendarFormat: _calendarFormat,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                          CalendarFormat.week: 'Week',
                        },
                        rangeSelectionMode: RangeSelectionMode.toggledOn,
                        focusedDay: _focusedDay,
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2030, 1, 1),
                        onPageChanged: (focusDay) {
                          _focusedDay = focusDay;
                        },
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onRangeSelected: _onRangeSelected,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withAlpha(25),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: buildText(
                          _rangeStart != null && _rangeEnd != null
                              ? 'Task starting at ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                              : 'Select a date range',
                          kPrimaryColor,
                          textSmall,
                          FontWeight.w400,
                          TextAlign.start,
                          TextOverflow.clip,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        'Title',
                        kBlackColor,
                        textMedium,
                        FontWeight.bold,
                        TextAlign.start,
                        TextOverflow.clip,
                      ),
                      const SizedBox(height: 10),
                      BuildTextField(
                        hint: "Task Title",
                        controller: title,
                        inputType: TextInputType.text,
                        fillColor: kWhiteColor,
                        onChange: (value) {},
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        'Description',
                        kBlackColor,
                        textMedium,
                        FontWeight.bold,
                        TextAlign.start,
                        TextOverflow.clip,
                      ),
                      const SizedBox(height: 10),
                      BuildTextField(
                        hint: "Task Description",
                        controller: description,
                        inputType: TextInputType.multiline,
                        fillColor: kWhiteColor,
                        onChange: (value) {},
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        'Priority',
                        kBlackColor,
                        textMedium,
                        FontWeight.bold,
                        TextAlign.start,
                        TextOverflow.clip,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<TaskPriority>(
                        value: _selectedPriority,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kWhiteColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: kGrey2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem<TaskPriority>(
                            value: priority,
                            child: Text(
                              priority.name.substring(0, 1).toUpperCase() +
                                  priority.name.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedPriority = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        'Sub-tasks',
                        kBlackColor,
                        textMedium,
                        FontWeight.bold,
                        TextAlign.start,
                        TextOverflow.clip,
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _subtaskControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: BuildTextField(
                                    hint: "Sub-task Title",
                                    controller: _subtaskControllers[index],
                                    inputType: TextInputType.text,
                                    fillColor: kWhiteColor,
                                    onChange: (value) {},
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: kRed),
                                  onPressed: () => _removeSubtask(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: kPrimaryColor),
                        label: buildText('Add Sub-task', kPrimaryColor, textSmall, FontWeight.w500, TextAlign.center, TextOverflow.clip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: kPrimaryColor),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _addSubtask,
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        'Categories',
                        kBlackColor,
                        textMedium,
                        FontWeight.bold,
                        TextAlign.start,
                        TextOverflow.clip,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _allCategories
                            .where((category) => _selectedCategoryIds.contains(category.id))
                            .map((category) => Chip(
                                  label: Text(category.name),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedCategoryIds.remove(category.id);
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: kPrimaryColor),
                        label: buildText('Add Category', kPrimaryColor, textSmall, FontWeight.w500, TextAlign.center, TextOverflow.clip),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: kPrimaryColor),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _showCategoryDialog,
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text('Set Reminder'),
                        value: _reminderEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _reminderEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  kWhiteColor,
                                ),
                                shape:
                                    WidgetStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // Adjust the radius as needed
                                      ),
                                    ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: buildText(
                                  'Cancel',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.w600,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  kPrimaryColor,
                                ),
                                shape:
                                    WidgetStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // Adjust the radius as needed
                                      ),
                                    ),
                              ),
                              onPressed: () {
                                final String taskId = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                final List<SubTaskModel> subtasks = _subtaskControllers
                                    .where((controller) => controller.text.isNotEmpty)
                                    .map((controller) => SubTaskModel(
                                          id: DateTime.now().millisecondsSinceEpoch.toString() + controller.text,
                                          title: controller.text,
                                        ))
                                    .toList();

                                var taskModel = TaskModel(
                                  id: taskId,
                                  title: title.text,
                                  description: description.text,
                                  startDateTime: _rangeStart,
                                  stopDateTime: _rangeEnd,
                                  priority: _selectedPriority,
                                  subtasks: subtasks,
                                  categoryIds: _selectedCategoryIds,
                                  reminder: _reminderEnabled,
                                );
                                context.read<TasksBloc>().add(
                                  AddNewTaskEvent(taskModel: taskModel),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: buildText(
                                  'Save',
                                  kWhiteColor,
                                  textMedium,
                                  FontWeight.w600,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

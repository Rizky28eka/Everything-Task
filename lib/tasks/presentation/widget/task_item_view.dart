import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/util.dart';
import '../../data/local/model/task_model.dart';
import '../bloc/tasks_bloc.dart';

class TaskItemView extends StatefulWidget {
  final TaskModel taskModel;
  final List<CategoryModel> allCategories;
  const TaskItemView({
    super.key,
    required this.taskModel,
    required this.allCategories,
  });

  @override
  State<TaskItemView> createState() => _TaskItemViewState();
}

class _TaskItemViewState extends State<TaskItemView> {
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return kRed;
      case TaskPriority.medium:
        return kOrange;
      case TaskPriority.low:
        return kGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskCategories = widget.allCategories
        .where((category) => widget.taskModel.categoryIds.contains(category.id))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, right: 15),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getPriorityColor(widget.taskModel.priority),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: widget.taskModel.completed,
                  onChanged: (value) {
                    var taskModel = TaskModel(
                      id: widget.taskModel.id,
                      title: widget.taskModel.title,
                      description: widget.taskModel.description,
                      completed: !widget.taskModel.completed,
                      startDateTime: widget.taskModel.startDateTime,
                      stopDateTime: widget.taskModel.stopDateTime,
                      priority: widget.taskModel.priority,
                      subtasks: widget.taskModel.subtasks,
                      categoryIds: widget.taskModel.categoryIds,
                    );
                    context.read<TasksBloc>().add(
                      UpdateTaskEvent(taskModel: taskModel),
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: buildText(
                              widget.taskModel.title,
                              kBlackColor,
                              textMedium,
                              FontWeight.w500,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                          ),
                          PopupMenuButton<int>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: kWhiteColor,
                            elevation: 1,
                            onSelected: (value) {
                              switch (value) {
                                case 0:
                                  {
                                    Navigator.pushNamed(
                                      context,
                                      Pages.updateTask,
                                      arguments: widget.taskModel,
                                    );
                                    break;
                                  }
                                case 1:
                                  {
                                    context.read<TasksBloc>().add(
                                      DeleteTaskEvent(
                                        taskModel: widget.taskModel,
                                      ),
                                    );
                                    break;
                                  }
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svgs/edit.svg',
                                        width: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      buildText(
                                        'Edit task',
                                        kBlackColor,
                                        textMedium,
                                        FontWeight.normal,
                                        TextAlign.start,
                                        TextOverflow.clip,
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svgs/delete.svg',
                                        width: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      buildText(
                                        'Delete task',
                                        kRed,
                                        textMedium,
                                        FontWeight.normal,
                                        TextAlign.start,
                                        TextOverflow.clip,
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            child: SvgPicture.asset(
                              'assets/svgs/vertical_menu.svg',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      buildText(
                        widget.taskModel.description,
                        kGrey1,
                        textSmall,
                        FontWeight.normal,
                        TextAlign.start,
                        TextOverflow.clip,
                      ),
                      if (widget.taskModel.subtasks.isNotEmpty)
                        const SizedBox(height: 10),
                      if (widget.taskModel.subtasks.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.taskModel.subtasks.length,
                          itemBuilder: (context, index) {
                            final subtask = widget.taskModel.subtasks[index];
                            return SizedBox(
                              height: 30,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: buildText(
                                  subtask.title,
                                  subtask.completed ? kGrey1 : kBlackColor,
                                  textSmall,
                                  FontWeight.normal,
                                  TextAlign.start,
                                  TextOverflow.clip,
                                ),
                                value: subtask.completed,
                                onChanged: (value) {
                                  setState(() {
                                    subtask.completed = value!;
                                  });
                                  context.read<TasksBloc>().add(
                                    UpdateTaskEvent(
                                      taskModel: widget.taskModel,
                                    ),
                                  );
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            );
                          },
                        ),
                      if (taskCategories.isNotEmpty) const SizedBox(height: 10),
                      if (taskCategories.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: taskCategories.map((category) {
                            return Chip(
                              label: Text(
                                category.name,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: kPrimaryColor.withAlpha(25),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 15),
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
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/calender.svg',
                              width: 12,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: buildText(
                                '${formatDate(dateTime: widget.taskModel.startDateTime.toString())} - ${formatDate(dateTime: widget.taskModel.stopDateTime.toString())}',
                                kBlackColor,
                                textTiny,
                                FontWeight.w400,
                                TextAlign.start,
                                TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

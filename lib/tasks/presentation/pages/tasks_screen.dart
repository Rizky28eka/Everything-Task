import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_manager/components/custom_app_bar.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';
import 'package:task_manager/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:task_manager/components/build_text_field.dart';
import 'package:task_manager/tasks/presentation/widget/filter_dialog.dart';
import 'package:task_manager/tasks/presentation/widget/task_item_view.dart';
import 'package:task_manager/utils/color_palette.dart';
import 'package:task_manager/utils/util.dart';

import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/font_sizes.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TextEditingController searchController = TextEditingController();
  TaskPriority? _selectedPriority;
  String? _selectedCategoryId;
  int? _selectedSortOption;

  @override
  void initState() {
    if (mounted) {
      context.read<TasksBloc>().add(FetchTaskEvent());
    }
    super.initState();
  }

  void _showFilterDialog(BuildContext context, FetchTasksSuccess state) async {
    final bloc = context.read<TasksBloc>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return FilterDialog(
          allCategories: state.categories,
          selectedPriority: _selectedPriority,
          selectedCategoryId: _selectedCategoryId,
          selectedSortOption: _selectedSortOption,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPriority = result['priority'];
        _selectedCategoryId = result['categoryId'];
        _selectedSortOption = result['sortOption'];
      });
      bloc.add(FilterTasksEvent(
            priority: _selectedPriority,
            categoryId: _selectedCategoryId,
            sortOption: _selectedSortOption,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: kWhiteColor,
          appBar: CustomAppBar(
            title: 'Hi Iqbal Ganteng',
            showBackArrow: false,
            actionWidgets: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Pages.analytics);
                },
                icon: const Icon(Icons.analytics),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Pages.calendar);
                },
                icon: SvgPicture.asset('assets/svgs/calender.svg'),
              ),
              BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state is FetchTasksSuccess) {
                    return IconButton(
                      onPressed: () => _showFilterDialog(context, state),
                      icon: SvgPicture.asset('assets/svgs/filter.svg'),
                    );
                  }
                  return IconButton(
                    onPressed: null,
                    icon: SvgPicture.asset('assets/svgs/filter.svg'),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Pages.settings);
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<TasksBloc, TasksState>(
                listener: (context, state) {
                  if (state is LoadTaskFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(getSnackBar(state.error, kRed));
                  }

                  if (state is AddTaskFailure || state is UpdateTaskFailure) {
                    context.read<TasksBloc>().add(FetchTaskEvent());
                  }
                },
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (state is LoadTaskFailure) {
                    return Center(
                      child: buildText(
                        state.error,
                        kBlackColor,
                        textMedium,
                        FontWeight.normal,
                        TextAlign.center,
                        TextOverflow.clip,
                      ),
                    );
                  }

                  if (state is FetchTasksSuccess) {
                    return state.tasks.isNotEmpty || state.isSearching
                        ? Column(
                            children: [
                              BuildTextField(
                                hint: "Search recent task",
                                controller: searchController,
                                inputType: TextInputType.text,
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: kGrey2,
                                ),
                                fillColor: kWhiteColor,
                                onChange: (value) {
                                  context.read<TasksBloc>().add(
                                    SearchTaskEvent(keywords: value),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: state.tasks.length,
                                  itemBuilder: (context, index) {
                                    return TaskItemView(
                                      taskModel: state.tasks[index],
                                      allCategories: state.categories,
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                        return const Divider(color: kGrey3);
                                      },
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svgs/tasks.svg',
                                  height: size.height * .20,
                                  width: size.width,
                                ),
                                const SizedBox(height: 50),
                                buildText(
                                  'Schedule your tasks',
                                  kBlackColor,
                                  textBold,
                                  FontWeight.w600,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                                buildText(
                                  'Manage your task schedule easily\nand efficiently',
                                  kBlackColor.withAlpha(128),
                                  textSmall,
                                  FontWeight.normal,
                                  TextAlign.center,
                                  TextOverflow.clip,
                                ),
                              ],
                            ),
                          );
                  }
                  return Container();
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_circle, color: kPrimaryColor),
            onPressed: () {
              Navigator.pushNamed(context, Pages.createNewTask);
            },
          ),
        ),
      ),
    );
  }
}

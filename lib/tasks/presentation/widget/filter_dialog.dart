import 'package:flutter/material.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/data/local/model/task_priority.dart';

class FilterDialog extends StatefulWidget {
  final List<CategoryModel> allCategories;
  final TaskPriority? selectedPriority;
  final String? selectedCategoryId;
  final int? selectedSortOption;

  const FilterDialog({
    super.key,
    required this.allCategories,
    this.selectedPriority,
    this.selectedCategoryId,
    this.selectedSortOption,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TaskPriority? _selectedPriority;
  late String? _selectedCategoryId;
  late int? _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.selectedPriority;
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedSortOption = widget.selectedSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter & Sort'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sort by'),
            DropdownButton<int>(
              value: _selectedSortOption,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Date')),
                DropdownMenuItem(value: 1, child: Text('Completed')),
                DropdownMenuItem(value: 2, child: Text('Pending')),
                DropdownMenuItem(value: 3, child: Text('Priority')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSortOption = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Filter by Priority'),
            DropdownButton<TaskPriority>(
              value: _selectedPriority,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.substring(0, 1).toUpperCase() +
                        priority.name.substring(1)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Filter by Category'),
            DropdownButton<String>(
              value: _selectedCategoryId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...widget.allCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'priority': _selectedPriority,
              'categoryId': _selectedCategoryId,
              'sortOption': _selectedSortOption,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

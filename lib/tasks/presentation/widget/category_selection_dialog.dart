import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/tasks/data/local/model/category_model.dart';
import 'package:task_manager/tasks/presentation/bloc/tasks_bloc.dart';

class CategorySelectionDialog extends StatefulWidget {
  final List<CategoryModel> allCategories;
  final List<String> selectedCategoryIds;

  const CategorySelectionDialog({
    super.key,
    required this.allCategories,
    required this.selectedCategoryIds,
  });

  @override
  State<CategorySelectionDialog> createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  late List<String> _tempSelectedCategoryIds;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedCategoryIds = List.from(widget.selectedCategoryIds);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _addNewCategory() {
    if (_newCategoryController.text.isNotEmpty) {
      final newCategory = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _newCategoryController.text,
      );
      context.read<TasksBloc>().add(AddCategoryEvent(category: newCategory));
      _newCategoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'New Category Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNewCategory,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allCategories.length,
                itemBuilder: (context, index) {
                  final category = widget.allCategories[index];
                  return CheckboxListTile(
                    title: Text(category.name),
                    value: _tempSelectedCategoryIds.contains(category.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _tempSelectedCategoryIds.add(category.id);
                        } else {
                          _tempSelectedCategoryIds.remove(category.id);
                        }
                      });
                    },
                  );
                },
              ),
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
            Navigator.of(context).pop(_tempSelectedCategoryIds);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}

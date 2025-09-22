import 'package:task_manager/routes/pages.dart';
import 'package:task_manager/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/theme/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: state.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().setTheme(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: state.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().setTheme(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System'),
                    value: ThemeMode.system,
                    groupValue: state.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        context.read<ThemeCubit>().setTheme(value);
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Manage Categories'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.pushNamed(context, Pages.categoryManagement);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import '../services/habits_service.dart';
import '../widgets/loading_overlay.dart';

import 'habits/habit_log_view.dart';
import 'habits/habit_stats_view.dart';
import 'habits/habit_edit_view.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _habitController = TextEditingController();

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _toggleHabit(String habit) async {
    LoadingOverlay.show(context);
    try {
      final key = _dateKey(_selectedDate);
      await context.read<HabitsService>().toggleHabit(key, habit);
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  void _addHabit() async {
    final newHabit = _habitController.text.trim();
    if (newHabit.isNotEmpty) {
      _habitController.clear();
      LoadingOverlay.show(context);
      try {
        await context.read<HabitsService>().addHabit(newHabit);
      } finally {
        if (mounted) LoadingOverlay.hide(context);
      }
    }
  }

  void _removeHabit(String habit) async {
    LoadingOverlay.show(context);
    try {
      await context.read<HabitsService>().removeHabit(habit);
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  void _confirmDeleteHabit(String habit) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Delete Habit?'),
        description: Text(
          'Are you sure you want to permanently delete "$habit"? This action cannot be undone.',
        ),
        actions: [
          ShadButton.secondary(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              _removeHabit(habit);
            },
          ),
        ],
      ),
    );
  }

  final List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final habitsService = context.watch<HabitsService>();
    final habits = habitsService.habits;
    final logs = habitsService.logs;

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: 'Log'),
                  Tab(text: 'Stats'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    HabitLogView(
                      selectedDate: _selectedDate,
                      habits: habits,
                      logs: logs,
                      weekdays: _weekdays,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      onToggleHabit: _toggleHabit,
                      dateKeyFormatter: _dateKey,
                    ),
                    HabitStatsView(
                      logs: logs,
                      habits: habits,
                      weekdays: _weekdays,
                      dateKeyFormatter: _dateKey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: HabitEditView(
                    habitController: _habitController,
                    habits: context.watch<HabitsService>().habits,
                    onAddHabit: () {
                      _addHabit();
                      Navigator.pop(context);
                    },
                    onRemoveHabit: _confirmDeleteHabit,
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

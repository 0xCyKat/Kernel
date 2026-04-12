import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import '../services/gym_service.dart';
import '../widgets/loading_overlay.dart';
import 'gym/gym_log_view.dart';
import 'gym/gym_stats_view.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  DateTime _selectedDate = DateTime.now();

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _saveWeight(double weight) async {
    LoadingOverlay.show(context);
    try {
      final key = _dateKey(_selectedDate);
      await context.read<GymService>().saveWeight(key, weight);
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  Future<void> _deleteWeight() async {
    LoadingOverlay.show(context);
    try {
      final key = _dateKey(_selectedDate);
      await context.read<GymService>().deleteWeight(key);
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymService = context.watch<GymService>();
    final weightLogs = gymService.weightLogs;

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
                    GymLogView(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      currentWeight: weightLogs[_dateKey(_selectedDate)],
                      onSaveWeight: _saveWeight,
                      onDeleteWeight: _deleteWeight,
                    ),
                    GymStatsView(weightLogs: weightLogs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

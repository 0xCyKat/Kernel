import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gym_service.dart';
import '../widgets/loading_overlay.dart';
import '../utils/constants.dart';
import 'gym/gym_log_view.dart';
import 'gym/gym_stats_view.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveWeight(double weight) async {
    LoadingOverlay.show(context);
    try {
      final key = AppUtils.dateKey(_selectedDate);
      await context.read<GymService>().saveWeight(key, weight);
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  Future<void> _deleteWeight() async {
    LoadingOverlay.show(context);
    try {
      final key = AppUtils.dateKey(_selectedDate);
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Log'),
                    Tab(text: 'Stats'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    GymLogView(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                      currentWeight: weightLogs[AppUtils.dateKey(_selectedDate)],
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


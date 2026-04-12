import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../services/habits_service.dart';
import '../services/gym_service.dart';
import '../services/finance_service.dart';
import '../widgets/weekly_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final habitsService = context.watch<HabitsService>();
    final gymService = context.watch<GymService>();
    final financeService = context.watch<FinanceService>();

    final dateKey = _dateKey(_selectedDate);

    // Habits calculation
    final allHabits = habitsService.habits;
    final logForDay = habitsService.logs[dateKey] ?? <String>{};
    final completedHabitsCount = allHabits
        .where((h) => logForDay.contains(h))
        .length;
    final totalHabitsCount = allHabits.length;
    final double habitProgress = totalHabitsCount == 0
        ? 0
        : completedHabitsCount / totalHabitsCount;

    // Gym Calculation
    final gymWeight = gymService.weightLogs[dateKey];

    // Finance Calculation
    final dayExpenses = financeService.expenses.where((e) {
      return e.date.year == _selectedDate.year &&
          e.date.month == _selectedDate.month &&
          e.date.day == _selectedDate.day;
    }).toList();
    final totalExpense = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
                // Also trigger FinanceService to fetch selected month if we navigate outside
                if (date.month != financeService.currentMonth.month ||
                    date.year != financeService.currentMonth.year) {
                  financeService.changeMonth(DateTime(date.year, date.month));
                }
              },
            ),
            const SizedBox(height: 32),
            Text(
              "Summary",
              style: ShadTheme.of(context).textTheme.large.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildSummaryCard(
                    context: context,
                    title: "Habits",
                    icon: Icons.checklist_rtl,
                    iconColor: Colors.blueAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$completedHabitsCount / $totalHabitsCount Completed",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${(habitProgress * 100).toInt()}%",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: habitProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white10,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context: context,
                    title: "Gym",
                    icon: Icons.fitness_center,
                    iconColor: Colors.orangeAccent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          gymWeight != null
                              ? "${gymWeight.toStringAsFixed(1)} kg"
                              : "Train!",
                          style: TextStyle(
                            color: gymWeight != null
                                ? Colors.white
                                : Colors.white38,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (gymWeight != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Logged",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context: context,
                    title: "Finance",
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.greenAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyFormat.format(totalExpense),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${dayExpenses.length} transactions",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xCC111111), // glassy dark
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

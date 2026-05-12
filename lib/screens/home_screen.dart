import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/services.dart';
import '../services/gym_service.dart';
import '../services/finance_service.dart';
import '../widgets/weekly_calendar.dart';
import '../widgets/bento_card.dart';
import '../utils/constants.dart';
import 'finance/add_expense_sheet.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final gymService = context.watch<GymService>();
    final financeService = context.watch<FinanceService>();

    final dateKey = AppUtils.dateKey(_selectedDate);

    // Gym Calculation
    final gymWeight = gymService.weightLogs[dateKey];

    // Finance Calculation
    final dayExpenses = financeService.expenses.where((e) {
      return e.date.year == _selectedDate.year &&
          e.date.month == _selectedDate.month &&
          e.date.day == _selectedDate.day;
    }).toList();
    final totalExpense = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // Sparkline - Finance (Last 7 days)
    final financeSparkline = <double>[];
    double maxFinance = 0;
    for (int i = 6; i >= 0; i--) {
      final d = _selectedDate.subtract(Duration(days: i));
      final totalForDay = financeService.expenses
          .where((e) =>
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day)
          .fold(0.0, (s, e) => s + e.amount);
      if (totalForDay > maxFinance) maxFinance = totalForDay;
      financeSparkline.add(totalForDay);
    }

    // Sparkline - Gym (Last 7 days)
    final gymSparkline = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = _selectedDate.subtract(Duration(days: i));
      final dk = AppUtils.dateKey(d);
      final w = gymService.weightLogs[dk];
      gymSparkline.add(w ?? 0.0); // Safe fallback
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeeklyCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                HapticFeedback.lightImpact();
                setState(() => _selectedDate = date);
                // Also trigger FinanceService to fetch selected month if we navigate outside
                if (date.month != financeService.currentMonth.month ||
                    date.year != financeService.currentMonth.year) {
                  financeService.changeMonth(DateTime(date.year, date.month));
                }
              },
            ),
            const SizedBox(height: 32),
            const Text(
              "Overview",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getGreeting(),
              style: ShadTheme.of(context).textTheme.large.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BentoCard(
                            title: "Gym",
                            icon: Icons.fitness_center,
                            iconColor: AppColors.textPrimary,
                            sparklineData: gymSparkline,
                            sparklineColor: AppColors.accentIndigo,
                            height: 180,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TweenAnimationBuilder<double>(
                                  key: ValueKey("gym_${AppUtils.dateKey(_selectedDate)}"),
                                  tween: Tween<double>(begin: 0, end: gymWeight ?? 0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, val, child) {
                                    return Text(
                                      gymWeight != null
                                          ? "${val.toStringAsFixed(1)} kg"
                                          : "Train!",
                                      style: TextStyle(
                                        color: gymWeight != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    );
                                  },
                                ),
                                if (gymWeight != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF27272A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "Logged",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => AddExpenseSheet(
                                  initialDate: _selectedDate,
                                ),
                              );
                            },
                            child: BentoCard(
                              title: "Quick Add",
                              icon: Icons.add_circle_outline,
                              iconColor: AppColors.textPrimary,
                              height: 180,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF27272A),
                                  AppColors.background.withValues(alpha: 0.8),
                                ],
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Expense",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Tap to log",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BentoCard(
                      title: "Finance",
                      icon: Icons.account_balance_wallet,
                      iconColor: AppColors.textPrimary,
                      sparklineData: financeSparkline,
                      sparklineColor: AppColors.accentPink,
                      maxY: maxFinance,
                      height: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            key: ValueKey("fin_${AppUtils.dateKey(_selectedDate)}"),
                            tween: Tween<double>(begin: 0, end: totalExpense),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, child) {
                              return Text(
                                AppUtils.currencyFormat.format(val),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.0,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${dayExpenses.length} transactions",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (dayExpenses.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Text(
                        "Today's Logs",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...dayExpenses.take(3).map((expense) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLighter,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.receipt_long, color: AppColors.textSecondary, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      expense.paymentType,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppUtils.currencyFormat.format(expense.amount),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


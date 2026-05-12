import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/finance_service.dart';
import '../utils/constants.dart';
import 'finance/finance_log_view.dart';
import 'finance/finance_stats_view.dart';
import 'finance/add_expense_sheet.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  void _previousMonth() {
    final svc = context.read<FinanceService>();
    svc.changeMonth(
      DateTime(svc.currentMonth.year, svc.currentMonth.month - 1),
    );
  }

  void _nextMonth() {
    final svc = context.read<FinanceService>();
    svc.changeMonth(
      DateTime(svc.currentMonth.year, svc.currentMonth.month + 1),
    );
  }

  void _showMonthPicker(BuildContext context, DateTime currentMonth) {
    showDialog(
      context: context,
      builder: (ctx) {
        int selectedYear = currentMonth.year;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceLighter,
              surfaceTintColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    onPressed: () => setState(() => selectedYear--),
                  ),
                  Text(
                    selectedYear.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
                    onPressed: () => setState(() => selectedYear++),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthDate = DateTime(selectedYear, index + 1);
                    final isSelected =
                        selectedYear == currentMonth.year &&
                        index + 1 == currentMonth.month;
                    return InkWell(
                      onTap: () {
                        this.context.read<FinanceService>().changeMonth(
                          monthDate,
                        );
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.textPrimary
                              : const Color(0xFF27272A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppUtils.formatMonthYear(monthDate).split(' ')[0], // Just MMM
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Consumer<FinanceService>(
                builder: (context, financeService, _) {
                  final total = financeService.expenses.fold(
                    0.0,
                    (sum, exp) => sum + exp.amount,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "TOTAL EXPENSES",
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    AppUtils.currencyFormat.format(total),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -2.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLighter,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                                  onPressed: _previousMonth,
                                ),
                                InkWell(
                                  onTap: () => _showMonthPicker(context, financeService.currentMonth),
                                  child: Text(
                                    AppUtils.formatMonthYear(financeService.currentMonth),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                                  onPressed: _nextMonth,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    const Expanded(
                      child: TabBarView(
                        children: [FinanceLogView(), FinanceStatsView()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textPrimary,
        elevation: 4,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddExpenseSheet(),
          );
        },
        child: const Icon(Icons.add_rounded, color: AppColors.background, size: 28),
      ),
    );
  }
}


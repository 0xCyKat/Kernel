import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../services/finance_service.dart';
import '../../models/expense.dart';
import '../../utils/constants.dart';
import 'add_expense_sheet.dart';

class FinanceLogView extends StatelessWidget {
  const FinanceLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceService>(
      builder: (context, financeService, child) {
        final expenses = financeService.expenses;
        if (expenses.isEmpty) {
          return const Center(
            child: Text(
              'No expenses recorded for this month.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        final Map<String, List<Expense>> groupedExpenses = {};
        for (var expense in expenses) {
          final dateKey = AppUtils.dateKey(expense.date);
          groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
        }

        final sortedKeys = groupedExpenses.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final dateKey = sortedKeys[index];
            final dailyExps = groupedExpenses[dateKey]!;
            final dailyTotal = dailyExps.fold(0.0, (sum, e) => sum + e.amount);
            final date = DateTime.parse(dateKey);

            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => AddExpenseSheet(
                          initialDate: date,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLighter,
                        border: Border(
                          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppUtils.formatDate(date).split(',')[1].trim().toUpperCase(), // Day name
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppUtils.formatDate(date).split(',')[0], // Date string
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "DAILY TOTAL",
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppUtils.currencyFormat.format(dailyTotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.error,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ...dailyExps.map((exp) {
                    final cat = financeService.getCategoryById(exp.categoryId);
                    final isLast = dailyExps.last == exp;
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddExpenseSheet(existingExpense: exp),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          border: isLast ? null : const Border(
                            bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLighter,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                                color: AppColors.textPrimary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exp.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${cat.name} • ${exp.paymentType}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppUtils.currencyFormat.format(exp.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

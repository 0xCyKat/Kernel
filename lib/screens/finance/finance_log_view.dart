import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/finance_service.dart';
import '../../models/expense.dart';
import 'package:intl/intl.dart';
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
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final Map<String, List<Expense>> groupedExpenses = {};
        for (var expense in expenses) {
          final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
          groupedExpenses.putIfAbsent(dateKey, () => []).add(expense);
        }

        final sortedKeys = groupedExpenses.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final dateKey = sortedKeys[index];
            final dailyExps = groupedExpenses[dateKey]!;
            final dailyTotal = dailyExps.fold(0.0, (sum, e) => sum + e.amount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey.shade900,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat(
                          'dd MMM yyyy, EEEE',
                        ).format(DateTime.parse(dateKey)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${dailyTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                ...dailyExps.map((exp) {
                  final cat = financeService.getCategoryById(exp.categoryId);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade800,
                      child: Icon(
                        IconData(
                          cat.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      exp.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${cat.name} • ${exp.paymentType}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Text(
                      '₹${exp.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>
                            AddExpenseSheet(existingExpense: exp),
                      );
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}

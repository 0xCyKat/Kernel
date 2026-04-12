import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/finance_service.dart';
import 'package:intl/intl.dart';
import 'finance/finance_log_view.dart';
import 'finance/finance_stats_view.dart';
import 'finance/add_expense_sheet.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );

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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => selectedYear--),
                  ),
                  Text(
                    selectedYear.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
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
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMM').format(monthDate),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
    final theme = Theme.of(context);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Column(
            children: [
              Consumer<FinanceService>(
                builder: (context, financeService, _) {
                  final total = financeService.expenses.fold(
                    0.0,
                    (sum, exp) => sum + exp.amount,
                  );
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _previousMonth,
                              ),
                              InkWell(
                                onTap: () => _showMonthPicker(
                                  context,
                                  financeService.currentMonth,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat(
                                          'MMM yyyy',
                                        ).format(financeService.currentMonth),
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _nextMonth,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Expenses',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(total),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Log'),
                  Tab(text: 'Stats'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [FinanceLogView(), FinanceStatsView()],
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
            builder: (context) => const AddExpenseSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

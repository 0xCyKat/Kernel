import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/finance_service.dart';
import '../../models/expense.dart';
import 'package:intl/intl.dart';

class FinanceStatsView extends StatefulWidget {
  const FinanceStatsView({super.key});

  @override
  State<FinanceStatsView> createState() => _FinanceStatsViewState();
}

class _FinanceStatsViewState extends State<FinanceStatsView> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceService>(
      builder: (context, financeService, _) {
        final expenses = _isYearly
            ? financeService.yearlyExpenses
            : financeService.expenses;

        final Map<String, double> categoryTotals = {};
        for (var e in expenses) {
          categoryTotals[e.categoryId] =
              (categoryTotals[e.categoryId] ?? 0) + e.amount;
        }

        final sortedCategories = categoryTotals.keys.toList()
          ..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));

        final colors = [
          const Color(0xFF6366F1), // Indigo
          const Color(0xFFEC4899), // Pink
          const Color(0xFF10B981), // Emerald
          const Color(0xFFF59E0B), // Amber
          const Color(0xFF8B5CF6), // Violet
          const Color(0xFF06B6D4), // Cyan
          const Color(0xFF14B8A6), // Teal
          const Color(0xFFF43F5E), // Rose
        ];

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Monthly')),
                  ButtonSegment(value: true, label: Text('Yearly')),
                ],
                selected: {_isYearly},
                onSelectionChanged: (set) {
                  setState(() => _isYearly = set.first);
                },
              ),
              const SizedBox(height: 16),
              if (expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else ...[
                if (_isYearly)
                  _buildYearlyLineChart(
                    financeService.yearlyExpenses,
                    financeService.currentMonth.year,
                  ),
                if (_isYearly) const SizedBox(height: 32),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: List.generate(sortedCategories.length, (i) {
                        final catId = sortedCategories[i];
                        final cat = financeService.getCategoryById(catId);
                        final val = categoryTotals[catId]!;
                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: val,
                          title:
                              '${((val / expenses.fold(0.0, (s, e) => s + e.amount)) * 100).toStringAsFixed(1)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: List.generate(sortedCategories.length, (i) {
                      final catId = sortedCategories[i];
                      final cat = financeService.getCategoryById(catId);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: colors[i % colors.length],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${categoryTotals[catId]!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearlyLineChart(List<Expense> expenses, int year) {
    // Aggregate by month (1 to 12)
    final Map<int, double> monthlyTotals = {
      for (int i = 1; i <= 12; i++) i: 0.0,
    };

    for (var e in expenses) {
      monthlyTotals[e.date.month] = monthlyTotals[e.date.month]! + e.amount;
    }

    double maxAmount = 100;
    for (var val in monthlyTotals.values) {
      if (val > maxAmount) maxAmount = val;
    }

    final spots = monthlyTotals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    spots.sort((a, b) => a.x.compareTo(b.x));

    return Column(
      children: [
        Text(
          '$year Trend',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 24, left: 8),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value < 1 || value > 12)
                        return const SizedBox.shrink();
                      final date = DateTime(year, value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        (value / 1000).toStringAsFixed(1) + 'k',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 1,
              maxX: 12,
              minY: 0,
              maxY: maxAmount * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.blueAccent,
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

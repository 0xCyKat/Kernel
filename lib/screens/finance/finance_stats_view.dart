import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../../services/finance_service.dart';
import '../../models/expense.dart';
import '../../utils/constants.dart';
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
          AppColors.accentIndigo,
          const Color(0xFF34D399), // Calm Emerald
          const Color(0xFFFB923C), // Warm Amber
          AppColors.accentPink,
          const Color(0xFF60A5FA), // Sky Blue
          const Color(0xFFA78BFA), // Smooth Violet
          const Color(0xFF2DD4BF), // Pleasant Teal
          const Color(0xFFFB7185), // Dusty Rose
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildPeriodToggle(),
              const SizedBox(height: 24),
              if (expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else ...[
                if (_isYearly) ...[
                  _buildSectionTitle("Spending Trend"),
                  const SizedBox(height: 12),
                  _buildBentoCard(
                    child: SizedBox(
                      height: 220,
                      child: _buildYearlyLineChart(
                        financeService.yearlyExpenses,
                        financeService.currentMonth.year,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                _buildSectionTitle("Category Breakdown"),
                const SizedBox(height: 12),
                _buildBentoCard(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 240,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: List.generate(sortedCategories.length, (i) {
                              final catId = sortedCategories[i];
                              final val = categoryTotals[catId]!;
                              final totalExp = expenses.fold(0.0, (s, e) => s + e.amount);
                              final isSmall = (val / totalExp) < 0.05;
                              return PieChartSectionData(
                                color: colors[i % colors.length],
                                value: val,
                                title: isSmall
                                    ? ''
                                    : '${((val / totalExp) * 100).toStringAsFixed(1)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.background,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Details"),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: List.generate(sortedCategories.length, (i) {
                      final catId = sortedCategories[i];
                      final cat = financeService.getCategoryById(catId);
                      final val = categoryTotals[catId]!;
                      final totalExp = expenses.fold(0.0, (s, e) => s + e.amount);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderSubtle, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLighter,
                                borderRadius: BorderRadius.circular(10),
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
                                    cat.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${((val / totalExp) * 100).toStringAsFixed(1)}% of total',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppUtils.currencyFormat.format(val),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleButton("Monthly", !_isYearly, () {
            if (_isYearly) {
              HapticFeedback.lightImpact();
              setState(() => _isYearly = false);
            }
          }),
          _buildToggleButton("Yearly", _isYearly, () {
            if (!_isYearly) {
              HapticFeedback.lightImpact();
              setState(() => _isYearly = true);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF27272A) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildBentoCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildYearlyLineChart(List<Expense> expenses, int year) {
    final Map<int, double> monthlyTotals = {
      for (int i = 1; i <= 12; i++) i: 0.0,
    };

    for (var e in expenses) {
      monthlyTotals[e.date.month] = (monthlyTotals[e.date.month] ?? 0.0) + e.amount;
    }

    double maxAmount = 100;
    for (var val in monthlyTotals.values) {
      if (val > maxAmount) maxAmount = val;
    }

    final spots = monthlyTotals.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    spots.sort((a, b) => a.x.compareTo(b.x));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: AppColors.borderSubtle, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value < 1 || value > 12) return const SizedBox.shrink();
                final date = DateTime(year, value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
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
            color: AppColors.accentIndigo,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentIndigo.withValues(alpha: 0.15),
                  AppColors.accentIndigo.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../widgets/bento_card.dart';
import '../../utils/constants.dart';

class GymStatsView extends StatelessWidget {
  final Map<String, double> weightLogs;

  const GymStatsView({super.key, required this.weightLogs});

  @override
  Widget build(BuildContext context) {
    if (weightLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, color: Color(0xFF27272A), size: 48),
            const SizedBox(height: 16),
            const Text(
              "No weight logged yet.",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Sort valid dates
    final validDates = weightLogs.keys.map((k) => DateTime.parse(k)).toList()
      ..sort();

    double minWeight = double.infinity;
    double maxWeight = -double.infinity;
    double sumWeight = 0;

    for (var date in validDates) {
      final w = weightLogs[AppUtils.dateKey(date)]!;
      if (w < minWeight) minWeight = w;
      if (w > maxWeight) maxWeight = w;
      sumWeight += w;
    }

    final double meanWeight = sumWeight / validDates.length;
    final double latestWeight = weightLogs[AppUtils.dateKey(validDates.last)]!;
    final double firstWeight = weightLogs[AppUtils.dateKey(validDates.first)]!;
    final double totalChange = latestWeight - firstWeight;

    // Sparkline for last 30 days
    final List<double> monthSparkline = [];
    double sparkMax = 0;
    for (int i = 29; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final w = weightLogs[AppUtils.dateKey(d)];
      final val = w ?? (monthSparkline.isNotEmpty ? monthSparkline.last : meanWeight);
      if (val > sparkMax) sparkMax = val;
      monthSparkline.add(val);
    }

    // 30-day consistency heatmap data
    final List<DateTime> heatmapDays = List.generate(
      30,
      (index) => DateTime.now().subtract(Duration(days: 29 - index)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BentoCard(
            title: "30-Day Trend",
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.textPrimary,
            height: 220,
            sparklineData: monthSparkline,
            sparklineColor: const Color(0xFF10B981), // Emerald
            maxY: sparkMax,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${latestWeight.toStringAsFixed(1)} kg",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    "${totalChange > 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg total",
                    style: TextStyle(
                      color: totalChange > 0 ? AppColors.error : const Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BentoCard(
                  title: "High",
                  icon: Icons.vertical_align_top_rounded,
                  iconColor: AppColors.error,
                  height: 140,
                  child: Text(
                    "${maxWeight.toStringAsFixed(1)} kg",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: BentoCard(
                  title: "Average",
                  icon: Icons.calculate_rounded,
                  iconColor: const Color(0xFF3B82F6), // Blue
                  height: 140,
                  child: Text(
                    "${meanWeight.toStringAsFixed(1)} kg",
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle("Consistency Heatmap"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("30 Days Ago", style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                    Text("Today", style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7 days a week
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: heatmapDays.length,
                  itemBuilder: (context, index) {
                    final date = heatmapDays[index];
                    final hasLog = weightLogs.containsKey(AppUtils.dateKey(date));
                    return Container(
                      decoration: BoxDecoration(
                        color: hasLog ? AppColors.accentIndigo : AppColors.surfaceLighter,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: hasLog
                            ? [
                                BoxShadow(
                                  color: AppColors.accentIndigo.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

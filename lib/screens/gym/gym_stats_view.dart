import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';

class GymStatsView extends StatelessWidget {
  final Map<String, double> weightLogs;

  const GymStatsView({super.key, required this.weightLogs});

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (weightLogs.isEmpty) {
      return Center(
        child: Text(
          "No weight logged yet.",
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(color: Colors.grey[400]),
        ),
      );
    }

    final today = DateTime.now();
    final spots = <FlSpot>[];

    // Parse to get valid double lists, sort by date
    final validDates = weightLogs.keys.map((k) => DateTime.parse(k)).toList()
      ..sort();

    final minDate = validDates.first;
    final maxDate = validDates.last;

    double minWeight = double.infinity;
    double maxWeight = -double.infinity;
    double sumWeight = 0;

    for (var date in validDates) {
      final w = weightLogs[_dateKey(date)]!;
      if (w < minWeight) minWeight = w;
      if (w > maxWeight) maxWeight = w;
      sumWeight += w;
    }

    final double meanWeight = sumWeight / validDates.length;

    // Calculate median
    final allWeights = validDates.map((d) => weightLogs[_dateKey(d)]!).toList()
      ..sort();
    double medianWeight;
    if (allWeights.length % 2 == 1) {
      medianWeight = allWeights[allWeights.length ~/ 2];
    } else {
      final mid = allWeights.length ~/ 2;
      medianWeight = (allWeights[mid - 1] + allWeights[mid]) / 2;
    }

    for (var date in validDates) {
      final daysDiff = date.difference(minDate).inDays.toDouble();
      spots.add(FlSpot(daysDiff, weightLogs[_dateKey(date)]!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Weight History",
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 32),
        Container(
          height: 250,
          padding: const EdgeInsets.only(right: 16),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxDate.difference(minDate).inDays.toDouble(),
              minY: (minWeight - 5).clamp(0, double.infinity),
              maxY: maxWeight + 5,
              gridData: const FlGridData(show: false),
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
                    reservedSize: 22,
                    interval: validDates.length > 7 ? validDates.length / 5 : 1,
                    getTitlesWidget: (value, meta) {
                      final date = minDate.add(Duration(days: value.toInt()));
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          DateFormat('MMM d').format(date),
                          style: const TextStyle(
                            color: Colors.grey,
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
                    reservedSize: 32,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blueAccent.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "Statistics",
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                "Mean",
                "${meanWeight.toStringAsFixed(1)} kg",
              ),
              _buildStatItem(
                context,
                "Median",
                "${medianWeight.toStringAsFixed(1)} kg",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: ShadTheme.of(
            context,
          ).textTheme.small.copyWith(color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: ShadTheme.of(context).textTheme.large.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

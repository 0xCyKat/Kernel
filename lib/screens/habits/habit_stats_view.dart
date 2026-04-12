import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HabitStatsView extends StatelessWidget {
  final Map<String, Set<String>> logs;
  final List<String> habits;
  final List<String> weekdays;
  final String Function(DateTime) dateKeyFormatter;

  const HabitStatsView({
    super.key,
    required this.logs,
    required this.habits,
    required this.weekdays,
    required this.dateKeyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate most followed habit
    String mostFollowed = "None";
    int maxCount = 0;
    Map<String, int> habitCounts = {};

    for (var completedList in logs.values) {
      for (var h in completedList) {
        habitCounts[h] = (habitCounts[h] ?? 0) + 1;
        if (habitCounts[h]! > maxCount) {
          maxCount = habitCounts[h]!;
          mostFollowed = h;
        }
      }
    }

    // Generate graph data (last 7 days completions)
    final today = DateTime.now();
    final spots = <FlSpot>[];
    double maxHabits = habits.isEmpty ? 1 : habits.length.toDouble();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = dateKeyFormatter(date);
      final count = logs[key]?.length ?? 0;
      // x = day index from 0 to 6
      spots.add(FlSpot((6 - i).toDouble(), count.toDouble()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line Graph section
        Text(
          'Last 7 Days (Hits)',
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(
            right: 24,
            top: 24,
            bottom: 12,
            left: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 30, // Give some vertical space for text
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value > 6) return const SizedBox();
                      // value is from 0 to 6
                      final d = today.subtract(
                        Duration(days: 6 - value.toInt()),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          weekdays[d.weekday - 1],
                          style: TextStyle(
                            color: Colors.grey[500],
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
                    interval: 1,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value % 1 != 0)
                        return const SizedBox(); // Only show whole numbers
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: -0.5, // Small horizontal padding buffer inside
              maxX: 6.5, // Small horizontal padding buffer inside
              minY: 0,
              maxY:
                  (maxHabits < 4 ? 4.0 : maxHabits) +
                  1.0, // Make the graph look better by having a top buffer
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.white,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Most Followed Habit section
        Text(
          'Most Followed Habit',
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mostFollowed,
                style: ShadTheme.of(
                  context,
                ).textTheme.h2.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    maxCount == 1 ? '1 Time' : '$maxCount Times',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

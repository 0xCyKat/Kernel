import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/weekly_calendar.dart';

class HabitLogView extends StatelessWidget {
  final DateTime selectedDate;
  final List<String> habits;
  final Map<String, Set<String>> logs;
  final List<String> weekdays;
  final void Function(DateTime) onDateSelected;
  final void Function(String) onToggleHabit;
  final String Function(DateTime) dateKeyFormatter;

  const HabitLogView({
    super.key,
    required this.selectedDate,
    required this.habits,
    required this.logs,
    required this.weekdays,
    required this.onDateSelected,
    required this.onToggleHabit,
    required this.dateKeyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Centered around today, 7 days total. So 3 days ago to 3 days future.
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 3 - index)),
    );

    return Column(
      children: [
        // Horizontal Calendar Segment
        WeeklyCalendar(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: habits.isEmpty
              ? Center(
                  child: Text(
                    "No habits. Add them in Edit!",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : ListView.separated(
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final isCompleted =
                        logs[dateKeyFormatter(selectedDate)]?.contains(habit) ??
                        false;

                    return GestureDetector(
                      onTap: () => onToggleHabit(habit),
                      child: AnimatedContainer(
                        duration: 300.ms,
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isCompleted ? null : const Color(0xFF141416),
                          gradient: isCompleted
                              ? LinearGradient(
                                  colors: [
                                    Colors.green.withOpacity(0.2),
                                    Colors.green.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.3)
                                : Colors.white10,
                            width: 1,
                          ),
                          boxShadow: [
                            if (isCompleted)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: -2,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child:
                                  Icon(
                                        isCompleted
                                            ? Icons.check
                                            : Icons.circle_outlined,
                                        color: isCompleted
                                            ? Colors.greenAccent
                                            : Colors.grey[500],
                                        size: 20,
                                      )
                                      .animate(target: isCompleted ? 1 : 0)
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.2, 1.2),
                                        duration: 200.ms,
                                      ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                habit,
                                style: ShadTheme.of(context).textTheme.large
                                    .copyWith(
                                      color: isCompleted
                                          ? Colors.white
                                          : Colors.white70,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: Colors.white54,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

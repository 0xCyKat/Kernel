import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WeeklyCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const WeeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showMonthCalendar(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Select a Date'),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ShadCalendar(
            selected: selectedDate,
            onChanged: (v) {
              if (v != null) {
                onDateSelected(v);
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Centered around selected date to allow navigation
    final days = List.generate(
      7,
      (index) => selectedDate.subtract(Duration(days: 3 - index)),
    );
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showMonthCalendar(context),
          child: Container(
            height: 80,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected = _dateKey(date) == _dateKey(selectedDate);
                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    width: 55,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdays[date.weekday - 1],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

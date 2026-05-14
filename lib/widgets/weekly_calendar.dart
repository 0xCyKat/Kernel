import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class WeeklyCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const WeeklyCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  void _showMonthCalendar(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.textPrimary, // Header background color
              onPrimary: AppColors.background, // Header text color
              surface: AppColors.surface, // Background color
              onSurface: AppColors.textPrimary, // Text color
            ),
            dialogBackgroundColor: AppColors.surface,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      HapticFeedback.mediumImpact();
      onDateSelected(pickedDate);
    }
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
          onTap: () {
            HapticFeedback.lightImpact();
            _showMonthCalendar(context);
          },
          child: Container(
            height: 75,
            width: 55,
            decoration: BoxDecoration(
              color: AppColors.surfaceLighter,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 75,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected = AppUtils.dateKey(date) == AppUtils.dateKey(selectedDate);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateSelected(date);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 55,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textPrimary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.border,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.textPrimary.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdays[date.weekday - 1],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF52525B) : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? AppColors.background : AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

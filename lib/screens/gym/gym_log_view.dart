import 'package:flutter/material.dart';
import '../../widgets/weekly_calendar.dart';
import '../../utils/custom_toast.dart';
import '../../utils/constants.dart';

class GymLogView extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final double? currentWeight;
  final void Function(double) onSaveWeight;
  final void Function() onDeleteWeight;

  const GymLogView({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.currentWeight,
    required this.onSaveWeight,
    required this.onDeleteWeight,
  });

  @override
  State<GymLogView> createState() => _GymLogViewState();
}

class _GymLogViewState extends State<GymLogView> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.currentWeight?.toString() ?? '';
  }

  @override
  void didUpdateWidget(GymLogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWeight != widget.currentWeight ||
        oldWidget.selectedDate != widget.selectedDate) {
      _weightController.text = widget.currentWeight?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeeklyCalendar(
            selectedDate: widget.selectedDate,
            onDateSelected: widget.onDateSelected,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "BODY WEIGHT",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -2.0,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0.0",
                          hintStyle: TextStyle(
                            color: Color(0xFF27272A), // Zinc 800
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "kg",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.currentWeight != null) ...[
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          widget.onDeleteWeight();
                          showCustomToast(context, 'Deleted', 'Weight entry deleted', CustomToastType.error);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          final weightStr = _weightController.text;
                          final weight = double.tryParse(weightStr);
                          if (weight != null) {
                            widget.onSaveWeight(weight);
                            showCustomToast(context, 'Success', 'Weight securely logged!', CustomToastType.success);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Log Weight",
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

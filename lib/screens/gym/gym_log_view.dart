import 'package:flutter/material.dart';
import '../../widgets/weekly_calendar.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../utils/custom_toast.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeeklyCalendar(
          selectedDate: widget.selectedDate,
          onDateSelected: widget.onDateSelected,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141416),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: Colors.orangeAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Log your weight",
                    style: ShadTheme.of(context).textTheme.large.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ShadInput(
                      controller: _weightController,
                      placeholder: const Text(
                        'Enter weight in kg',
                        style: TextStyle(color: Colors.white38),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ShadButton(
                    onPressed: () {
                      // Dismiss the keyboard
                      FocusScope.of(context).unfocus();

                      final weightStr = _weightController.text;
                      final weight = double.tryParse(weightStr);
                      if (weight != null) {
                        widget.onSaveWeight(weight);
                        showCustomToast(
                          context,
                          'Success',
                          'Weight logged!',
                          CustomToastType.success,
                        );
                      }
                    },
                    backgroundColor: Colors.orangeAccent.withOpacity(0.2),
                    hoverBackgroundColor: Colors.orangeAccent.withOpacity(0.3),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.currentWeight != null) ...[
                    const SizedBox(width: 8),
                    ShadButton.destructive(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        widget.onDeleteWeight();
                        showCustomToast(
                          context,
                          'Deleted',
                          'Weight entry deleted',
                          CustomToastType.error,
                        );
                      },
                      backgroundColor: Colors.redAccent.withOpacity(0.15),
                      hoverBackgroundColor: Colors.redAccent.withOpacity(0.25),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

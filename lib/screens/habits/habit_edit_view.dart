import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HabitEditView extends StatelessWidget {
  final TextEditingController habitController;
  final List<String> habits;
  final VoidCallback onAddHabit;
  final void Function(String) onRemoveHabit;

  const HabitEditView({
    super.key,
    required this.habitController,
    required this.habits,
    required this.onAddHabit,
    required this.onRemoveHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ShadInput(
                controller: habitController,
                placeholder: const Text('Add new habit...'),
              ),
            ),
            const SizedBox(width: 12),
            ShadButton(onPressed: onAddHabit, child: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: habits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      habit,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      iconSize: 28,
                      onPressed: () => onRemoveHabit(habit),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/finance_palette.dart';
import '../../services/finance_service.dart';
import '../../utils/constants.dart';

class PaletteSelectorSheet extends StatelessWidget {
  const PaletteSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "SELECT PALETTE",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: Consumer<FinanceService>(
              builder: (context, svc, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: FinancePalette.availablePalettes.length,
                  itemBuilder: (context, index) {
                    final palette = FinancePalette.availablePalettes[index];
                    final isSelected = svc.selectedPaletteId == palette.id;

                    return InkWell(
                      onTap: () {
                        svc.setPalette(palette.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    palette.name,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: palette.colors.take(6).map((color) {
                                      return Container(
                                        width: 20,
                                        height: 20,
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.textPrimary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

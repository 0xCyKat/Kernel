import 'package:flutter/material.dart';
import 'sparkline_painter.dart';
import '../utils/constants.dart';

class BentoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final List<double>? sparklineData;
  final Color? sparklineColor;
  final double? height;
  final double? maxY;
  final Gradient? gradient;

  const BentoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.sparklineData,
    this.sparklineColor,
    this.height,
    this.maxY,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Stack(
        children: [
          if (sparklineData != null && sparklineData!.length > 1)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: CustomPaint(
                  painter: SparklinePainter(
                    data: sparklineData!,
                    color: sparklineColor ?? AppColors.textPrimary,
                    maxY: maxY != null && maxY! > 0 ? maxY! * 1.2 : null,
                    minY: 0,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLighter,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: iconColor, size: 18),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

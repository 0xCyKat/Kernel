import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum CustomToastType { success, error, warning, info }

void showCustomToast(
  BuildContext context,
  String title,
  String description,
  CustomToastType type,
) {
  Color iconColor;
  Color bgColor;
  IconData icon;

  switch (type) {
    case CustomToastType.success:
      iconColor = const Color(0xFF10B981);
      bgColor = const Color(0xCC064E3B);
      icon = Icons.check_circle_outline;
      break;
    case CustomToastType.error:
      iconColor = const Color(0xFFF43F5E);
      bgColor = const Color(0xCC7F1D1D);
      icon = Icons.cancel_outlined;
      break;
    case CustomToastType.warning:
      iconColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xCC78350F);
      icon = Icons.warning_amber_rounded;
      break;
    case CustomToastType.info:
    default:
      iconColor = const Color(0xFF3B82F6);
      bgColor = const Color(0xCC1E3A8A);
      icon = Icons.info_outline;
      break;
  }

  ShadToaster.of(context).show(
    ShadToast(
      backgroundColor: bgColor,
      border: ShadBorder.all(
        color: iconColor.withOpacity(0.5),
        width: 1,
        radius: BorderRadius.circular(16),
      ), // changed
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      description: Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Text(
          description,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ),
      action: ShadButton.ghost(
        child: const Icon(Icons.close, color: Colors.white54, size: 18),
        onPressed: () => ShadToaster.of(context).hide(),
      ),
    ),
  );
}

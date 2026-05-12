import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const background = Color(0xFF09090B); // Zinc 950
  static const surface = Color(0xFF121214);   // Subtle elevation
  static const surfaceLighter = Color(0xFF18181B); // Zinc 900
  static const border = Color(0x1AFFFFFF);
  static const borderSubtle = Color(0x0DFFFFFF);
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const textMuted = Color(0xFF52525B);    // Zinc 500
  static const primary = Color(0xFFFAFAFA);
  static const accentIndigo = Color(0xFF818CF8);
  static const accentPink = Color(0xFFF472B6);
  static const error = Color(0xFFE11D48); // Rose 600
}

class AppUtils {
  static final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final currencyFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, EEEE').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }
}

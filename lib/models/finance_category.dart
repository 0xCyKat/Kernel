import 'package:flutter/material.dart';

class FinanceCategory {
  final String id;
  final String name;
  final int iconCodePoint;

  FinanceCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
  });

  factory FinanceCategory.fromMap(String id, Map<String, dynamic> data) {
    return FinanceCategory(
      id: id,
      name: data['n'] ?? 'Unknown',
      iconCodePoint: data['i'] ?? Icons.category.codePoint,
    );
  }

  Map<String, dynamic> toMap() {
    return {'n': name, 'i': iconCodePoint};
  }

  static List<FinanceCategory> defaultCategories = [
    FinanceCategory(
      id: 'health',
      name: 'Health',
      iconCodePoint: Icons.medical_services.codePoint,
    ),
    FinanceCategory(
      id: 'household',
      name: 'Household',
      iconCodePoint: Icons.home.codePoint,
    ),
    FinanceCategory(
      id: 'food',
      name: 'Food',
      iconCodePoint: Icons.fastfood.codePoint,
    ),
    FinanceCategory(
      id: 'transport',
      name: 'Transport',
      iconCodePoint: Icons.directions_car.codePoint,
    ),
    FinanceCategory(
      id: 'entertainment',
      name: 'Entertainment',
      iconCodePoint: Icons.movie.codePoint,
    ),
    FinanceCategory(
      id: 'apparel',
      name: 'Apparel',
      iconCodePoint: Icons.checkroom.codePoint,
    ),
    FinanceCategory(
      id: 'home',
      name: 'Home',
      iconCodePoint: Icons.house.codePoint,
    ),
    FinanceCategory(
      id: 'edu',
      name: 'Edu',
      iconCodePoint: Icons.school.codePoint,
    ),
    FinanceCategory(
      id: 'medicine',
      name: 'Medicine',
      iconCodePoint: Icons.local_pharmacy.codePoint,
    ),
    FinanceCategory(
      id: 'beauty',
      name: 'Beauty',
      iconCodePoint: Icons.face_retouching_natural.codePoint,
    ),
    FinanceCategory(
      id: 'others',
      name: 'Others',
      iconCodePoint: Icons.more_horiz.codePoint,
    ),
  ];
}

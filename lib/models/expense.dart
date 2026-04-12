import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final DateTime date;
  final String paymentType;
  final double amount;

  Expense({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.date,
    required this.paymentType,
    required this.amount,
  });

  factory Expense.fromMap(String id, Map<String, dynamic> data) {
    return Expense(
      id: id,
      name: data['n'] ?? '',
      categoryId: data['c'] ?? 'others',
      description: data['d'] ?? '',
      date: (data['dt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentType: data['p'] ?? 'Cash',
      amount: (data['a'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'n': name,
      'c': categoryId,
      'd': description,
      'dt': Timestamp.fromDate(date),
      'p': paymentType,
      'a': amount,
    };
  }
}

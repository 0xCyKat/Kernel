import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/finance_category.dart';
import 'package:flutter/material.dart';
import '../models/finance_palette.dart';

class FinanceService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Expense> _expenses = [];
  List<Expense> _yearlyExpenses = [];
  List<FinanceCategory> _customCategories = [];
  List<String> _customPaymentTypes = [];
  String _selectedPaletteId = 'default';

  StreamSubscription? _expenseSub;
  StreamSubscription? _yearlyExpenseSub;
  StreamSubscription? _categorySub;
  StreamSubscription? _paymentSub;

  List<Expense> get expenses => _expenses;
  List<Expense> get yearlyExpenses => _yearlyExpenses;
  String get selectedPaletteId => _selectedPaletteId;
  FinancePalette get selectedPalette => FinancePalette.getPalette(_selectedPaletteId);

  List<FinanceCategory> get categories {
    final map = <String, FinanceCategory>{};
    for (var c in FinanceCategory.defaultCategories) {
      map[c.id] = c;
    }
    for (var c in _customCategories) {
      map[c.id] = c;
    }
    return map.values.toList();
  }

  List<String> get paymentTypes =>
      {'Cash', 'UPI', 'Card', 'Pluxee', ..._customPaymentTypes}.toList();

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get currentMonth => _currentMonth;

  FinanceService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadPalettePreference();
        _loadCategories();
        _loadPaymentTypes();
        _listenToExpenses();
      } else {
        _cancelAllSubscriptions();
        _expenses = [];
        _yearlyExpenses = [];
        _customCategories = [];
        _customPaymentTypes = [];
        notifyListeners();
      }
    });
  }

  void _cancelAllSubscriptions() {
    _expenseSub?.cancel();
    _yearlyExpenseSub?.cancel();
    _categorySub?.cancel();
    _paymentSub?.cancel();
  }

  @override
  void dispose() {
    _cancelAllSubscriptions();
    super.dispose();
  }

  void changeMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month);
    _listenToExpenses();
  }

  void _listenToExpenses() {
    final user = _auth.currentUser;
    if (user == null) return;

    _expenseSub?.cancel();
    _yearlyExpenseSub?.cancel();

    final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final end = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    _expenseSub = _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('dt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('dt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _expenses = snapshot.docs
              .map((doc) => Expense.fromMap(doc.id, doc.data()))
              .toList();
          notifyListeners();
        });

    final yearStart = DateTime(_currentMonth.year, 1, 1);
    final yearEnd = DateTime(
      _currentMonth.year + 1,
      1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    _yearlyExpenseSub = _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('dt', isGreaterThanOrEqualTo: Timestamp.fromDate(yearStart))
        .where('dt', isLessThanOrEqualTo: Timestamp.fromDate(yearEnd))
        .orderBy('dt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _yearlyExpenses = snapshot.docs
              .map((doc) => Expense.fromMap(doc.id, doc.data()))
              .toList();
          notifyListeners();
        });
  }

  Future<void> _loadCategories() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _categorySub?.cancel();
    _categorySub = _db
        .collection('users')
        .doc(user.uid)
        .collection('finance_categories')
        .snapshots()
        .listen((snap) {
          _customCategories = snap.docs
              .map((doc) => FinanceCategory.fromMap(doc.id, doc.data()))
              .toList();
          notifyListeners();
        });
  }

  Future<void> _loadPaymentTypes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _paymentSub?.cancel();
    _paymentSub = _db
        .collection('users')
        .doc(user.uid)
        .collection('finance_payments')
        .snapshots()
        .listen((snap) {
          _customPaymentTypes = snap.docs
              .map((doc) => doc.data()['n'] as String)
              .toList();
          notifyListeners();
        });
  }

  Future<void> addPaymentType(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('finance_payments')
        .add({'n': name});
  }

  Future<void> deletePaymentType(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final query = await _db
        .collection('users')
        .doc(user.uid)
        .collection('finance_payments')
        .where('n', isEqualTo: name)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    final snaps = await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('p', isEqualTo: name)
        .get();
    if (snaps.docs.isNotEmpty) {
      final batch = _db.batch();
      for (var doc in snaps.docs) {
        // Defaulting to empty or basic payment type
        batch.update(doc.reference, {'p': 'Cash'});
      }
      await batch.commit();
    }
  }

  Future<void> addExpense(Expense expense) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .add(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(id)
        .delete();
  }

  Future<void> addCategory(FinanceCategory category) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('finance_categories')
        .add(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('finance_categories')
        .doc(id)
        .delete();

    // Find custom category id in all user expenses to update them to "others" if it exists
    final snaps = await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .where('c', isEqualTo: id)
        .get();

    if (snaps.docs.isNotEmpty) {
      final batch = _db.batch();
      for (var doc in snaps.docs) {
        batch.update(doc.reference, {'c': 'others'});
      }
      await batch.commit();
    }
  }

  FinanceCategory getCategoryById(String id) {
    if (categories.isEmpty) {
      return FinanceCategory(
        id: 'unknown',
        name: 'Unknown',
        iconCodePoint: Icons.help_outline.codePoint,
      );
    }
    return categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => categories.firstWhere(
        (c) => c.id == 'others',
        orElse: () => categories.first,
      ),
    );
  }

  void setPalette(String paletteId) {
    _selectedPaletteId = paletteId;
    notifyListeners();
    _savePalettePreference(paletteId);
  }

  Future<void> _loadPalettePreference() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()!.containsKey('finance_palette')) {
      _selectedPaletteId = doc.data()!['finance_palette'] as String;
      notifyListeners();
    }
  }

  Future<void> _savePalettePreference(String paletteId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _db.collection('users').doc(user.uid).set({
      'finance_palette': paletteId,
    }, SetOptions(merge: true));
  }
}

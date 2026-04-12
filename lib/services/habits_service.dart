import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HabitsService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _habits = [];
  Map<String, Set<String>> _logs = {};

  List<String> get habits => _habits;
  Map<String, Set<String>> get logs => _logs;

  HabitsService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToHabits(user.uid);
        _listenToHabitLogs(user.uid);
      } else {
        _habits = [];
        _logs = {};
        notifyListeners();
      }
    });
  }

  void _listenToHabits(String userId) {
    _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
          _habits.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data.containsKey('title')) {
              _habits.add(data['title'] as String);
            }
          }
          notifyListeners();
        });
  }

  void _listenToHabitLogs(String userId) {
    _db
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .snapshots()
        .listen((snapshot) {
          final newLogs = <String, Set<String>>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data.containsKey('completed')) {
              final completions = List<String>.from(data['completed']);
              newLogs[doc.id] = completions.toSet();
            }
          }
          _logs = newLogs;
          notifyListeners();
        });
  }

  Future<void> toggleHabit(String dateKey, String habit) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final logRef = _db
        .collection('users')
        .doc(userId)
        .collection('habit_logs')
        .doc(dateKey);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(logRef);
      if (!snapshot.exists) {
        transaction.set(logRef, {
          'completed': [habit],
        });
      } else {
        final data = snapshot.data()!;
        final completions = List<String>.from(data['completed'] ?? []);
        if (completions.contains(habit)) {
          completions.remove(habit);
        } else {
          completions.add(habit);
        }
        transaction.update(logRef, {'completed': completions});
      }
    });
  }

  Future<void> addHabit(String habitTitle) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.collection('users').doc(userId).collection('habits').add({
      'title': habitTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeHabit(String habitTitle) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final query = await _db
        .collection('users')
        .doc(userId)
        .collection('habits')
        .where('title', isEqualTo: habitTitle)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }
}

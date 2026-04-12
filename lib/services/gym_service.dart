import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GymService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, double> _weightLogs = {};
  Map<String, double> get weightLogs => _weightLogs;

  GymService() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToWeightLogs(user.uid);
      } else {
        _weightLogs = {};
        notifyListeners();
      }
    });
  }

  void _listenToWeightLogs(String userId) {
    _db
        .collection('users')
        .doc(userId)
        .collection('weight_logs')
        .snapshots()
        .listen((snapshot) {
          final newLogs = <String, double>{};
          for (var doc in snapshot.docs) {
            if (doc.data().containsKey('weight')) {
              newLogs[doc.id] = (doc['weight'] as num).toDouble();
            }
          }
          _weightLogs = newLogs;
          notifyListeners();
        });
  }

  Future<void> saveWeight(String dateKey, double weight) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('weight_logs')
        .doc(dateKey)
        .set({'weight': weight});
  }

  Future<void> deleteWeight(String dateKey) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('weight_logs')
        .doc(dateKey)
        .delete();
  }
}

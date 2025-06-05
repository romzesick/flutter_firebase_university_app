import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_app/services/stats_service.dart';

/// viewmodel profilu użytkownika
///
/// pobiera dane użytkownika, średnią produktywność oraz progres dnia, miesiąca i roku
/// automatycznie odświeża progres czasu co minutę
class ProfileViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _statsService = UserStatsService();

  String _userName = '';
  double _averageProductivity = 0.0;
  bool _isLoading = true;
  double _yearProgress = 0.0;
  double _monthProgress = 0.0;
  double _dayProgress = 0.0;
  Timer? _timer;

  double get yearProgress => _yearProgress;
  double get monthProgress => _monthProgress;
  double get dayProgress => _dayProgress;
  String get userName => _userName;
  double get averageProductivity => _averageProductivity;
  bool get isLoading => _isLoading;

  /// ładuje dane profilu (nazwa, produktywność, progres czasu)
  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        _userName = userDoc.data()?['name'] ?? user.displayName ?? 'User';
      }

      _averageProductivity =
          await _statsService.getCachedTotalProductivity() ?? 0.0;
      _calculateTimeProgresses();
      _startTimer();
    } catch (e) {
      print('Error loading profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// oblicza progres dnia, miesiąca i roku
  void _calculateTimeProgresses() {
    final now = DateTime.now();

    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year + 1, 1, 1);
    _yearProgress =
        now.difference(yearStart).inSeconds /
        yearEnd.difference(yearStart).inSeconds;

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    _monthProgress =
        now.difference(monthStart).inSeconds /
        monthEnd.difference(monthStart).inSeconds;

    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    _dayProgress =
        now.difference(dayStart).inSeconds /
        dayEnd.difference(dayStart).inSeconds;
  }

  /// uruchamia timer do automatycznego odświeżania czasu
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 60), (_) {
      _calculateTimeProgresses();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';

/// Serwis do obsługi statystyk produktywności użytkownika.
/// Liczy średnią produktywność, zapisuje i pobiera ją z Firestore.
class UserStatsService {
  final DayService _dayService = DayService();

  /// Oblicza średnią produktywność użytkownika
  ///
  /// Uwzględnia tylko dni, które:
  /// - są dzisiaj lub wcześniej
  /// - zawierają przynajmniej jedno zadanie
  ///
  /// Zwraca wartość od 0.0 do 1.0
  Future<double> calculateTotalProductivity() async {
    final allDays = await _dayService.fetchAllUserDays();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final relevantDays =
        allDays.where((d) {
          final dayDate = DateTime(d.date.year, d.date.month, d.date.day);
          return !dayDate.isAfter(today) && d.tasks.isNotEmpty;
        }).toList();

    if (relevantDays.isEmpty) return 0.0;

    final totalProgress = relevantDays
        .map((d) => d.progress)
        .reduce((a, b) => a + b);

    return totalProgress / relevantDays.length;
  }

  /// Zapisuje obliczoną produktywność użytkownika do Firestore
  ///
  /// Przechowywana wartość jest potem wykorzystywana do rankingu i profilu
  Future<void> updateTotalProductivity(double? productivity) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'totalProductivity': productivity,
    });
  }

  /// Pobiera ostatnio zapisaną produktywność z Firestore (bez przeliczania)
  Future<double?> getCachedTotalProductivity() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    return userDoc.data()?['totalProductivity']?.toDouble();
  }
}

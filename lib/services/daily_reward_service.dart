import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/domain/models/daily_reward_model.dart';
import 'package:firebase_flutter_app/services/rank_service.dart';

/// Serwis odpowiedzialny za codzienne nagrody użytkownika.
/// Obsługuje aktualizację streaków, przyznawanie punktów oraz komunikację z bazą danych
class DailyRewardService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Pobiera dane nagrody codziennej z Firestore
  Future<DailyRewardModel?> getRewardData() async {
    final userId = _auth.currentUser!.uid;
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists || doc.data()?['dailyReward'] == null) return null;
    return DailyRewardModel.fromJson(doc.data()!['dailyReward']);
  }

  /// Aktualizuje dane nagrody w Firestore
  Future<void> updateReward(DailyRewardModel reward) async {
    final userId = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(userId).set({
      'dailyReward': reward.toJson(),
    }, SetOptions(merge: true));
  }

  /// Sprawdza, czy streak został zachowany, czy powinien zostać zresetowany
  Future<DailyRewardModel> evaluateStreak(DailyRewardModel reward) async {
    final now = DateTime.now();
    final last = reward.lastClaimedDate;
    final daysGap =
        now.difference(DateTime(last.year, last.month, last.day)).inDays;

    if (daysGap > 1) {
      // Streak został przerwany
      return DailyRewardModel(
        currentStreak: 1,
        lastClaimedDate: reward.lastClaimedDate,
        totalPoints: reward.totalPoints,
      );
    }
    return reward;
  }

  /// Przyznaje codzienną nagrodę – punkty i streak
  Future<bool> claimDailyReward() async {
    final userId = _auth.currentUser!.uid;
    final docRef = _firestore.collection('users').doc(userId);
    final doc = await docRef.get();

    final now = DateTime.now();
    DailyRewardModel reward;

    if (!doc.exists || doc.data()?['dailyReward'] == null) {
      // Pierwsze przyznanie nagrody
      reward = DailyRewardModel(
        currentStreak: 2, // zaczynamy od 2, bo nagroda jest kliknięta
        lastClaimedDate: now,
        totalPoints: _getPointsForDay(1),
      );
    } else {
      reward = DailyRewardModel.fromJson(doc.data()!['dailyReward']);

      final last = reward.lastClaimedDate;
      final daysGap =
          now.difference(DateTime(last.year, last.month, last.day)).inDays;

      final nextStreak =
          daysGap == 1 ? reward.currentStreak + 1 : 2; // reset jeśli przerwany
      final dayInCycle = ((nextStreak - 2) % 7) + 1;

      reward = DailyRewardModel(
        currentStreak: nextStreak,
        lastClaimedDate: now,
        totalPoints: reward.totalPoints + _getPointsForDay(dayInCycle),
      );
    }

    await updateReward(reward);
    await RankService().updateUserRank(reward.totalPoints);
    return true;
  }

  /// Zwraca liczbę punktów przyznawanych w zależności od dnia streaka (1-7)
  int _getPointsForDay(int day) {
    switch (day) {
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return 40;
      case 4:
        return 60;
      case 5:
        return 80;
      case 6:
        return 110;
      case 7:
        return 150;
      default:
        return 10;
    }
  }
}

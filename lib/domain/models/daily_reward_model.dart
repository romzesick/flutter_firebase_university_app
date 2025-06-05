import 'package:cloud_firestore/cloud_firestore.dart';

/// Model reprezentujący system dziennych nagród.
class DailyRewardModel {
  final int currentStreak; // Aktualna seria (dni pod rząd z nagrodą)
  final DateTime lastClaimedDate; // Ostatnia data odbioru nagrody
  final int totalPoints; // Całkowita liczba punktów zdobytych przez użytkownika

  DailyRewardModel({
    required this.currentStreak,
    required this.lastClaimedDate,
    required this.totalPoints,
  });

  /// Tworzy instancję modelu na podstawie mapy JSON
  factory DailyRewardModel.fromJson(Map<String, dynamic> json) {
    return DailyRewardModel(
      currentStreak: json['currentStreak'] ?? 0,
      lastClaimedDate: (json['lastClaimedDate'] as Timestamp).toDate(),
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  /// Konwertuje model do formatu JSON
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'lastClaimedDate': Timestamp.fromDate(lastClaimedDate),
      'totalPoints': totalPoints,
    };
  }
}

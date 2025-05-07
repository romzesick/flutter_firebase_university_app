import 'package:cloud_firestore/cloud_firestore.dart';

class DailyRewardModel {
  final int currentStreak;
  final DateTime lastClaimedDate;
  final int totalPoints;

  DailyRewardModel({
    required this.currentStreak,
    required this.lastClaimedDate,
    required this.totalPoints,
  });

  factory DailyRewardModel.fromJson(Map<String, dynamic> json) {
    return DailyRewardModel(
      currentStreak: json['currentStreak'] ?? 0,
      lastClaimedDate: (json['lastClaimedDate'] as Timestamp).toDate(),
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'lastClaimedDate': Timestamp.fromDate(lastClaimedDate),
      'totalPoints': totalPoints,
    };
  }
}

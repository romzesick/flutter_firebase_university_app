import 'package:firebase_flutter_app/domain/models/daily_reward_model.dart';

class UserModel {
  final String uid;
  final String name;
  final int age;
  final String email;
  final DailyRewardModel dailyReward;
  final List<String> friends;
  final List<String> sentRequests;
  final List<String> friendRequests;
  final String rank;
  final double totalProductivity;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.email,
    required this.dailyReward,
    required this.friends,
    required this.sentRequests,
    required this.friendRequests,
    required this.rank,
    required this.totalProductivity,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      email: map['email'] ?? '',
      rank: map['rank'] ?? '',
      totalProductivity: (map['totalProductivity'] ?? 0.0).toDouble(),
      dailyReward:
          map['dailyReward'] != null
              ? DailyRewardModel.fromJson(map['dailyReward'])
              : DailyRewardModel(
                currentStreak: 0,
                lastClaimedDate: DateTime.now(),
                totalPoints: 0,
              ),
      friends: List<String>.from(map['friends'] ?? []),
      sentRequests: List<String>.from(map['sentRequests'] ?? []),
      friendRequests: List<String>.from(map['friendRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'rank': rank,
      'totalProductivity': totalProductivity,
      'dailyReward': dailyReward.toJson(),
      'friends': friends,
      'sentRequests': sentRequests,
      'friendRequests': friendRequests,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

class FriendsRankingViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> friendsRanking = [];
  bool isLoading = false;

  FriendsRankingViewModel() {
    loadFriendsRanking();
  }

  Future<void> loadFriendsRanking() async {
    isLoading = true;
    notifyListeners();

    try {
      final ranking = await _friendService.getFriendsWithRanking();
      friendsRanking = ranking;
    } catch (e) {
      print('Error loading friends ranking: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}

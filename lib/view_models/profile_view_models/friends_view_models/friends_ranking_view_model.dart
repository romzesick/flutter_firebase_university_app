import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

/// ViewModel odpowiedzialny za pobieranie i przechowywanie rankingu znajomych.
///
/// Pobiera listę znajomych posortowaną według `totalProductivity`
/// i udostępnia ją do wykorzystania w widżetach.
class FriendsRankingViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> friendsRanking =
      []; // lista znajomych z rankingiem
  bool isLoading = false; // stan ładowania

  FriendsRankingViewModel() {
    loadFriendsRanking(); // automatyczne ładowanie po utworzeniu
  }

  /// Ładuje ranking znajomych z serwera i powiadamia widżety.
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

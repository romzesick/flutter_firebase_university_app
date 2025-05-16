import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

/// ViewModel zarządzający przychodzącymi zaproszeniami do znajomych.
///
/// Obsługuje:
/// - ładowanie listy zaproszeń,
/// - akceptowanie zaproszenia,
/// - odrzucanie zaproszenia.
class FriendRequestsViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<Map<String, dynamic>> friendRequests = []; // lista zaproszeń
  bool isLoading = true; // status ładowania

  FriendRequestsViewModel() {
    loadFriendRequests(); // automatyczne załadowanie przy inicjalizacji
  }

  /// Pobiera listę oczekujących zaproszeń do znajomych.
  Future<void> loadFriendRequests() async {
    isLoading = true;
    notifyListeners();

    final requests = await _friendService.getFriendRequests();
    friendRequests = requests;

    isLoading = false;
    notifyListeners();
  }

  /// Akceptuje zaproszenie od użytkownika o podanym ID.
  Future<void> acceptRequest(String requesterId) async {
    await _friendService.acceptFriendRequest(requesterId);
    friendRequests.removeWhere((request) => request['id'] == requesterId);
    notifyListeners();
  }

  /// Odrzuca zaproszenie od użytkownika o podanym ID.
  Future<void> declineRequest(String requesterId) async {
    await _friendService.declineFriendRequest(requesterId);
    friendRequests.removeWhere((request) => request['id'] == requesterId);
    notifyListeners();
  }
}

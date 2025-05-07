import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

class FriendViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();

  List<Map<String, dynamic>> _friends = [];
  String? _error;
  bool _isLoading = false;

  List<Map<String, dynamic>> get friends => _friends;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _friends = await _friendService.getFriendsRanked();
    } catch (e) {
      _error = 'Failed to load friends';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendRequest(String email) async {
    try {
      await _friendService.sendFriendRequest(email);
    } catch (e) {
      _error = 'Failed to send friend request';
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requesterId) async {
    try {
      await _friendService.acceptFriendRequest(requesterId);
      await loadFriends(); // Обновляем список после принятия
    } catch (e) {
      _error = 'Failed to accept request';
      notifyListeners();
    }
  }
}

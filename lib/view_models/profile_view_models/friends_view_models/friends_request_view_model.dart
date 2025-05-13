import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

class FriendRequestsViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> friendRequests = [];
  bool isLoading = true;

  FriendRequestsViewModel() {
    loadFriendRequests();
  }

  Future<void> loadFriendRequests() async {
    isLoading = true;
    notifyListeners();

    final requests = await _friendService.getFriendRequests();
    friendRequests = requests;

    isLoading = false;
    notifyListeners();
  }

  Future<void> acceptRequest(String requesterId) async {
    await _friendService.acceptFriendRequest(requesterId);
    friendRequests.removeWhere((request) => request['id'] == requesterId);
    notifyListeners();
  }

  Future<void> declineRequest(String requesterId) async {
    await _friendService.declineFriendRequest(requesterId);
    friendRequests.removeWhere((request) => request['id'] == requesterId);
    notifyListeners();
  }
}

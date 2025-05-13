import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

class FriendsListViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> users = [];
  List<String> friendIds = [];
  List<String> pendingRequests = [];
  String searchQuery = '';

  FriendsListViewModel() {
    _fetchAllUsers();
    _loadFriendsAndRequests();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchAllUsers() async {
    final fetchedUsers = await _friendService.getAllUsers();
    users = fetchedUsers;
    notifyListeners();
  }

  Future<void> _loadFriendsAndRequests() async {
    friendIds = await _friendService.getFriendsIds();
    pendingRequests = await _friendService.getPendingRequests();
    notifyListeners();
  }

  void _onSearchChanged() {
    searchQuery = searchController.text.trim();
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.isEmpty) return users;

    List<Map<String, dynamic>> filtered =
        users
            .where(
              (user) => user['email'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();
    filtered.sort((a, b) => a['email'] == searchQuery ? -1 : 1);
    return filtered;
  }

  Future<void> sendFriendRequest(String userId) async {
    await _friendService.sendFriendRequest(userId);
    pendingRequests.add(userId);
    notifyListeners();
  }

  Future<void> removeFriend(String userId) async {
    await _friendService.removeFriend(userId);
    friendIds.remove(userId);
    notifyListeners();
  }

  bool isFriend(String userId) => friendIds.contains(userId);
  bool isPending(String userId) => pendingRequests.contains(userId);

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> removeFriendRequest(String userId) async {
    await _friendService.removeFriendRequest(userId);
    pendingRequests.remove(userId);
    notifyListeners();
  }
}

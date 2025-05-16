import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

/// ViewModel zarządzający listą użytkowników i zaproszeniami do znajomych.
///
/// Obsługuje:
/// - pobieranie wszystkich użytkowników,
/// - filtrowanie po e-mailu,
/// - sprawdzanie statusu (znajomy, oczekujący),
/// - wysyłanie i anulowanie zaproszeń,
/// - usuwanie znajomych.
class FriendsListViewModel extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> users = []; // wszyscy użytkownicy
  List<String> friendIds = []; // ID znajomych
  List<String> pendingRequests = []; // ID oczekujących zaproszeń
  String searchQuery = ''; // wpisana fraza do wyszukiwania

  FriendsListViewModel() {
    _fetchAllUsers();
    _loadFriendsAndRequests();
    searchController.addListener(_onSearchChanged);
  }

  /// Pobiera wszystkich użytkowników z wyjątkiem zalogowanego
  Future<void> _fetchAllUsers() async {
    final fetchedUsers = await _friendService.getAllUsers();
    users = fetchedUsers;
    notifyListeners();
  }

  /// Pobiera listę ID znajomych i oczekujących zaproszeń
  Future<void> _loadFriendsAndRequests() async {
    friendIds = await _friendService.getFriendsIds();
    pendingRequests = await _friendService.getPendingRequests();
    notifyListeners();
  }

  /// Aktualizuje `searchQuery` po zmianie w polu tekstowym
  void _onSearchChanged() {
    searchQuery = searchController.text.trim();
    notifyListeners();
  }

  /// Zwraca listę użytkowników dopasowanych do wyszukiwania
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

  /// Wysyła zaproszenie do znajomego
  Future<void> sendFriendRequest(String userId) async {
    await _friendService.sendFriendRequest(userId);
    pendingRequests.add(userId);
    notifyListeners();
  }

  /// Usuwa użytkownika z listy znajomych
  Future<void> removeFriend(String userId) async {
    await _friendService.removeFriend(userId);
    friendIds.remove(userId);
    notifyListeners();
  }

  /// Zwraca `true`, jeśli użytkownik jest znajomym
  bool isFriend(String userId) => friendIds.contains(userId);

  /// Zwraca `true`, jeśli zaproszenie zostało już wysłane
  bool isPending(String userId) => pendingRequests.contains(userId);

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  /// Anuluje zaproszenie do znajomego
  Future<void> removeFriendRequest(String userId) async {
    await _friendService.removeFriendRequest(userId);
    pendingRequests.remove(userId);
    notifyListeners();
  }
}

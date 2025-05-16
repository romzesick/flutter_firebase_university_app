import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

/// Notyfikator śledzący liczbę oczekujących zaproszeń do znajomych.
///
/// Używa strumienia `snapshots()` do nasłuchiwania zmian w kolekcji `users`,
/// automatycznie aktualizując `requestCount` i powiadamiając widżety.
class FriendRequestsNotifier extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  int requestCount = 0; // liczba oczekujących zaproszeń
  StreamSubscription<DocumentSnapshot>? _subscription;

  FriendRequestsNotifier() {
    _listenForRequests(); // rozpoczęcie nasłuchiwania przy tworzeniu
  }

  /// Nasłuchuje zmian w dokumencie użytkownika i aktualizuje liczbę zaproszeń.
  void _listenForRequests() {
    final userId = _friendService.currentUserId;

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final List<dynamic> requests =
                snapshot.data()?['friendRequests'] ?? [];
            requestCount = requests.length;
            notifyListeners();
          }
        });
  }

  /// Anuluje subskrypcję strumienia przy usuwaniu obiektu.
  @override
  void dispose() {
    _subscription?.cancel();
    print('disposed');
    super.dispose();
  }
}

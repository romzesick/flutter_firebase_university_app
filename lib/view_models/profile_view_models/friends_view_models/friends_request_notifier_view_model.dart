import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_app/services/friend_service.dart';

class FriendRequestsNotifier extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  int requestCount = 0;
  StreamSubscription<DocumentSnapshot>? _subscription;

  FriendRequestsNotifier() {
    _listenForRequests();
  }

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

  @override
  void dispose() {
    _subscription?.cancel();
    print('disposed');
    super.dispose();
  }
}

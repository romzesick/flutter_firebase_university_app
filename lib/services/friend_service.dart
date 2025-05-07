// friend_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Future<void> sendFriendRequest(String targetUserId) async {
    final userDoc = _firestore.collection('users').doc(targetUserId);
    await userDoc.set({
      'friendRequests': FieldValue.arrayUnion([currentUserId]),
    }, SetOptions(merge: true));
  }

  Future<void> acceptFriendRequest(String fromUserId) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUserId);
    final fromUserDoc = _firestore.collection('users').doc(fromUserId);

    // Добавляем друг друга в друзья
    await currentUserDoc.set({
      'friends': FieldValue.arrayUnion([fromUserId]),
      'friendRequests': FieldValue.arrayRemove([fromUserId]),
    }, SetOptions(merge: true));

    await fromUserDoc.set({
      'friends': FieldValue.arrayUnion([currentUserId]),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getFriendsRanked() async {
    final userSnap =
        await _firestore.collection('users').doc(currentUserId).get();
    final List<dynamic> friendIds = userSnap.data()?['friends'] ?? [];

    final List<Map<String, dynamic>> friends = [];

    for (final friendId in friendIds) {
      final doc = await _firestore.collection('users').doc(friendId).get();
      final data = doc.data();
      if (data != null) {
        final productivity =
            (data['totalProductivity'] as num?)?.toDouble() ?? 0.0;
        friends.add({
          'id': friendId,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'totalProductivity': productivity,
        });
      }
    }

    friends.sort(
      (a, b) => (b['totalProductivity'] as double).compareTo(
        a['totalProductivity'] as double,
      ),
    );

    return friends;
  }
}

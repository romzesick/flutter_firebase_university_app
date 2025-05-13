// friend_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      final users =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'email': data['email'] ?? 'Unknown',
              'name': data['name'] ?? 'No Name',
            };
          }).toList();

      // Исключаем текущего пользователя из списка
      return users.where((user) => user['id'] != currentUserId).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<List<String>> getFriendsIds() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    return List<String>.from(userDoc.data()?['friends'] ?? []);
  }

  Future<List<String>> getPendingRequests() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    return List<String>.from(userDoc.data()?['sentRequests'] ?? []);
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    final userDoc = _firestore.collection('users').doc(currentUserId);
    await userDoc.set({
      'sentRequests': FieldValue.arrayUnion([targetUserId]),
    }, SetOptions(merge: true));

    final targetDoc = _firestore.collection('users').doc(targetUserId);
    await targetDoc.set({
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

  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final List<dynamic> requestIds = userDoc.data()?['friendRequests'] ?? [];

    List<Map<String, dynamic>> requests = [];

    for (String id in requestIds) {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        requests.add({
          'id': id,
          'email': doc.data()?['email'] ?? 'Unknown',
          'name': doc.data()?['name'] ?? 'No Name',
        });
      }
    }

    return requests;
  }

  Future<void> removeFriendRequest(String targetUserId) async {
    final userDoc = _firestore.collection('users').doc(currentUserId);
    await userDoc.update({
      'sentRequests': FieldValue.arrayRemove([targetUserId]),
    });

    final targetDoc = _firestore.collection('users').doc(targetUserId);
    await targetDoc.update({
      'friendRequests': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<void> declineFriendRequest(String requesterId) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUserId);
    final requesterDoc = _firestore.collection('users').doc(requesterId);

    // Удаляем запрос у получателя
    await currentUserDoc.update({
      'friendRequests': FieldValue.arrayRemove([requesterId]),
    });

    // Удаляем запрос у отправителя
    await requesterDoc.update({
      'sentRequests': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<int> getRequestCount() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final List<dynamic> requests = userDoc.data()?['friendRequests'] ?? [];
    return requests.length;
  }

  Future<List<Map<String, dynamic>>> getFriendsWithRanking() async {
    final userSnap =
        await _firestore.collection('users').doc(currentUserId).get();
    final List<dynamic> friendIds = userSnap.data()?['friends'] ?? [];
    final double userProductivity =
        (userSnap.data()?['totalProductivity'] as num?)?.toDouble() ?? 0.0;

    final List<Map<String, dynamic>> rankingList = [];

    // Добавляем текущего пользователя
    rankingList.add({
      'id': currentUserId,
      'name': userSnap.data()?['name'] ?? 'You',
      'email': userSnap.data()?['email'] ?? 'Unknown',
      'totalProductivity': userProductivity,
      'isCurrentUser': true,
    });

    // Добавляем друзей
    if (friendIds.isNotEmpty) {
      final friendsSnap =
          await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: friendIds)
              .get();
      for (var doc in friendsSnap.docs) {
        rankingList.add({
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unknown',
          'email': doc.data()['email'] ?? '',
          'totalProductivity':
              (doc.data()['totalProductivity'] as num?)?.toDouble() ?? 0.0,
          'isCurrentUser': false,
        });
      }
    }

    // Сортируем по `totalProductivity` в порядке убывания
    rankingList.sort(
      (a, b) => (b['totalProductivity'] as double).compareTo(
        a['totalProductivity'] as double,
      ),
    );

    return rankingList;
  }

  Future<void> removeFriend(String targetUserId) async {
    final userDoc = _firestore.collection('users').doc(currentUserId);
    final targetDoc = _firestore.collection('users').doc(targetUserId);

    // Удаляем друга из списка текущего пользователя
    await userDoc.update({
      'friends': FieldValue.arrayRemove([targetUserId]),
    });

    // Удаляем текущего пользователя из списка друга
    await targetDoc.update({
      'friends': FieldValue.arrayRemove([currentUserId]),
    });
  }
}

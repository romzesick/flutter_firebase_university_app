import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Pobiera identyfikator aktualnie zalogowanego użytkownika
  String get currentUserId => _auth.currentUser!.uid;

  /// Pobiera listę wszystkich użytkowników oprócz aktualnego
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

      // Usuwa aktualnego użytkownika z listy
      return users.where((user) => user['id'] != currentUserId).toList();
    } catch (e) {
      print('Błąd podczas pobierania użytkowników: $e');
      return [];
    }
  }

  /// Pobiera listę ID przyjaciół aktualnego użytkownika
  Future<List<String>> getFriendsIds() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    return List<String>.from(userDoc.data()?['friends'] ?? []);
  }

  /// Pobiera listę oczekujących wysłanych zaproszeń
  Future<List<String>> getPendingRequests() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    return List<String>.from(userDoc.data()?['sentRequests'] ?? []);
  }

  /// Wysyła zaproszenie do znajomych
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

  /// Akceptuje zaproszenie od innego użytkownika
  Future<void> acceptFriendRequest(String fromUserId) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUserId);
    final fromUserDoc = _firestore.collection('users').doc(fromUserId);

    await currentUserDoc.set({
      'friends': FieldValue.arrayUnion([fromUserId]),
      'friendRequests': FieldValue.arrayRemove([fromUserId]),
    }, SetOptions(merge: true));

    await fromUserDoc.set({
      'friends': FieldValue.arrayUnion([currentUserId]),
    }, SetOptions(merge: true));
  }

  /// Pobiera listę przyjaciół wraz z ich produktywnością, posortowaną malejąco
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

  /// Pobiera listę przychodzących zaproszeń do znajomych
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

  /// Usuwa wysłane zaproszenie do znajomych
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

  /// Odrzuca zaproszenie do znajomych
  Future<void> declineFriendRequest(String requesterId) async {
    final currentUserDoc = _firestore.collection('users').doc(currentUserId);
    final requesterDoc = _firestore.collection('users').doc(requesterId);

    await currentUserDoc.update({
      'friendRequests': FieldValue.arrayRemove([requesterId]),
    });

    await requesterDoc.update({
      'sentRequests': FieldValue.arrayRemove([currentUserId]),
    });
  }

  /// Zwraca liczbę przychodzących zaproszeń
  Future<int> getRequestCount() async {
    final userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final List<dynamic> requests = userDoc.data()?['friendRequests'] ?? [];
    return requests.length;
  }

  /// Pobiera listę przyjaciół i użytkownika z rankingiem produktywności
  Future<List<Map<String, dynamic>>> getFriendsWithRanking() async {
    final userSnap =
        await _firestore.collection('users').doc(currentUserId).get();
    final List<dynamic> friendIds = userSnap.data()?['friends'] ?? [];
    final double userProductivity =
        (userSnap.data()?['totalProductivity'] as num?)?.toDouble() ?? 0.0;

    final List<Map<String, dynamic>> rankingList = [];

    // Dodajemy aktualnego użytkownika
    rankingList.add({
      'id': currentUserId,
      'name': userSnap.data()?['name'] ?? 'You',
      'email': userSnap.data()?['email'] ?? 'Unknown',
      'totalProductivity': userProductivity,
      'isCurrentUser': true,
    });

    // Dodajemy przyjaciół
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

    // Sortujemy według produktywności
    rankingList.sort(
      (a, b) => (b['totalProductivity'] as double).compareTo(
        a['totalProductivity'] as double,
      ),
    );

    return rankingList;
  }

  /// Usuwa znajomego (z obu stron)
  Future<void> removeFriend(String targetUserId) async {
    final userDoc = _firestore.collection('users').doc(currentUserId);
    final targetDoc = _firestore.collection('users').doc(targetUserId);

    await userDoc.update({
      'friends': FieldValue.arrayRemove([targetUserId]),
    });

    await targetDoc.update({
      'friends': FieldValue.arrayRemove([currentUserId]),
    });
  }
}

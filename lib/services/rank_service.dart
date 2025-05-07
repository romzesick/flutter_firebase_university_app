import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/domain/models/rank_model.dart';

class RankService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<RankModel>> getAllRanks() async {
    final snapshot =
        await _firestore.collection('ranks').orderBy('minPoints').get();

    return snapshot.docs.map((doc) => RankModel.fromJson(doc.data())).toList();
  }

  Future<RankModel?> getUserRank() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    if (data == null || data['dailyReward'] == null) return null;
    final totalPoints = data['dailyReward']['totalPoints'] as int? ?? 0;

    final ranks = await getAllRanks();

    RankModel? currentRank;
    for (final rank in ranks) {
      if (totalPoints >= rank.minPoints) {
        currentRank = rank;
      } else {
        break;
      }
    }

    if (currentRank != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'rank': currentRank.name,
      }, SetOptions(merge: true));
    }

    return currentRank;
  }

  Future<void> updateUserRank(int totalPoints) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    final snapshot =
        await firestore.collection('ranks').orderBy('minPoints').get();

    String currentRank = 'Unranked';
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (totalPoints >= (data['minPoints'] ?? 0)) {
        currentRank = data['name'] ?? 'Unknown';
      } else {
        break;
      }
    }

    await firestore.collection('users').doc(userId).set({
      'rank': currentRank,
    }, SetOptions(merge: true));
  }

  Future<int> getUserTotalPoints() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final data = userDoc.data();

    if (data == null || data['dailyReward'] == null) return 0;
    return data['dailyReward']['totalPoints'] as int? ?? 0;
  }
}

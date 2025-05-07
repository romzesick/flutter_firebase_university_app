import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';

class UserStatsService {
  final DayService _dayService = DayService();

  Future<double> calculateTotalProductivity() async {
    final allDays = await _dayService.fetchAllUserDays();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final relevantDays =
        allDays.where((d) {
          final dayDate = DateTime(d.date.year, d.date.month, d.date.day);
          return !dayDate.isAfter(today) && d.tasks.isNotEmpty;
        }).toList();

    if (relevantDays.isEmpty) return 0.0;

    final totalProgress = relevantDays
        .map((d) => d.progress)
        .reduce((a, b) => a + b);

    return totalProgress / relevantDays.length;
  }

  // сюда мы помещаем, ту продуктивность, что мы считаем выше
  Future<void> updateTotalProductivity(double? productivity) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'totalProductivity': productivity,
    });
  }

  Future<double?> getCachedTotalProductivity() async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    return userDoc.data()?['totalProductivity']?.toDouble();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/domain/models/day_model.dart';
import 'package:firebase_flutter_app/domain/models/task_model.dart';

class DayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _daysCollection =>
      _firestore.collection('users').doc(_userId).collection('days');

  /// Получить данные о дне
  Future<DayModel?> fetchDay(DateTime date) async {
    final docId = _dateToId(date);
    final doc = await _daysCollection.doc(docId).get();

    if (doc.exists) {
      return DayModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }

  /// Создать или обновить день
  Future<void> saveDay(DayModel day) async {
    final docId = _dateToId(day.date);
    await _daysCollection.doc(docId).set(day.toJson());
  }

  /// Добавить новую задачу в день
  Future<void> addTaskToDay(DateTime date, TaskModel task) async {
    final existingDay = await fetchDay(date);
    final updatedTasks = [...(existingDay?.tasks ?? <TaskModel>[]), task];

    final progress = _calculateProgress(updatedTasks);

    final updatedDay = DayModel(
      date: date,
      tasks: updatedTasks,
      note: existingDay?.note,
      progress: progress,
    );

    await saveDay(updatedDay);
  }

  /// Обновить задачу (например, изменить done)
  Future<void> updateTaskInDay(DateTime date, TaskModel updatedTask) async {
    final existingDay = await fetchDay(date);
    if (existingDay == null) return;

    final updatedTasks =
        existingDay.tasks
            .map((task) => task.id == updatedTask.id ? updatedTask : task)
            .toList();

    final progress = _calculateProgress(updatedTasks);

    final updatedDay = DayModel(
      date: date,
      tasks: updatedTasks,
      note: existingDay.note,
      progress: progress,
    );

    await saveDay(updatedDay);
  }

  /// Удалить задачу
  Future<void> deleteTaskFromDay(DateTime date, String taskId) async {
    final existingDay = await fetchDay(date);
    if (existingDay == null) return;

    final updatedTasks =
        existingDay.tasks.where((task) => task.id != taskId).toList();

    final progress = _calculateProgress(updatedTasks);

    final updatedDay = DayModel(
      date: date,
      tasks: updatedTasks,
      note: existingDay.note,
      progress: progress,
    );

    await saveDay(updatedDay);
  }

  /// Добавить или обновить заметку к дню
  Future<void> updateNoteForDay(DateTime date, String note) async {
    final existingDay = await fetchDay(date);

    final updatedDay = DayModel(
      date: date,
      tasks: existingDay?.tasks ?? <TaskModel>[],
      note: note,
      progress: existingDay?.progress ?? 0.0,
    );

    await saveDay(updatedDay);
  }

  /// Перевести дату в ID для документа (например, "2025-04-30")
  String _dateToId(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Подсчитать прогресс задач
  double _calculateProgress(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((task) => task.done).length;
    return completed / tasks.length;
  }

  /// Перенести задачу на завтра
  Future<void> moveTaskToTomorrow(DateTime currentDay, String taskId) async {
    final day = await fetchDay(currentDay);
    if (day == null) return;

    final task = day.tasks.firstWhere((t) => t.id == taskId);

    // Удаляем из сегодняшнего дня
    final updatedTasks = day.tasks.where((t) => t.id != taskId).toList();

    await saveDay(
      DayModel(
        date: currentDay,
        tasks: updatedTasks,
        note: day.note,
        progress: _calculateProgress(updatedTasks),
      ),
    );

    // Добавляем задачу в завтрашний день
    final tomorrow = currentDay.add(const Duration(days: 1));
    await addTaskToDay(tomorrow, task);
  }

  Future<List<DayModel>> fetchAllUserDays() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('days')
            .get();

    return snapshot.docs.map((doc) => DayModel.fromJson(doc.data())).toList();
  }
}

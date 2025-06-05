import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/domain/models/day_model.dart';
import 'package:firebase_flutter_app/domain/models/task_model.dart';

/// Serwis do zarządzania danymi dnia w Firestore.
/// Obsługuje zadania, notatki, postęp oraz operacje typu dodaj, usuń, przenieś.
class DayService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ID aktualnie zalogowanego użytkownika
  String get _userId => _auth.currentUser!.uid;

  /// Kolekcja dni użytkownika
  CollectionReference<Map<String, dynamic>> get _daysCollection =>
      _firestore.collection('users').doc(_userId).collection('days');

  /// Pobierz dane dnia z Firestore (jeśli istnieją)
  Future<DayModel?> fetchDay(DateTime date) async {
    final docId = _dateToId(date);
    final doc = await _daysCollection.doc(docId).get();

    if (doc.exists) {
      return DayModel.fromJson(doc.data()!);
    } else {
      return null;
    }
  }

  /// Zapisz (stwórz lub zaktualizuj) dzień w Firestore
  Future<void> saveDay(DayModel day) async {
    final docId = _dateToId(day.date);
    await _daysCollection.doc(docId).set(day.toJson());
  }

  /// Dodaj nowe zadanie do konkretnego dnia
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

  /// Zaktualizuj istniejące zadanie w dniu
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

  /// Usuń zadanie z dnia
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

  /// Zaktualizuj lub dodaj notatkę do dnia
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

  /// Konwertuj datę do formatu dokumentu Firestore, np. "2025-05-16"
  String _dateToId(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Oblicz postęp na podstawie listy zadań
  double _calculateProgress(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((task) => task.done).length;
    return completed / tasks.length;
  }

  /// Przenieś zadanie z bieżącego dnia na jutro
  Future<void> moveTaskToTomorrow(DateTime currentDay, String taskId) async {
    final day = await fetchDay(currentDay);
    if (day == null) return;

    final task = day.tasks.firstWhere((t) => t.id == taskId);

    // Usuń zadanie z aktualnego dnia
    final updatedTasks = day.tasks.where((t) => t.id != taskId).toList();

    await saveDay(
      DayModel(
        date: currentDay,
        tasks: updatedTasks,
        note: day.note,
        progress: _calculateProgress(updatedTasks),
      ),
    );

    // Dodaj to samo zadanie do jutra
    final tomorrow = currentDay.add(const Duration(days: 1));
    await addTaskToDay(tomorrow, task);
  }

  /// Pobierz wszystkie dni użytkownikaa
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

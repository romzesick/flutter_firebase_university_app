import 'package:firebase_flutter_app/services/stats_service.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/day_model.dart';
import 'package:firebase_flutter_app/domain/models/task_model.dart';
import 'package:uuid/uuid.dart';

/// ViewModel odpowiedzialny za logikę zarządzania zadaniami dnia:
/// - ładowanie danych z dnia
/// - dodawanie, usuwanie, edytowanie zadań
/// - postęp i produktywność
/// - notatki i animacje sukcesu
class DayTasksViewModel extends ChangeNotifier {
  final UserStatsService _statsService = UserStatsService();
  final DayService _dayService = DayService();
  final _uuid = const Uuid();

  DateTime _selectedDate = DateTime.now();
  DayModel? _currentDay;
  bool _isLoading = false;
  String? _errorMessage;
  List<TaskModel> _tasks = [];
  double? _totalProductivity;

  // GETTERY
  double? get totalProductivity => _totalProductivity;
  List<TaskModel> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;
  DayModel? get currentDay => _currentDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Ładowanie danych dnia z bazy
  Future<void> loadDay(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentDay = await _dayService.fetchDay(date);
      _tasks = _currentDay?.tasks ?? [];
      _updateOrCreateCurrentDay();
      await _refreshTotalProductivity();
    } catch (e) {
      _errorMessage = 'Failed to load day: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Dodanie nowego zadania do listy
  Future<void> addTask(String text) async {
    final newTask = TaskModel(id: _uuid.v4(), text: text, done: false);
    _tasks.add(newTask);
    _updateOrCreateCurrentDay();
    notifyListeners();

    try {
      await _dayService.saveDay(_currentDay!);
      await _refreshTotalProductivity();
    } catch (e) {
      _tasks.removeWhere((t) => t.id == newTask.id);
      _updateOrCreateCurrentDay();
      _setError('Failed to add task: $e');
    }
    notifyListeners();
  }

  /// Aktualizacja istniejącego zadania
  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    _tasks[index] = updatedTask;
    _updateOrCreateCurrentDay();
    notifyListeners();

    try {
      await _dayService.saveDay(_currentDay!);
      await _refreshTotalProductivity();
    } catch (e) {
      _tasks[index] = oldTask;
      _updateOrCreateCurrentDay();
      _setError('Failed to update task: $e');
    }
    notifyListeners();
  }

  /// Przełączanie statusu ukończenia zadania
  Future<void> toggleTaskDone(TaskModel task) async {
    final updatedTask = task.copyWith(done: !task.done);
    await updateTask(updatedTask);
  }

  /// Usunięcie zadania z listy
  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => TaskModel(id: '', text: '', done: false),
    );
    if (task.id.isEmpty) return;

    _tasks.remove(task);
    _updateOrCreateCurrentDay();
    notifyListeners();

    try {
      await _dayService.saveDay(_currentDay!);
      await _refreshTotalProductivity();
    } catch (e) {
      _tasks.add(task);
      _updateOrCreateCurrentDay();
      _setError('Failed to delete task: $e');
    }
    notifyListeners();
  }

  /// Przeniesienie zadania na jutro
  Future<void> moveTaskToTomorrow(String taskId) async {
    final task = _tasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => TaskModel(id: '', text: '', done: false),
    );
    if (task.id.isEmpty) return;

    _tasks.remove(task);
    _updateOrCreateCurrentDay();
    notifyListeners();

    try {
      await _dayService.moveTaskToTomorrow(_selectedDate, taskId);
      await _refreshTotalProductivity();
    } catch (e) {
      _tasks.add(task);
      _updateOrCreateCurrentDay();
      _setError('Failed to move task: $e');
    }
    notifyListeners();
  }

  /// Zapisanie nowej notatki dla danego dnia
  Future<void> updateNote(String note) async {
    try {
      await _dayService.updateNoteForDay(_selectedDate, note);
    } catch (e) {
      _setError('Failed to update note: $e');
    }
    notifyListeners();
  }

  /// Zmiana wybranej daty (z przeładowaniem zadań)
  Future<void> changeSelectedDate(DateTime date) async {
    await loadDay(date);
  }

  /// Odświeżenie globalnej produktywności użytkownika
  Future<void> _refreshTotalProductivity() async {
    final productivity = await _statsService.calculateTotalProductivity();
    _totalProductivity = productivity;
    await _statsService.updateTotalProductivity(productivity);
  }

  /// Tworzy lub aktualizuje model dnia na podstawie listy zadań
  void _updateOrCreateCurrentDay() {
    final progress = _calculateProgress();
    if (_currentDay == null) {
      _currentDay = DayModel(
        date: _selectedDate,
        tasks: _tasks,
        note: '',
        progress: progress,
      );
    } else {
      _currentDay = _currentDay!.copyWith(tasks: _tasks, progress: progress);
    }
    _checkCompletion();
  }

  /// Oblicza procent ukończonych zadań
  double _calculateProgress() {
    if (_tasks.isEmpty) return 0.0;
    final completed = _tasks.where((t) => t.done).length;
    return completed / _tasks.length;
  }

  /// Ustawia komunikat o błędzie
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Czyści błędy
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Czy wyświetlać animację ukończenia
  bool _showCompletionGif = false;
  bool get showCompletionGif => _showCompletionGif;

  /// Sprawdza czy wszystkie zadania zostały ukończone – wyświetla animację
  void _checkCompletion() {
    final isCompleted = _tasks.isNotEmpty && _tasks.every((t) => t.done);
    if (isCompleted && !_showCompletionGif) {
      _showCompletionGif = true;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _showCompletionGif = false;
        notifyListeners();
      });
    }
  }
}

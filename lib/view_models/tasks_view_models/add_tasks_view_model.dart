import 'package:firebase_flutter_app/domain/models/task_model.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/task_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Klasa stanu dla AddTaskViewModel.
/// Przechowuje: tekst zadania, status ładowania, ewentualny błąd.
class _AddTaskViewModelState {
  final String text;
  final bool isLoading;
  final String? error;

  const _AddTaskViewModelState({
    this.text = '',
    this.isLoading = false,
    this.error,
  });

  _AddTaskViewModelState copyWith({
    String? text,
    bool? isLoading,
    String? error,
  }) {
    return _AddTaskViewModelState(
      text: text ?? this.text,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// ViewModel do dodawania i edytowania zadania.
/// Obsługuje: inicjalizację z istniejącym zadaniem, zapis, walidację i błędy.
class AddTaskViewModel extends ChangeNotifier {
  _AddTaskViewModelState _state = const _AddTaskViewModelState();
  _AddTaskViewModelState get state => _state;

  String get text => _state.text;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  TaskModel? _editingTask; // <-- zadanie do edycji (jeśli istnieje)

  /// Inicjalizacja ViewModelu (jeśli przekazano istniejące zadanie — tryb edycji)
  void init(TaskModel? task) {
    if (task != null) {
      _editingTask = task;
      _state = _state.copyWith(text: task.text);
    }
  }

  /// Obsługuje zmianę tekstu w polu
  void changeText(String value) {
    _state = _state.copyWith(text: value);
    notifyListeners();
  }

  /// Zapisuje nowe lub edytowane zadanie
  Future<void> saveTask(BuildContext context) async {
    if (text.trim().isEmpty) {
      _setError('Task cannot be empty');
      return;
    }

    _setLoading(true);

    try {
      final dayTasksViewModel = context.read<DayTasksViewModel>();

      if (_editingTask == null) {
        // Dodajemy nowe zadanie
        await dayTasksViewModel.addTask(text.trim());
      } else {
        // Aktualizujemy istniejące
        final updatedTask = _editingTask!.copyWith(text: text.trim());
        await dayTasksViewModel.updateTask(updatedTask);
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // Zamykamy stronę
      }
    } catch (e) {
      _setError('Failed to save task: $e');
    }

    _setLoading(false);
  }

  /// Ustawia status ładowania
  void _setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  /// Ustawia błąd do wyświetlenia
  void _setError(String message) {
    _state = _state.copyWith(error: message);
    notifyListeners();
  }
}

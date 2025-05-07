import 'package:firebase_flutter_app/domain/models/task_model.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/task_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class AddTaskViewModel extends ChangeNotifier {
  _AddTaskViewModelState _state = const _AddTaskViewModelState();
  _AddTaskViewModelState get state => _state;

  String get text => _state.text;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  TaskModel? _editingTask; // <--- ДОБАВЛЕНО: сюда сохраним редактируемую задачу

  void init(TaskModel? task) {
    // <--- ДОБАВЛЕНО: инициализация для редактирования
    if (task != null) {
      _editingTask = task;
      _state = _state.copyWith(text: task.text);
    }
  }

  void changeText(String value) {
    _state = _state.copyWith(text: value);
    notifyListeners();
  }

  Future<void> saveTask(BuildContext context) async {
    if (text.trim().isEmpty) {
      _setError('Task cannot be empty');
      return;
    }

    _setLoading(true);

    try {
      final dayTasksViewModel = context.read<DayTasksViewModel>();

      if (_editingTask == null) {
        // Новая задача
        await dayTasksViewModel.addTask(text.trim());
      } else {
        // Редактирование задачи
        final updatedTask = _editingTask!.copyWith(text: text.trim());
        await dayTasksViewModel.updateTask(updatedTask);
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _setError('Failed to save task: $e');
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  void _setError(String message) {
    _state = _state.copyWith(error: message);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/goal_model.dart';
import 'package:firebase_flutter_app/domain/models/goal_steps_model.dart';
import 'package:firebase_flutter_app/services/goals_service.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalsService _goalsService = GoalsService();

  List<GoalModel> _goals = [];
  String? _error;
  bool _isLoading = false;
  bool _isDisposed = false;

  List<GoalModel> get goals => _goals;
  String? get error => _error;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadGoals({bool completed = false}) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _goals = await _goalsService.fetchGoals(completed: completed);
    } catch (e) {
      _error = 'Failed to load goals: $e';
    }

    _isLoading = false;
    _safeNotifyListeners();
  }

  Future<String?> addGoalAndReturnId(String title) async {
    try {
      final id = await _goalsService.addGoalAndReturnId(title);
      final newGoal = GoalModel(
        id: id,
        title: title,
        progress: 0.0,
        steps: [],
        completed: false,
      );
      _goals.add(newGoal);
      _safeNotifyListeners();
      return id;
    } catch (e) {
      _error = 'Failed to create goal: $e';
      _safeNotifyListeners();
      return null;
    }
  }

  Future<void> updateGoal(GoalModel updatedGoal) async {
    try {
      await _goalsService.updateGoal(updatedGoal);
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        _safeNotifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update goal: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _goalsService.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to delete goal: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> addStep(String goalId, String text) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;

      final goal = _goals[goalIndex];
      final step = GoalStepModel(id: UniqueKey().toString(), text: text);
      final updatedSteps = [...goal.steps, step];
      final updatedProgress = _goalsService.calculateProgress(updatedSteps);
      final updatedGoal = goal.copyWith(
        steps: updatedSteps,
        progress: updatedProgress,
        completed: updatedProgress == 1.0,
      );

      await _goalsService.updateGoal(updatedGoal);
      _goals[goalIndex] = updatedGoal;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to add step: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> updateStep(String goalId, GoalStepModel updatedStep) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;

      final goal = _goals[goalIndex];
      final updatedSteps =
          goal.steps
              .map((s) => s.id == updatedStep.id ? updatedStep : s)
              .toList();
      final updatedProgress = _goalsService.calculateProgress(updatedSteps);
      final updatedGoal = goal.copyWith(
        steps: updatedSteps,
        progress: updatedProgress,
        completed: updatedProgress == 1.0,
      );

      await _goalsService.updateGoal(updatedGoal);
      _goals[goalIndex] = updatedGoal;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to update step: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> deleteStep(String goalId, String stepId) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;

      final goal = _goals[goalIndex];
      final updatedSteps = goal.steps.where((s) => s.id != stepId).toList();
      final updatedProgress = _goalsService.calculateProgress(updatedSteps);
      final updatedGoal = goal.copyWith(
        steps: updatedSteps,
        progress: updatedProgress,
        completed: updatedProgress == 1.0,
      );

      await _goalsService.updateGoal(updatedGoal);
      _goals[goalIndex] = updatedGoal;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to delete step: $e';
      _safeNotifyListeners();
    }
  }

  Future<void> toggleStepDone(String goalId, String stepId) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return;

      final goal = _goals[goalIndex];
      final updatedSteps =
          goal.steps
              .map((s) => s.id == stepId ? s.copyWith(done: !s.done) : s)
              .toList();

      final updatedProgress = _goalsService.calculateProgress(updatedSteps);
      final updatedGoal = goal.copyWith(
        steps: updatedSteps,
        progress: updatedProgress,
        completed: updatedProgress == 1.0,
      );

      await _goalsService.updateGoal(updatedGoal);
      _goals[goalIndex] = updatedGoal;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to toggle step: $e';
      _safeNotifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }
}

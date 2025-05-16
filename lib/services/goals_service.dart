import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/domain/models/goal_model.dart';
import 'package:firebase_flutter_app/domain/models/goal_steps_model.dart';
import 'package:uuid/uuid.dart';

/// Serwis do zarządzania celami użytkownika (Firestore).
/// Obsługuje CRUD dla celów i ich kroków.
class GoalsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // ID aktualnie zalogowanego użytkownika
  String get _userId => _auth.currentUser!.uid;

  // Referencja do kolekcji "goals" danego użytkownika
  CollectionReference get _goalsCollection =>
      _firestore.collection('users').doc(_userId).collection('goals');

  /// Dodaje nowy cel i zwraca jego ID
  Future<String> addGoalAndReturnId(String title) async {
    final id = _uuid.v4();
    final goal = GoalModel(
      id: id,
      title: title,
      progress: 0.0,
      steps: [],
      completed: false,
    );
    await _goalsCollection.doc(id).set(goal.toJson());
    return id;
  }

  /// Pobiera wszystkie cele użytkownika (domyślnie nieukończone)
  Future<List<GoalModel>> fetchGoals({bool completed = false}) async {
    final snapshot =
        await _goalsCollection.where('completed', isEqualTo: completed).get();

    return snapshot.docs
        .map((doc) => GoalModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Aktualizuje istniejący cel (cały dokument)
  Future<void> updateGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.id).set(goal.toJson());
  }

  /// Usuwa cel na podstawie jego ID
  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }

  /// Dodaje nowy krok do wybranego celu
  Future<void> addStep(String goalId, String text) async {
    final snapshot = await _goalsCollection.doc(goalId).get();
    if (!snapshot.exists) return;

    final goal = GoalModel.fromJson(snapshot.data() as Map<String, dynamic>);
    final step = GoalStepModel(id: _uuid.v4(), text: text);
    final updatedSteps = [...goal.steps, step];

    final updatedProgress = calculateProgress(updatedSteps);
    final updatedGoal = goal.copyWith(
      steps: updatedSteps,
      progress: updatedProgress,
      completed: updatedProgress == 1.0,
    );

    await updateGoal(updatedGoal);
  }

  /// Aktualizuje konkretny krok w celu
  Future<void> updateStep(String goalId, GoalStepModel updatedStep) async {
    final snapshot = await _goalsCollection.doc(goalId).get();
    if (!snapshot.exists) return;

    final goal = GoalModel.fromJson(snapshot.data() as Map<String, dynamic>);
    final updatedSteps =
        goal.steps
            .map((s) => s.id == updatedStep.id ? updatedStep : s)
            .toList();
    final updatedProgress = calculateProgress(updatedSteps);

    final updatedGoal = goal.copyWith(
      steps: updatedSteps,
      progress: updatedProgress,
      completed: updatedProgress == 1.0,
    );
    await updateGoal(updatedGoal);
  }

  /// Usuwa krok z listy kroków celu
  Future<void> deleteStep(String goalId, String stepId) async {
    final snapshot = await _goalsCollection.doc(goalId).get();
    if (!snapshot.exists) return;

    final goal = GoalModel.fromJson(snapshot.data() as Map<String, dynamic>);
    final updatedSteps = goal.steps.where((s) => s.id != stepId).toList();
    final updatedProgress = calculateProgress(updatedSteps);

    final updatedGoal = goal.copyWith(
      steps: updatedSteps,
      progress: updatedProgress,
      completed: updatedProgress == 1.0,
    );
    await updateGoal(updatedGoal);
  }

  /// Oblicza procentowy postęp wykonanych kroków
  double calculateProgress(List<GoalStepModel> steps) {
    if (steps.isEmpty) return 0.0;
    final completed = steps.where((s) => s.done).length;
    return completed / steps.length;
  }
}

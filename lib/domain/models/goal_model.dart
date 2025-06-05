import 'package:firebase_flutter_app/domain/models/goal_steps_model.dart';

/// Model celu długoterminowego użytkownika.
///
/// Zawiera identyfikator, tytuł celu, postęp (0.0–1.0),
/// listę kroków do osiągnięcia celu oraz status ukończenia.
class GoalModel {
  final String id; // Unikalny identyfikator celu
  final String title; // Nazwa lub opis celu
  final double progress; // Postęp celu (0.0–1.0)
  final List<GoalStepModel> steps; // Lista kroków prowadzących do celu
  final bool completed; // Czy cel został ukończony

  GoalModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.steps,
    required this.completed,
  });

  /// Tworzy model na podstawie danych z JSON (np. z Firestore)
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      completed: json['completed'] ?? false,
      steps:
          (json['steps'] as List<dynamic>)
              .map((e) => GoalStepModel.fromJson(e))
              .toList(),
    );
  }

  /// Konwertuje model do formatu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'completed': completed,
      'steps': steps.map((e) => e.toJson()).toList(),
    };
  }

  /// Zwraca kopię modelu z możliwością nadpisania pól
  GoalModel copyWith({
    String? title,
    double? progress,
    List<GoalStepModel>? steps,
    bool? completed,
  }) {
    return GoalModel(
      id: id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      steps: steps ?? this.steps,
      completed: completed ?? this.completed,
    );
  }
}

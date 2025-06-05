import 'package:firebase_flutter_app/domain/models/task_model.dart';

/// Model reprezentujący dane jednego dnia.
///
/// Zawiera: datę, listę zadań [TaskModel], opcjonalną notatkę
/// oraz wartość produktywności (procent wykonania zadań).
class DayModel {
  final DateTime date; // Data (dzień)
  final List<TaskModel> tasks; // Lista zadań przypisanych do tego dnia
  final String? note; // Opcjonalna notatka tekstowa
  final double progress; // Procent wykonania zadań (0.0–1.0)

  DayModel({
    required this.date,
    required this.tasks,
    this.note,
    this.progress = 0.0,
  });

  /// Tworzy instancję modelu na podstawie mapy JSON
  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      date: DateTime.parse(json['date'] as String),
      tasks:
          (json['tasks'] as List<dynamic>)
              .map((task) => TaskModel.fromJson(task as Map<String, dynamic>))
              .toList(),
      note: json['note'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Konwertuje model do formatu JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'note': note,
      'progress': progress,
    };
  }

  /// Zwraca kopię modelu z możliwością zmiany pól
  DayModel copyWith({
    DateTime? date,
    List<TaskModel>? tasks,
    String? note,
    double? progress,
  }) {
    return DayModel(
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      note: note ?? this.note,
      progress: progress ?? this.progress,
    );
  }
}

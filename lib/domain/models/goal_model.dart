import 'package:firebase_flutter_app/domain/models/goal_steps_model.dart';

class GoalModel {
  final String id;
  final String title;
  final double progress;
  final List<GoalStepModel> steps;
  final bool completed;

  GoalModel({
    required this.id,
    required this.title,
    required this.progress,
    required this.steps,
    required this.completed,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'completed': completed,
      'steps': steps.map((e) => e.toJson()).toList(),
    };
  }

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

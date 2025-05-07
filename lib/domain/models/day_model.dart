// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_flutter_app/domain/models/task_model.dart';

class DayModel {
  final DateTime date;
  final List<TaskModel> tasks;
  final String? note;
  final double progress;

  DayModel({
    required this.date,
    required this.tasks,
    this.note,
    this.progress = 0.0,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'note': note,
      'progress': progress,
    };
  }

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

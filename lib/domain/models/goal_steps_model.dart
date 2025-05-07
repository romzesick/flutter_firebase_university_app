class GoalStepModel {
  final String id;
  final String text;
  final bool done;

  GoalStepModel({required this.id, required this.text, this.done = false});

  factory GoalStepModel.fromJson(Map<String, dynamic> json) {
    return GoalStepModel(
      id: json['id'],
      text: json['text'],
      done: json['done'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'done': done};
  }

  GoalStepModel copyWith({String? text, bool? done}) {
    return GoalStepModel(
      id: id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

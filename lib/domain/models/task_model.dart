// ignore_for_file: public_member_api_docs, sort_constructors_first
class TaskModel {
  final String id;
  final String text;
  final bool done;

  TaskModel({required this.id, required this.text, required this.done});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      text: json['text'] as String,
      done: json['done'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'done': done};
  }

  TaskModel copyWith({String? id, String? text, bool? done}) {
    return TaskModel(
      id: id ?? this.id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

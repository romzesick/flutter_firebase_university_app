/// Model pojedynczego zadania.
///
/// Reprezentuje jedno zadanie użytkownika z unikalnym identyfikatorem,
/// tekstem oraz statusem wykonania.
class TaskModel {
  final String id; // Unikalny identyfikator zadania
  final String text; // Treść zadania
  final bool done; // Czy zadanie zostało wykonane

  TaskModel({required this.id, required this.text, required this.done});

  /// Tworzy model z mapy JSON (np. z Firestore)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      text: json['text'] as String,
      done: json['done'] as bool,
    );
  }

  /// Konwertuje model do formatu JSON (np. do zapisu w bazie)
  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'done': done};
  }

  /// Zwraca nową kopię z opcjonalnymi zmianami
  TaskModel copyWith({String? id, String? text, bool? done}) {
    return TaskModel(
      id: id ?? this.id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

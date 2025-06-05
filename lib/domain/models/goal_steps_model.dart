/// Model pojedynczego kroku w ramach celu długoterminowego.
///
/// Zawiera identyfikator, treść kroku oraz informację, czy krok został ukończony.
class GoalStepModel {
  final String id; // Unikalny identyfikator kroku
  final String text; // Opis kroku
  final bool done; // Czy krok został wykonany

  GoalStepModel({required this.id, required this.text, this.done = false});

  /// Tworzy model na podstawie danych z JSON
  factory GoalStepModel.fromJson(Map<String, dynamic> json) {
    return GoalStepModel(
      id: json['id'],
      text: json['text'],
      done: json['done'] ?? false,
    );
  }

  /// Konwertuje model do formatu JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'done': done};
  }

  /// Zwraca kopię modelu z możliwością zmiany tekstu lub statusu wykonania
  GoalStepModel copyWith({String? text, bool? done}) {
    return GoalStepModel(
      id: id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

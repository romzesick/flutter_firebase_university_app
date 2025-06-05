/// Model reprezentujący rangę użytkownika.
///
/// Zawiera nazwę rangi (`name`) oraz minimalną liczbę punktów (`minPoints`),
/// które użytkownik musi osiągnąć, aby uzyskać tę rangę.
class RankModel {
  final String name; // Nazwa rangi (np. "Expert", "Beginner")
  final int
  minPoints; // Minimalna liczba punktów potrzebna do osiągnięcia rangi

  RankModel({required this.name, required this.minPoints});

  /// Tworzy instancję modelu na podstawie danych z JSON
  factory RankModel.fromJson(Map<String, dynamic> json) {
    return RankModel(
      name: json['name'] ?? 'Unknown',
      minPoints: json['minPoints'] ?? 0,
    );
  }

  /// Konwertuje model do mapy JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'minPoints': minPoints};
  }
}

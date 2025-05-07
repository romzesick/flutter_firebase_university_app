class RankModel {
  final String name;
  final int minPoints;

  RankModel({required this.name, required this.minPoints});

  factory RankModel.fromJson(Map<String, dynamic> json) {
    return RankModel(
      name: json['name'] ?? 'Unknown',
      minPoints: json['minPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'minPoints': minPoints};
  }
}

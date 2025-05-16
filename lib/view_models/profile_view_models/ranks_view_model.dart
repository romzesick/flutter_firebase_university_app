import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/rank_model.dart';
import 'package:firebase_flutter_app/services/rank_service.dart';

/// ViewModel odpowiedzialny za pobieranie i przechowywanie informacji o rangach.
///
/// Obsługuje:
/// - załadowanie wszystkich rang z bazy danych,
/// - określenie aktualnej rangi użytkownika,
/// - pobranie łącznej liczby punktów użytkownika.
///
/// Stan ładowania oraz ewentualne błędy dostępne są przez pola `isLoading` i `error`.

class RankViewModel extends ChangeNotifier {
  final RankService _rankService = RankService();

  int? _userPoints;
  RankModel? _userRank;
  List<RankModel> _allRanks = [];
  String? _error;
  bool _isLoading = false;

  int? get userPoints => _userPoints;
  RankModel? get userRank => _userRank;
  List<RankModel> get allRanks => _allRanks;
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// Ładowanie wszystkich danych: listy rang, rangi użytkownika i punktów.
  Future<void> loadRanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRanks = await _rankService.getAllRanks();
      _userRank = await _rankService.getUserRank();
      _userPoints = await _rankService.getUserTotalPoints();
    } catch (e) {
      _error = 'Failed to load ranks';
    }

    _isLoading = false;
    notifyListeners();
  }
}

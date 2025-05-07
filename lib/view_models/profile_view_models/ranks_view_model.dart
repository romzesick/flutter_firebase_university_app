import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/rank_model.dart';
import 'package:firebase_flutter_app/services/rank_service.dart';

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

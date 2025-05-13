import 'package:firebase_flutter_app/view_models/profile_view_models/ranks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/daily_reward_model.dart';
import 'package:firebase_flutter_app/services/daily_reward_service.dart';

class DailyRewardViewModel extends ChangeNotifier {
  final DailyRewardService _rewardService = DailyRewardService();
  final RankViewModel _rankViewModel;

  DailyRewardViewModel(this._rankViewModel);

  DailyRewardModel? _reward;
  String? _error;
  bool _isLoading = false;

  DailyRewardModel? get reward => _reward;
  String? get error => _error;
  bool get isLoading => _isLoading;

  int get currentStreak => _reward?.currentStreak ?? 1;
  int get totalPoints => _reward?.totalPoints ?? 0;

  bool get canClaim {
    if (_reward == null) return false;
    final now = DateTime.now();
    final last = _reward!.lastClaimedDate;
    return !_isSameDate(now, last);
  }

  Future<void> loadRewardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reward = await _rewardService.getRewardData();

      if (_reward == null) {
        _reward = DailyRewardModel(
          currentStreak: 1,
          lastClaimedDate: DateTime(2000),
          totalPoints: 0,
        );
      } else {
        _reward = await _rewardService.evaluateStreak(_reward!);
      }

      await _rewardService.updateReward(_reward!);
    } catch (e) {
      _error = 'Failed to load reward';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> claimReward() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _rewardService.claimDailyReward();
      await loadRewardData();

      /// Теперь мы можем обновить RankViewModel напрямую
      await _rankViewModel.loadRanks();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

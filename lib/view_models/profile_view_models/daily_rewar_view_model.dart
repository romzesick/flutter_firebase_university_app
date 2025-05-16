import 'package:firebase_flutter_app/view_models/profile_view_models/ranks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/daily_reward_model.dart';
import 'package:firebase_flutter_app/services/daily_reward_service.dart';

/// ViewModel odpowiedzialny za logikę nagrody dziennej.
/// Zarządza aktualnym stanem streaka, punktami i uprawnieniami do odbioru.
/// Obsługuje:
/// - pobieranie danych z Firestore,
/// - ocenę streaka i aktualizację danych,
/// - odbieranie nagrody i synchronizację z rangą.
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

  /// Zwraca aktualną długość streaka
  int get currentStreak => _reward?.currentStreak ?? 1;

  /// Zwraca łączną liczbę zdobytych punktów
  int get totalPoints => _reward?.totalPoints ?? 0;

  /// Czy użytkownik może dziś odebrać nagrodę
  bool get canClaim {
    if (_reward == null) return false;
    final now = DateTime.now();
    final last = _reward!.lastClaimedDate;
    return !_isSameDate(now, last);
  }

  /// Wczytuje dane nagrody dziennej z Firestore
  Future<void> loadRewardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reward = await _rewardService.getRewardData();

      // Jeśli pierwszy raz, inicjalizujemy dane
      if (_reward == null) {
        _reward = DailyRewardModel(
          currentStreak: 1,
          lastClaimedDate: DateTime(2000),
          totalPoints: 0,
        );
      } else {
        // Ocena, czy streak należy zresetować
        _reward = await _rewardService.evaluateStreak(_reward!);
      }

      await _rewardService.updateReward(_reward!);
    } catch (e) {
      _error = 'Failed to load reward';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Obsługuje odbiór nagrody dziennej i aktualizuje rangę
  Future<void> claimReward() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _rewardService.claimDailyReward();
      await loadRewardData();
      await _rankViewModel.loadRanks();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sprawdza, czy dwie daty to ten sam dzień
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

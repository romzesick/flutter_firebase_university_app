import 'package:firebase_flutter_app/view_models/profile_view_models/daily_rewar_view_model.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/ranks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Popup do systemu codziennych nagród (Daily Reward).
/// Zawiera:
/// - wyświetlanie listy 7-dniowego cyklu nagród,
/// - obsługę stanu dziennego streaku i punktów,
/// - przycisk odbioru nagrody danego dnia,
class DailyRewardPopup extends StatelessWidget {
  final RankViewModel rankViewModel;

  const DailyRewardPopup({super.key, required this.rankViewModel});

  static final List<int> rewards = [10, 20, 40, 60, 80, 110, 150];

  @override
  Widget build(BuildContext context) {
    // Używamy Provider do stworzenia i udostępnienia DailyRewardViewModel
    return ChangeNotifierProvider(
      create: (_) => DailyRewardViewModel(rankViewModel)..loadRewardData(),
      child: const _RewardContent(),
    );
  }
}

class _RewardContent extends StatelessWidget {
  const _RewardContent();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DailyRewardViewModel>();

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.6,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),

          // Ładowanie danych
          child:
              model.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Daily reward',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista dni z nagrodami
                      Expanded(
                        child: Consumer<DailyRewardViewModel>(
                          builder: (context, model, _) {
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                final day = index + 1;
                                final reward = DailyRewardPopup.rewards[index];
                                final currentStreak =
                                    model.reward?.currentStreak ?? 1;
                                final dayInCycle =
                                    ((currentStreak - 1) % 7) + 1;

                                final isClaimed = day < dayInCycle;
                                final isToday =
                                    day == dayInCycle && model.canClaim;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[850],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          // Etykieta dnia
                                          Expanded(
                                            child: Text(
                                              'Day $day',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),

                                          // Przycisk do odebrania lub status
                                          GestureDetector(
                                            onTap: () async {
                                              if (isToday && model.canClaim) {
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    );
                                                await model.claimReward();
                                                messenger.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Reward claimed!',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              width: 130,
                                              decoration: BoxDecoration(
                                                color:
                                                    isClaimed
                                                        ? Colors.white12
                                                        : isToday
                                                        ? Colors.green
                                                        : Colors.white10,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    isClaimed
                                                        ? 'Claimed $reward 🎯'
                                                        : isToday
                                                        ? 'Claim $reward 🎯'
                                                        : 'Locked $reward 🎯',
                                                    style: TextStyle(
                                                      color:
                                                          isClaimed || isToday
                                                              ? Colors.white
                                                              : Colors.white38,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Przycisk zamknięcia popupu
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

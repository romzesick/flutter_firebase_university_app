import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/ranks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ekran z listą wszystkich rang użytkownika
///
/// pokazuje rangi w kolejności od najniższych do najwyższych
/// podświetla rangi osiągnięte przez użytkownika
class ViewRangsWidget extends StatelessWidget {
  const ViewRangsWidget({super.key});

  /// tworzy widget z podłączonym [RankViewModel]
  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => RankViewModel()..loadRanks(),
      child: const ViewRangsWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankViewModel = context.watch<RankViewModel>();
    final allRanks = rankViewModel.allRanks;
    final userRank = rankViewModel.userRank;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Rangs'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:
              rankViewModel.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : ListView.builder(
                    itemCount: allRanks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final rank = allRanks[index];
                      final isReached =
                          userRank != null &&
                          rank.minPoints <= userRank.minPoints;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FadeSlideIn(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isReached ? Colors.blue : Colors.grey[900],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      rank.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${rank.minPoints} 🎯',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}

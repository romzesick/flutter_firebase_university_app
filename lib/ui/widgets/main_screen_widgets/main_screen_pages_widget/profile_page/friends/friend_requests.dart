import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_models/friends_ranking_view_model.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_models/friends_request_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Strona wyświetlająca listę otrzymanych zaproszeń do znajomych.
///
/// Umożliwia:
/// - akceptację zaproszenia (dodanie do znajomych),
/// - odrzucenie zaproszenia,
/// - aktualizację rankingu znajomych po zaakceptowaniu.
///
/// Dane są ładowane przez `FriendRequestsViewModel`, który
/// pobiera listę oczekujących zaproszeń z Firestore.
class FriendRequestsPage extends StatelessWidget {
  final FriendsRankingViewModel friendsRankingViewModel;

  const FriendRequestsPage({super.key, required this.friendsRankingViewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendRequestsViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Friend Requests'),
        ),
        body: Consumer<FriendRequestsViewModel>(
          builder: (context, viewModel, child) {
            /// Loader podczas pobierania danych
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            // Brak zaproszeń
            if (viewModel.friendRequests.isEmpty) {
              return const Center(
                child: Text(
                  'No friend requests',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            /// Lista zaproszeń
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: viewModel.friendRequests.length,
                itemBuilder: (context, index) {
                  final request = viewModel.friendRequests[index];
                  return _FriendRequestTile(
                    request: request,
                    friendsRankingViewModel: friendsRankingViewModel,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Kafelek zaproszenia od innego użytkownika.
/// Pokazuje adres e-mail i pozwala:
/// - zaakceptować zaproszenie,
/// - odrzucić zaproszenie.
///
/// Po zaakceptowaniu aktualizowany jest ranking znajomych.
class _FriendRequestTile extends StatelessWidget {
  final Map<String, dynamic> request;
  final FriendsRankingViewModel friendsRankingViewModel;

  const _FriendRequestTile({
    required this.request,
    required this.friendsRankingViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<FriendRequestsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FadeSlideIn(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  request['email'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              /// Akceptacja zaproszenia
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () async {
                  await viewModel.acceptRequest(request['id']);

                  // Odśwież ranking znajomych
                  await friendsRankingViewModel.loadFriendsRanking();
                },
              ),

              /// Odrzucenie zaproszenia
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () async {
                  await viewModel.declineRequest(request['id']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request declined')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

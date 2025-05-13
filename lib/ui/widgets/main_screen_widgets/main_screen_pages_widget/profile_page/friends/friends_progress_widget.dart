import 'package:firebase_flutter_app/ui/components/radial_progress_bar/progres_bar.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/friends/friend_requests.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/friends/search_add_friends.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_models/friends_ranking_view_model.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_models/friends_request_notifier_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsProgressWidget extends StatefulWidget {
  const FriendsProgressWidget({super.key});

  @override
  State<FriendsProgressWidget> createState() => _FriendsProgressWidgetState();
}

class _FriendsProgressWidgetState extends State<FriendsProgressWidget> {
  @override
  Widget build(BuildContext context) {
    final friendsRankingViewModel = context.read<FriendsRankingViewModel>();
    return Consumer<FriendRequestsNotifier>(
      builder: (context, notifier, child) {
        return Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Friends Rating:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FriendsListPage(
                                  friendsRankingViewModel:
                                      friendsRankingViewModel,
                                ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => FriendRequestsPage(
                                            friendsRankingViewModel:
                                                friendsRankingViewModel,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              if (notifier.requestCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${notifier.requestCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            'Add friend',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          Icon(Icons.add, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(child: _FriendsRankingList()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FriendsRankingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FriendsRankingViewModel>();

    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (viewModel.friendsRanking.isEmpty) {
      return const Center(
        child: Text(
          'You dont have firends yet',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.friendsRanking.length,
      itemBuilder: (context, index) {
        final friend = viewModel.friendsRanking[index];
        final isCurrentUser = friend['isCurrentUser'] as bool;
        final borderColor = isCurrentUser ? Colors.green : Colors.white30;
        final displayName =
            isCurrentUser ? '${friend['name']} (you)' : friend['name'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. $displayName',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            friend['email'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: RadialPercentWidget(
                        percent: friend['totalProductivity'],
                        fillColor: Colors.white30,
                        freeColor: Colors.white70,
                        lineWidth: 5,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

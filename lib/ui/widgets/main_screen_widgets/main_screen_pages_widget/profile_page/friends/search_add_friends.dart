import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_models/friends_ranking_view_model.dart';
import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_models/friends_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsListPage extends StatelessWidget {
  const FriendsListPage({super.key, required this.friendsRankingViewModel});

  final FriendsRankingViewModel friendsRankingViewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendsListViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Add Friends'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _SearchField(),
              SizedBox(height: 16),
              Expanded(
                child: _UsersList(
                  friendsRankingViewModel: friendsRankingViewModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<FriendsListViewModel>();
    return TextField(
      controller: viewModel.searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search by email',
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({required this.friendsRankingViewModel});

  final FriendsRankingViewModel friendsRankingViewModel;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FriendsListViewModel>();
    final users = viewModel.filteredUsers;

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserTile(
          user: user,
          friendsRankingViewModel: friendsRankingViewModel,
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final FriendsRankingViewModel friendsRankingViewModel;

  const _UserTile({required this.user, required this.friendsRankingViewModel});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<FriendsListViewModel>();
    final userId = user['id'];

    IconData icon;
    Color iconColor;
    VoidCallback? onPressed;

    if (viewModel.isFriend(userId)) {
      icon = Icons.check;
      iconColor = Colors.green;
      onPressed = null; // Уже друг
    } else if (viewModel.isPending(userId)) {
      icon = Icons.hourglass_empty;
      iconColor = Colors.orange;
      onPressed = () async {
        await viewModel.removeFriendRequest(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request cancelled')),
        );
      };
    } else {
      icon = Icons.person_add;
      iconColor = Colors.green;
      onPressed = () async {
        await viewModel.sendFriendRequest(userId);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend request sent')));
      };
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FadeSlideIn(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color:
                viewModel.isFriend(userId)
                    ? Colors.green[700]
                    : Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  user['email'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (viewModel.isFriend(userId))
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey[900]),
                  onPressed: () async {
                    await viewModel.removeFriend(userId);
                    await friendsRankingViewModel.loadFriendsRanking();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend removed')),
                    );
                  },
                ),
              IconButton(
                icon: Icon(icon, color: iconColor),
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

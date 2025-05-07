import 'package:firebase_flutter_app/view_models/profile_view_models/friends_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendSearchWidget extends StatelessWidget {
  const FriendSearchWidget({super.key});

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => FriendViewModel()..loadFriends(),
      child: const FriendSearchWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendViewModel = context.read<FriendViewModel>();
    final TextEditingController emailController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Friend",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter email",
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                await friendViewModel.sendRequest(email);
                emailController.clear();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
  }
}

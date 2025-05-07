import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/friends/get_user.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/friends/search_add_friends.dart';
import 'package:flutter/material.dart';

class FriendsProgressWidget extends StatefulWidget {
  const FriendsProgressWidget({super.key});

  @override
  State<FriendsProgressWidget> createState() => _FriendsProgressWidgetState();
}

class _FriendsProgressWidgetState extends State<FriendsProgressWidget> {
  List<String> docIds = [];
  Future<void> getDocIds() async {
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach((element) {
            docIds.add(element.reference.id);
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDocIds(),
      builder: (context, snapshot) {
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
                        'Friends:',
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
                            builder: (context) => FriendSearchWidget.create(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Add friend',
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(Icons.add, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: docIds.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white30,
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GetUserNameEmailWidglet(
                                        documentId: docIds[index],
                                      ),
                                    ],
                                  ),
                                ),
                                Text('🎯', style: TextStyle(fontSize: 30)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

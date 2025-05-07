import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserNameEmailWidglet extends StatelessWidget {
  final String documentId;
  const GetUserNameEmailWidglet({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['name'], style: TextStyle(color: Colors.white)),
              Text(data['email'], style: TextStyle(color: Colors.white)),
            ],
          );
        }
        return Text('loading...', style: TextStyle(color: Colors.white));
      },
    );
  }
}

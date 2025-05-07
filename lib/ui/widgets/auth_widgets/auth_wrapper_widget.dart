import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/login_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_page.dart';
import 'package:flutter/material.dart';

class AuthWrapperWidget extends StatelessWidget {
  const AuthWrapperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return MainPage();
        } else {
          return LoginPage.create();
        }
      },
    );
  }
}

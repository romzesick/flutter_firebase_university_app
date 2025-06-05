import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/login_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_page.dart';
import 'package:flutter/material.dart';

/// Widget odpowiedzialny za przekierowanie użytkownika
/// w zależności od statusu logowania.
///
/// - Jeśli użytkownik jest zalogowany (`FirebaseAuth.instance.currentUser != null`)
///   — wyświetlana jest strona główna ([MainPage]).
/// - Jeśli użytkownik nie jest zalogowany — pokazywana jest strona logowania ([LoginPage]).
///
/// Wykorzystuje [StreamBuilder], który nasłuchuje zmian statusu autoryzacji
/// za pomocą [FirebaseAuth.authStateChanges].
class AuthWrapperWidget extends StatelessWidget {
  const AuthWrapperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      /// Nasłuchuje zmian statusu zalogowania użytkownika.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        /// Pokazanie loadera, gdy status jeszcze się ładuje
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        /// Jeśli użytkownik jest zalogowany, pokaż główną stronę
        if (snapshot.hasData) {
          return MainPage();
        }
        /// Jeśli użytkownik nie jest zalogowany, pokaż stronę logowania
        else {
          return LoginPage.create();
        }
      },
    );
  }
}

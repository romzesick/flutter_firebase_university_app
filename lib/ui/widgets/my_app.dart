import 'package:firebase_flutter_app/ui/widgets/auth_widgets/auth_wrapper_widget.dart';
import 'package:flutter/material.dart';

/// Główny widget aplikacji.
///
/// Odpowiada za uruchomienie całego interfejsu użytkownika.
/// Korzysta z [MaterialApp], a punktem wejścia do nawigacji jest [AuthWrapperWidget].
///
/// AuthWrapper automatycznie decyduje, czy pokazać ekran logowania,
/// czy główny ekran aplikacji — w zależności od stanu autoryzacji użytkownika.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productivity App',
      debugShowCheckedModeBanner: false,
      home: AuthWrapperWidget(), // Przejście do logiki autoryzacji
    );
  }
}

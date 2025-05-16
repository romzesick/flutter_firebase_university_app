import 'package:firebase_flutter_app/ui/widgets/auth_widgets/auth_wrapper_widget.dart';
import 'package:flutter/material.dart';

/// Główna klasa aplikacji — punkt wejścia interfejsu użytkownika

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Widżet startowy, który sprawdza status autoryzacji użytkownika
      home: AuthWrapperWidget(),
    );
  }
}

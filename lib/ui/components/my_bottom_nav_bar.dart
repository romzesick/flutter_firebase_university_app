import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// Pasek nawigacyjny na dole ekranu z nowoczesnym wyglądem (GNav).
/// Pozwala użytkownikowi przełączać się między stronami:
/// - Zadania dnia
/// - Cele długoterminowe
/// - Profil
class MyBottomNavBar extends StatelessWidget {
  /// Funkcja wykonywana po kliknięciu zakładki.
  /// Przyjmuje indeks nowo wybranej zakładki.
  final void Function(int)? onTabChange;

  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GNav(
        color: Colors.white,
        activeColor: Colors.white,
        tabBackgroundColor: Colors.grey.shade900,
        padding: const EdgeInsets.all(16),
        gap: 8,
        onTabChange: (value) => onTabChange!(value),
        tabs: const [
          GButton(icon: Icons.task_alt_outlined, text: 'Daily Tasks'),
          GButton(icon: Icons.task, text: 'Long-term Goals'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

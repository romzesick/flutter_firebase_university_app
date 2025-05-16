import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

///
/// D O L N A   N A W I G A C J A
///
/// Pasek nawigacyjny na dole ekranu z nowoczesnym wyglądem (GNav).
/// Pozwala użytkownikowi przełączać się między stronami:
/// - Zadania dnia
/// - Cele długoterminowe
/// - Profil
///
class MyBottomNavBar extends StatelessWidget {
  /// Funkcja wywoływana przy zmianie zakładki (indeks nowej zakładki)
  final void Function(int)? onTabChange;

  const MyBottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GNav(
        // Kolor ikon nieaktywnych
        color: Colors.white,

        // Kolor ikon aktywnych
        activeColor: Colors.white,

        // Tło aktywnej zakładki
        tabBackgroundColor: Colors.grey.shade900,

        // Odstęp wewnątrz zakładki
        padding: const EdgeInsets.all(16),

        // Odstęp między ikoną a tekstem
        gap: 8,

        // Obsługa zmiany zakładki
        onTabChange: (value) => onTabChange!(value),

        // Lista przycisków w dolnej nawigacji
        tabs: const [
          GButton(icon: Icons.task_alt_outlined, text: 'Daily Tasks'),
          GButton(icon: Icons.task, text: 'Long-term Goals'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

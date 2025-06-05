import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/global_goals_page/goals_page.dart';
import 'package:flutter/material.dart';

import '../../components/my_bottom_nav_bar.dart';
import 'main_screen_pages_widget/profile_page/profile_page.dart';

/// Strona główna po zalogowaniu.
/// Zawiera dolny pasek nawigacyjny i trzy zakładki:
/// - zadania dnia,
/// - cele globalne,
/// - profil użytkownika.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Aktualnie wybrany indeks zakładki
  int _selectedIndex = 0;

  /// Zmienia aktualną zakładkę po kliknięciu w dolny pasek
  void navigateBottomBar(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Lista stron przypisanych do zakładek
  final List<Widget> _pages = [
    MainTasksPage.create(),
    GoalsPageWidget(),
    ProfilePage.create(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }
}

import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/global_goals_page/goals_page.dart';
import 'package:flutter/material.dart';

import '../../components/my_bottom_nav_bar.dart';
import 'main_screen_pages_widget/profile_page/profile_page.dart';

///
/// S T R O N A   G Ł Ó W N A
///
/// Zawiera dolny pasek nawigacyjny i trzy główne zakładki:
/// - Zadania dnia (MainTasksPage)
/// - Cele globalne (GoalsPage)
/// - Profil użytkownika (ProfilePage)
///
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// Aktualnie wybrany indeks w dolnym pasku nawigacji
  int _selectedIndex = 0;

  /// Metoda do zmiany zakładki po kliknięciu w dolny pasek
  void navigateBottomBar(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Lista stron odpowiadających zakładkom nawigacji
  final List<Widget> _pages = [
    MainTasksPage.create(), // Zadania dnia
    GoalsPageWidget(), // Cele
    ProfilePage.create(), // Profil
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

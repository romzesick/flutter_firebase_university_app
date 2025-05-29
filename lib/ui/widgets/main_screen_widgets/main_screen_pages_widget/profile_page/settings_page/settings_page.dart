import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/auth_wrapper_widget.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/settings_page/about_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Widżet ustawień aplikacji z opcją wylogowania, usunięcia konta i przejścia do strony "O aplikacji"
class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  // Wylogowanie użytkownika i przejście do ekranu logowania
  void _logUserOut() {
    FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapperWidget()),
        (route) => false,
      );
    }
  }

  // Usunięcie konta użytkownika i wylogowanie
  Future<void> _deleteAccountLogOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete(); // Usunięcie konta
      FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapperWidget()),
          (route) => false,
        );
      }
    }
  }

  // Flaga do przechowywania stanu powiadomień
  bool _notificationsEnabled = true;
  bool _darkModeOn = false;

  // Włączenie lub wyłączenie powiadomień push
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);

    if (value) {
      // Prośba o pozwolenie na powiadomienia
      final settings = await FirebaseMessaging.instance.requestPermission();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? '🔔 Уведомления включены' : '⚠️ Разрешение не получено',
          ),
          backgroundColor: granted ? Colors.green : Colors.orange,
        ),
      );
    } else {
      // Wyłączenie inicjalizacji powiadomień
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔕 Уведомления отключены'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'), // Tytuł AppBar
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingsItemsWidget(
              function: () {},
              widget: Switch(
                activeColor: Colors.grey,
                value: _darkModeOn,
                onChanged: (value) {},
              ),
              text: _darkModeOn == true ? 'Dark Mode' : 'Light Mode',
            ),
            // Przełącznik powiadomień
            SettingsItemsWidget(
              function: () {},
              widget: Switch(
                activeColor: Colors.grey,
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
              text: 'Notifications',
            ),
            // Przejście do strony "O aplikacji"
            SettingsItemsWidget(
              function: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
              widget: Icon(Icons.info, color: Colors.white),
              text: 'About App',
            ),
            // Przycisk wylogowania
            SettingsItemsWidget(
              function: _logUserOut,
              widget: Icon(Icons.logout, color: Colors.white),
              text: 'Log Out',
            ),
            // Przycisk usuwania konta
            SettingsItemsWidget(
              function: _deleteAccountLogOut,
              widget: Icon(Icons.delete, color: Colors.white),
              text: 'Delete Account',
            ),
          ],
        ),
      ),
    );
  }
}

// Widżet pojedynczego elementu ustawień (np. przełącznik, przycisk)
class SettingsItemsWidget extends StatelessWidget {
  final Function function; // Akcja po kliknięciu
  final Widget widget; // Ikona lub przełącznik
  final String text; // Opis

  const SettingsItemsWidget({
    super.key,
    required this.widget,
    required this.text,
    required this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GestureDetector(
        onTap: () => function(),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: text == 'Delete Account' ? Colors.red : Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(text, style: TextStyle(color: Colors.white)),
                ),
                widget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

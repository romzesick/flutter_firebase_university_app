import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/auth_wrapper_widget.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/profile_page/settings_page/about_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// strona ustawień aplikacji
///
/// umożliwia:
/// - przełączanie powiadomień push,
/// - wylogowanie się z konta,
/// - usunięcie konta,
/// - przejście do strony "O aplikacji"
class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  /// wylogowanie użytkownika
  void _logUserOut() {
    FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapperWidget()),
        (route) => false,
      );
    }
  }

  /// usunięcie konta i przekierowanie do logowania
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

  /// przełącznik powiadomień push
  bool _notificationsEnabled = true;

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
            granted
                ? '🔔 Notifications turn on'
                : '⚠️ Permition is not recieved',
          ),
          backgroundColor: granted ? Colors.green : Colors.orange,
        ),
      );
    } else {
      // Wyłączenie inicjalizacji powiadomień
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔕 Notifications turnd off'),
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
        title: Text('Settings'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// przełącznik powiadomień
            SettingsItemsWidget(
              function: () {},
              widget: Switch(
                activeColor: Colors.grey,
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
              text: 'Notifications',
            ),

            /// przejście do strony o aplikacji
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

            /// przycisk wylogowania
            SettingsItemsWidget(
              function: _logUserOut,
              widget: Icon(Icons.logout, color: Colors.white),
              text: 'Log Out',
            ),

            /// przycisk usunięcia konta
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

/// pojedynczy element ustawień (tekst + akcja)
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

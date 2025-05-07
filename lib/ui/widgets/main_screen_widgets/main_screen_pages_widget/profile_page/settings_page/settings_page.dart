import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter_app/ui/widgets/auth_widgets/auth_wrapper_widget.dart';
import 'package:flutter/material.dart';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  // method to log user out
  void _logUserOut() {
    FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapperWidget()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccountLogOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
      FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapperWidget()),
          (route) => false,
        );
      }
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
            SettingsItemsWidget(
              function: () {},
              widget: Switch(value: true, onChanged: (bool value) {}),
              text: 'Light Mode',
            ),
            SettingsItemsWidget(
              function: () {},
              widget: Icon(Icons.info, color: Colors.white),
              text: 'About App',
            ),
            SettingsItemsWidget(
              function: () {},
              widget: Icon(Icons.chevron_right_outlined, color: Colors.white),
              text: 'Privacy Policy',
            ),
            SettingsItemsWidget(
              function: () => Navigator.pop(context),
              widget: Icon(Icons.chevron_right_outlined, color: Colors.white),
              text: 'Terms and Conditions',
            ),
            SettingsItemsWidget(
              function: () {},
              widget: Icon(Icons.settings, color: Colors.white),
              text: 'Notifications',
            ),
            SettingsItemsWidget(
              function: _logUserOut,
              widget: Icon(Icons.logout, color: Colors.white),
              text: 'Log Out',
            ),
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

class SettingsItemsWidget extends StatelessWidget {
  final Function function;
  final Widget widget;
  final String text;
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

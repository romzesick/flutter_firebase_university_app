import 'package:flutter/material.dart';

/// Ekran informacyjny "O aplikacji"
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static Widget create() => const AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'About This App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'This app is designed to help you track and improve your daily productivity. '
              'You can set tasks, monitor progress, create long-term goals, and even compete with friends.\n\n'
              '🔥 Features:\n'
              '• Daily tasks & notes\n'
              '• Progress analytics (day/week/month/year)\n'
              '• Achievement system & ranks\n'
              '• Push notifications\n'
              '• Friend system & leaderboards\n\n'
              'Built with ❤️ using Flutter & Firebase.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20),
            Text('Version 1.0.0', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

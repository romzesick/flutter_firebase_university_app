import 'package:flutter/material.dart';

/// Nie potrzebuje tej strony, ale jak coś to skorzystam

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView.builder(
          itemCount: 10,
          itemBuilder:
              (context, index) => Container(
                height: 100,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[900],
                ),
              ),
        ),
      ),
    );
  }
}

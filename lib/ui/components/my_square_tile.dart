import 'package:flutter/material.dart';

/// Kwadratowy kafelek wykorzystywany do logowania przez Google lub Apple
class SquareTile extends StatelessWidget {
  /// Ścieżka do ikony (np. "images/google.png")
  final String imagePath;

  const SquareTile({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(imagePath, height: 40),
    );
  }
}

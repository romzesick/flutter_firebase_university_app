import 'package:flutter/material.dart';

///
/// P R Z Y C I S K   S P O Ł E C Z N O Ś C I O W Y
///
/// Kwadratowy kafelek wykorzystywany do logowania przez Google lub Apple
///
class SquareTile extends StatelessWidget {
  /// Ścieżka do ikony (np. "images/google.png")
  final String imagePath;

  const SquareTile({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(imagePath, height: 40),
    );
  }
}

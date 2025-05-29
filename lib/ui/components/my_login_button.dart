import 'package:flutter/material.dart';

///
/// P R Z Y C I S K
///
/// Uniwersalny przycisk używany w formularzach logowania i rejestracji.
///
class MyButton extends StatelessWidget {
  /// Tekst wyświetlany na przycisku (np. "Sign In" lub "Sign Up")
  final String signInUp;

  /// Funkcja wykonywana po kliknięciu przycisku
  final Function()? onTap;

  const MyButton({super.key, required this.onTap, required this.signInUp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            signInUp,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

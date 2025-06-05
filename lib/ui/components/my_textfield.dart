import 'package:flutter/material.dart';

/// Komponent pola tekstowego do wielokrotnego użytku.
///
/// Wyświetla pole z obramowaniem, podpowiedzią i opcjonalnym ukrywaniem tekstu (np. dla haseł).
/// Można przekazać własny [TextEditingController] oraz funkcję [onChanged].
///
/// Stylizacja dostosowana do ciemnego motywu (kolory, tło, obramowanie).
///
/// Używany w ekranach logowania, rejestracji i innych.
class MyTextField extends StatelessWidget {
  /// Kontroler tekstu (opcjonalnie, jeśli potrzebna bezpośrednia kontrola)
  final TextEditingController? controller;

  /// Funkcja wywoływana przy każdej zmianie tekstu
  final void Function(String)? onChanged;

  /// Tekst podpowiedzi (placeholder)
  final String hintText;

  /// Czy pole ma ukrywać tekst (np. dla haseł)
  final bool obscureText;

  const MyTextField({
    super.key,
    this.onChanged,
    this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        obscureText: obscureText,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          fillColor: Colors.grey[900],
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}

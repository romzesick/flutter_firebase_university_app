import 'package:flutter/material.dart';

/// P O L E   T E K S T O W E

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
          // Obramowanie nieaktywne
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),

          // Obramowanie aktywne (gdy pole jest zaznaczone)
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),

          // Tło pola
          fillColor: Colors.grey[900],
          filled: true,

          // Tekst podpowiedzi
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}

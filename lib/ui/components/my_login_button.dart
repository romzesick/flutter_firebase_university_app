import 'package:flutter/material.dart';

/*

B U T T O N

This is a custom built sign in button!

*/

class MyButton extends StatelessWidget {
  final String signInUp;
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
          color: Colors.grey[900],
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

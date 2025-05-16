import 'package:flutter/material.dart';

/// Prosty pasek postępu z animacją i etykietą.
///
/// Używany do wizualizacji postępu w czasie (np. dzienny, tygodniowy).
class TimeProgressBar extends StatelessWidget {
  final String label; // Etykieta opisana nad paskiem
  final double percent; // Wartość procentowa postępu (0.0–1.0)

  const TimeProgressBar({
    super.key,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0.0,
        end: percent.clamp(0.0, 1.0),
      ), // Ograniczamy do 0–1
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, animatedPercent, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tekst z etykietą i procentem
            Text(
              '$label: ${(animatedPercent * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 3),

            // Pasek postępu
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: animatedPercent,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:firebase_flutter_app/domain/models/goal_model.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/global_goals_page/add_steps_for_goals_page.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Ekran tworzenia nowego celu.
/// Użytkownik wpisuje nazwę celu, po czym zostaje przekierowany na stronę dodawania kroków.
class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage({super.key});

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Reagujemy na zmianę tekstu, by np. aktywować przycisk
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Obsługa naciśnięcia "Next"
  Future<void> _handleNext() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Describe your goal')));
      return;
    }

    setState(() => _isLoading = true);
    final model = context.read<GoalsViewModel>();
    final newGoalId = await model.addGoalAndReturnId(title);
    if (!mounted || newGoalId == null) return;

    GoalModel? createdGoal;

    // Czekamy aż nowy cel pojawi się w modelu (max 5s)
    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      try {
        createdGoal = model.goals.firstWhere((g) => g.id == newGoalId);
        break;
      } catch (_) {}
    }

    setState(() => _isLoading = false);

    if (createdGoal == null || !mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CreateGoalStepsPage(goalId: newGoalId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pasek postępu (1 z 2 kroków)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: LinearProgressIndicator(
                value: 0.5,
                color: Colors.green,
                backgroundColor: Colors.grey[900],
                minHeight: 4,
              ),
            ),

            // Podtytuł
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Set career aim',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            // Tytuł sekcji
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '1. Describe global aim',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Pole tekstowe do wpisania celu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Example, "Finish the app"',
                  hintStyle: TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Przyciski
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _controller.text.isEmpty
                              ? Colors.green.shade900
                              : Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            )
                            : const Text('Next'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size.fromHeight(50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

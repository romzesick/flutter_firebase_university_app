import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Strona wyświetlająca wszystkie osiągnięte cele użytkownika.
/// Obsługuje:
/// - ładowanie ukończonych celów (`completed = true`),
/// - wyświetlanie listy celów,
/// - usuwanie ukończonego celu,
/// - pokazanie komunikatu jeśli brak danych.
class GoalsAchievedWidget extends StatefulWidget {
  const GoalsAchievedWidget({super.key});

  @override
  State<GoalsAchievedWidget> createState() => _GoalsAchievedWidgetState();
}

class _GoalsAchievedWidgetState extends State<GoalsAchievedWidget> {
  @override
  void initState() {
    super.initState();

    // Ładujemy tylko ukończone cele (completed = true)
    Future.microtask(() {
      context.read<GoalsViewModel>().loadGoals(completed: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Górny pasek z tytułem
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Goals achieved'),
      ),

      // Główna zawartość strony
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _GoalsWidget(), // Osobny widżet do listy celów
        ),
      ),
    );
  }
}

class _GoalsWidget extends StatelessWidget {
  const _GoalsWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GoalsViewModel>();

    // Filtrowanie — pokazujemy tylko zakończone cele
    final achievedGoals = model.goals.where((g) => g.completed).toList();

    // Pokazujemy loader jeśli trwa ładowanie
    if (model.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Komunikat jeśli brak zakończonych celów
    if (achievedGoals.isEmpty) {
      return const Center(
        child: Text(
          'No achieved goals yet!',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Lista zakończonych celów
    return ListView.builder(
      itemCount: achievedGoals.length,
      itemBuilder: (context, index) {
        final goal = achievedGoals[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: FadeSlideIn(
            // Efekt wejścia elementu
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Tekst celu
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    // Ikona usuwania celu
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await model.deleteGoal(goal.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Goal "${goal.title}" deleted'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

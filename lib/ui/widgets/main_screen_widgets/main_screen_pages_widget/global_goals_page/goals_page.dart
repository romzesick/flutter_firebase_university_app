import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_flutter_app/domain/models/goal_steps_model.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/global_goals_page/add_goal_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/global_goals_page/edit_goal_page.dart';
import 'package:firebase_flutter_app/ui/components/radial_progress_bar/progres_bar.dart';

/// Strona prezentująca długoterminowe cele.
/// Pozwala dodawać nowe cele, oznaczać kroki jako wykonane oraz przechodzić do edycji.
/// Widok zarządzany przez [GoalsViewModel].
class GoalsPageWidget extends StatefulWidget {
  const GoalsPageWidget({super.key});

  @override
  State<GoalsPageWidget> createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget> {
  String? selectedGoalId;

  @override
  void initState() {
    super.initState();

    /// Ładowanie celów przy starcie
    Future.microtask(() {
      context.read<GoalsViewModel>().loadGoals();
    });
  }

  /// Zmiana zaznaczenia celu
  void _toggleGoalSelection(String goalId) {
    setState(() {
      selectedGoalId = selectedGoalId == goalId ? null : goalId;
    });
  }

  /// Nawigacja do ekranu edycji celu
  void _navigateToDetails() async {
    if (selectedGoalId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditGoalPage(goalId: selectedGoalId!),
        ),
      );

      // Po powrocie odznaczamy cel
      setState(() {
        selectedGoalId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GoalsViewModel>();
    final visibleGoals = model.goals.where((g) => !g.completed).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child:
              model.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : visibleGoals.isEmpty
                  ? _buildEmptyContent()
                  : ListView.builder(
                    key: ValueKey(visibleGoals.length),
                    itemCount: visibleGoals.length,
                    itemBuilder: (context, index) {
                      final goal = visibleGoals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: GestureDetector(
                          onTap: () => _toggleGoalSelection(goal.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    selectedGoalId == goal.id
                                        ? Colors.green
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      _GoalProgressWidget(
                                        percent: goal.progress,
                                      ),
                                      const SizedBox(width: 10),
                                      _GoalLabelWidget(title: goal.title),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _StepsToAchieveGoal(
                                  goalId: goal.id,
                                  steps: goal.steps,
                                  onToggle: (stepId) async {
                                    await model.toggleStepDone(goal.id, stepId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),

      /// FloatingActionButton umożliwiający dodanie nowego celu lub edycję zaznaczonego
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FloatingActionButton(
          heroTag: 'fab_goals_main_${DateTime.now().microsecondsSinceEpoch}',
          backgroundColor:
              selectedGoalId != null ? Colors.white30 : Colors.green,
          onPressed:
              selectedGoalId != null
                  ? _navigateToDetails
                  : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateGoalPage()),
                  ),
          child: Icon(
            selectedGoalId != null ? Icons.edit : Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Widok pustej listy celów
  Widget _buildEmptyContent() {
    return Center(
      child: FadeSlideIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 90),
            Lottie.asset('assets/darts.json', width: 300, height: 300),
            const SizedBox(height: 10),
            const Text(
              'Oh, no goals, bro. Add right now!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wskaźnik postępu celu
class _GoalProgressWidget extends StatelessWidget {
  final double percent;
  const _GoalProgressWidget({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 65,
      child: RadialPercentWidget(
        percent: percent,
        fillColor: Colors.white30,
        freeColor: Colors.white70,
        lineWidth: 7,
        child: Text(
          '${(percent * 100).toInt()}%',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Tytuł celu
class _GoalLabelWidget extends StatelessWidget {
  final String title;
  const _GoalLabelWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Lista kroków przypisana do danego celu
class _StepsToAchieveGoal extends StatelessWidget {
  final String goalId;
  final List<GoalStepModel> steps;
  final void Function(String stepId) onToggle;

  const _StepsToAchieveGoal({
    required this.goalId,
    required this.steps,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        children:
            steps.map((step) {
              return GestureDetector(
                onTap: () => onToggle(step.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: step.done ? Colors.green : Colors.white30,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        step.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

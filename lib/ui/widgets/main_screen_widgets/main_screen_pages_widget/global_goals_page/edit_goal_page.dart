import 'package:firebase_flutter_app/domain/models/goal_model.dart';
import 'package:firebase_flutter_app/domain/models/goal_steps_model.dart';
import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditGoalPage extends StatefulWidget {
  final String goalId;
  const EditGoalPage({super.key, required this.goalId});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  String? _editingStepId;

  @override
  void dispose() {
    _titleController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _handleStepSubmit(GoalsViewModel model, GoalModel goal) {
    final text = _stepController.text.trim();
    if (text.isEmpty) return;

    if (_editingStepId == null) {
      model.addStep(goal.id, text);
    } else {
      final updatedStep = goal.steps
          .firstWhere((s) => s.id == _editingStepId!)
          .copyWith(text: text);
      model.updateStep(goal.id, updatedStep);
    }

    setState(() {
      _stepController.clear();
      _editingStepId = null;
    });
  }

  void _editStep(GoalStepModel step) {
    setState(() {
      _editingStepId = step.id;
      _stepController.text = step.text;
    });
  }

  void _deleteGoal(GoalsViewModel model, GoalModel goal) async {
    await model.deleteGoal(goal.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GoalsViewModel>();
    final goal = model.goals.firstWhere(
      (g) => g.id == widget.goalId,
      orElse:
          () => GoalModel(
            id: '',
            title: '',
            progress: 0.0,
            steps: [],
            completed: false,
          ),
    );

    if (goal.id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const Scaffold();
    }

    _titleController.text = goal.title;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Edit Goal', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Edit goal title...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final newTitle = _titleController.text.trim();
                      if (newTitle.isNotEmpty && newTitle != goal.title) {
                        final updatedGoal = goal.copyWith(title: newTitle);
                        model.updateGoal(updatedGoal);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stepController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add or edit step...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _handleStepSubmit(model, goal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_editingStepId == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: goal.steps.length,
                itemBuilder: (_, index) {
                  final step = goal.steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.text,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            onPressed: () => _editStep(step),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => model.deleteStep(goal.id, step.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed:
                        goal.steps.isEmpty
                            ? () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add at least one step'),
                              ),
                            )
                            : () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          goal.steps.isEmpty
                              ? Colors.green.shade900
                              : Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _deleteGoal(model, goal),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Delete Goal'),
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

import 'package:firebase_flutter_app/view_models/goals_view_models/goals_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGoalStepsPage extends StatefulWidget {
  final String goalId;
  const CreateGoalStepsPage({super.key, required this.goalId});

  @override
  State<CreateGoalStepsPage> createState() => _CreateGoalStepsPageState();
}

class _CreateGoalStepsPageState extends State<CreateGoalStepsPage> {
  final TextEditingController _controller = TextEditingController();

  String? _editingStepId;

  void _addOrUpdateStep() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final model = context.read<GoalsViewModel>();

    if (_editingStepId == null) {
      // Добавление нового шага
      model.addStep(widget.goalId, text);
    } else {
      // Обновление существующего шага
      final goal = model.goals.firstWhere((g) => g.id == widget.goalId);
      final step = goal.steps.firstWhere((s) => s.id == _editingStepId);
      final updatedStep = step.copyWith(text: text);
      model.updateStep(widget.goalId, updatedStep);
    }

    // Очистка состояния ввода и режима редактирования
    setState(() {
      _controller.clear();
      _editingStepId = null;
    });
  }

  void _editStep(String stepId, String currentText) {
    setState(() {
      _controller.text = currentText;
      _editingStepId = stepId;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GoalsViewModel>();
    final goal = model.goals.firstWhere(
      (g) => g.id == widget.goalId,
      orElse: () => throw Exception('Goal not found'),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Прогресс-бар
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: LinearProgressIndicator(
                  value: 1,
                  color: Colors.green,
                  backgroundColor: Colors.white12,
                  minHeight: 4,
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Set steps',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '1. What steps are needed to achieve this goal?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Поле ввода и кнопка Add/Save
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Example, "Fix bugs with adding steps"',
                          hintStyle: const TextStyle(color: Colors.white60),
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
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addOrUpdateStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _editingStepId == null
                                ? Colors.green
                                : Colors.green.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_editingStepId == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Список шагов
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: goal.steps.length,
                  itemBuilder: (context, index) {
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                step.text,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white70,
                                  ),
                                  onPressed:
                                      () => _editStep(step.id, step.text),
                                  tooltip: 'Edit step',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed:
                                      () => model.deleteStep(
                                        widget.goalId,
                                        step.id,
                                      ),
                                  tooltip: 'Delete step',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Кнопки Create и Back
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          goal.steps.isEmpty
                              ? () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Add at least one step'),
                                    ),
                                  )
                              : () => Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_flutter_app/domain/models/task_model.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/add_tasks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? existingTask; // <-- редактируемая задача

  const AddTaskPage({super.key, this.existingTask});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller; // <-- контроллер теперь тут

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // <-- инициализируем один раз

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<AddTaskViewModel>();
      model.init(widget.existingTask);

      // Устанавливаем текст в контроллере
      _controller.text = model.text;

      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AddTaskViewModel>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.existingTask == null ? 'Add Task' : 'Edit Task',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: model.changeText,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter your task...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed:
                        model.isLoading
                            ? null
                            : () {
                              FocusScope.of(context).unfocus();
                              model.saveTask(context);
                            },
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.existingTask == null
                          ? 'Save Task'
                          : 'Save Changes',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  if (model.error != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      model.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (model.isLoading)
          const Opacity(
            opacity: 0.6,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (model.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // <-- не забываем очищать
    _focusNode.dispose();
    super.dispose();
  }
}

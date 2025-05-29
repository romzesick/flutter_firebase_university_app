import 'package:firebase_flutter_app/domain/models/task_model.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/add_tasks_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Strona dodawania lub edytowania zadania.
/// Obsługuje:
/// - wstępne ustawienie tekstu,
/// - zapis zadania,
/// - walidację i blokadę przycisku, gdy pole puste.
class AddTaskPage extends StatefulWidget {
  final TaskModel? existingTask; // <-- jeśli nie null, to edycja

  const AddTaskPage({super.key, this.existingTask});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller; // <-- kontroler pola tekstowego

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // <-- inicjalizacja kontrolera

    // Po zbudowaniu widoku
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<AddTaskViewModel>();
      model.init(widget.existingTask);

      // Ustawiamy tekst w polu jeśli edytujemy
      _controller.text = model.text;

      // Automatyczne ustawienie kursora w polu
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
                  // Pole tekstowe do wpisania treści zadania
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: model.changeText,
                    cursorColor: Colors.white,
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

                  // Przycisk zapisu zadania
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
                  ),

                  // Wyświetlenie błędu (jeśli istnieje)
                  if (model.error != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      model.error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Nakładka ładowania (ciemne tło + spinner)
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
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

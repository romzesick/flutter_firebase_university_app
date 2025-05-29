import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/note_view_model.dart';

/// Strona dodawania lub edycji notatki do konkretnego dnia.
/// Obsługuje automatyczne zapisywanie z opóźnieniem (debounce).
class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  /// Fabryczna metoda do przekazania daty i utworzenia widoku
  static Widget create(DateTime date) {
    return ChangeNotifierProvider(
      create: (_) => NoteViewModel(date)..loadNote(),
      child: const AddNotePage(),
    );
  }

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // Słuchamy zmian tekstu w polu
    _controller.addListener(_onNoteChanged);

    // Pokazujemy klawiaturę z opóźnieniem po załadowaniu strony
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    });
  }

  /// Obsługa debounced zapisu notatki — zapis po 500ms bez pisania
  void _onNoteChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final text = _controller.text;
      context.read<NoteViewModel>().updateNote(text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final model = context.watch<NoteViewModel>();

    // Inicjalne wypełnienie pola jeśli notatka istnieje
    if (_controller.text.isEmpty && model.note.isNotEmpty) {
      _controller.text = model.note;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NoteViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Your Note', style: TextStyle(color: Colors.white)),
      ),

      // Główna zawartość: pole tekstowe lub spinner jeśli ładowanie
      body:
          model.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  key: const ValueKey('note_field'),
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Write your note...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 15,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

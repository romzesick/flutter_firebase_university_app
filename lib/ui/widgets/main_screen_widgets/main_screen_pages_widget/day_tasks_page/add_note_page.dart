import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/note_view_model.dart';

/// Strona dodawania lub edycji notatki do konkretnego dnia.
/// Korzysta z [NoteViewModel] do zarządzania logiką i danymi.
class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  /// Fabryczna metoda do przekazania daty i utworzenia widoku z ViewModel
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

    /// nasłuchiwanie zmian w polu tekstowym
    _controller.addListener(_onNoteChanged);

    /// automatyczne skupienie kursora po otwarciu strony
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    });
  }

  /// obsługuje zapis z opóźnieniem (500ms od ostatniej zmiany)
  void _onNoteChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final text = _controller.text;
      context.read<NoteViewModel>().updateNote(text);
    });
  }

  /// wypełnia pole notatki istniejącym tekstem (po załadowaniu modelu)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final model = context.watch<NoteViewModel>();
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

      /// główna zawartość — pole tekstowe lub spinner
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
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
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

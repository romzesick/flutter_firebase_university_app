import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/note_view_model.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

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

    _controller.addListener(_onNoteChanged);

    // Показываем клавиатуру немного позже, когда страница отрисуется
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

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
                    decoration: InputDecoration(
                      hintText: 'Write your note...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

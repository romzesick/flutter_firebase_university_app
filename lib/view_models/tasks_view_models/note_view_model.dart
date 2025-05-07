import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';

class NoteViewModel extends ChangeNotifier {
  final DayService _dayService = DayService();

  DateTime _date;
  String _note = '';
  bool _isLoading = false;
  String? _error;

  NoteViewModel(this._date);

  String get note => _note;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNote() async {
    _isLoading = true;
    notifyListeners();
    try {
      final day = await _dayService.fetchDay(_date);
      _note = day?.note ?? '';
    } catch (e) {
      _error = 'Failed to load note: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateNote(String newNote) async {
    _note = newNote;
    notifyListeners();
    try {
      await _dayService.updateNoteForDay(_date, newNote);
    } catch (e) {
      _error = 'Failed to save note: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

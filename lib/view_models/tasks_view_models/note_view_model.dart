import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';

/// ViewModel odpowiedzialny za obsługę notatek użytkownika.
/// Ładuje i zapisuje notatki powiązane z konkretną datą.
class NoteViewModel extends ChangeNotifier {
  final DayService _dayService = DayService();

  DateTime _date;
  String _note = '';
  bool _isLoading = false;
  String? _error;

  /// Inicjalizacja z konkretną datą
  NoteViewModel(this._date);

  // Gettery do wykorzystania w UI
  String get note => _note;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Ładowanie notatki z bazy (dla danego dnia)
  Future<void> loadNote() async {
    _isLoading = true;
    notifyListeners();
    try {
      final day = await _dayService.fetchDay(_date);
      _note = day?.note ?? ''; // jeśli brak notatki — zwracamy pusty ciąg
    } catch (e) {
      _error = 'Failed to load note: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Aktualizacja notatki — natychmiast w UI, potem zapis do bazy
  Future<void> updateNote(String newNote) async {
    _note = newNote;
    notifyListeners();
    try {
      await _dayService.updateNoteForDay(_date, newNote);
    } catch (e) {
      _error = 'Failed to save note: $e';
      notifyListeners(); // powiadamiamy o błędzie
    }
  }

  /// Czyszczenie błędu
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

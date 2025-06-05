import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';

/// ViewModel odpowiedzialny za obsługę notatek użytkownika.
/// Ładuje i zapisuje notatki powiązane z konkretną datą.
/// Wykorzystuje [DayService] do komunikacji z bazą danych.
class NoteViewModel extends ChangeNotifier {
  final DayService _dayService = DayService();

  DateTime _date;
  String _note = '';
  bool _isLoading = false;
  String? _error;

  /// Inicjalizacja ViewModelu z konkretną datą
  NoteViewModel(this._date);

  /// aktualna treść notatki
  String get note => _note;

  /// czy trwa ładowanie notatki
  bool get isLoading => _isLoading;

  /// komunikat błędu (jeśli wystąpił)
  String? get error => _error;

  /// Ładowanie notatki z Firestore na podstawie daty
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

  /// Zmienia notatkę w UI i zapisuje ją w Firestore
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

  /// Usuwa aktualny błąd i odświeża UI
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:firebase_flutter_app/services/tasks_servise.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_app/domain/models/day_model.dart';
import 'package:table_calendar/table_calendar.dart';

class AllNotesViewModel extends ChangeNotifier {
  final DayService _dayService = DayService();

  List<DayModel> _daysWithNotes = [];
  List<DayModel> _filteredNotes = [];
  List<DayModel> get filteredNotes => _filteredNotes;

  String _selectedMonth = 'All';
  String get selectedMonth => _selectedMonth;

  bool isLoading = false;

  Future<void> loadDaysWithNotes() async {
    isLoading = true;
    notifyListeners();

    final allDays = await _dayService.fetchAllUserDays();

    _daysWithNotes =
        allDays.where((day) => (day.note ?? '').trim().isNotEmpty).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    _filteredNotes = List.from(_daysWithNotes);
    isLoading = false;
    notifyListeners();
  }

  void filterByMonth(String month) {
    _selectedMonth = month;

    if (month == 'All') {
      _filteredNotes = List.from(_daysWithNotes);
    } else {
      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final monthNumber = int.parse(parts[1]);

      _filteredNotes =
          _daysWithNotes
              .where(
                (day) => day.date.year == year && day.date.month == monthNumber,
              )
              .toList();
    }

    notifyListeners();
  }

  /// Получаем список месяцев с заметками
  List<String> get availableMonths {
    final unique =
        _daysWithNotes
            .map(
              (d) =>
                  '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}',
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    return ['All', ...unique];
  }

  Future<void> deleteNote(DateTime date) async {
    // Удаляем заметку в Firestore
    await _dayService.updateNoteForDay(date, '');

    // Удаляем день из списка заметок
    _daysWithNotes.removeWhere((day) => isSameDay(day.date, date));

    // Повторно применяем фильтрацию
    filterByMonth(_selectedMonth);
  }
}

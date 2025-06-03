import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/day_tasks_page.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/notes_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/add_note_page.dart';

class NotesPageWidget extends StatelessWidget {
  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => AllNotesViewModel()..loadDaysWithNotes(),
      child: const NotesPageWidget(),
    );
  }

  const NotesPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AllNotesViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('All Notes', style: TextStyle(color: Colors.white)),
      ),
      body:
          model.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Column(
                children: [
                  _buildMonthDropdown(model),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: model.filteredNotes.length,
                      itemBuilder: (context, index) {
                        final day = model.filteredNotes[index];
                        final formattedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(day.date);
                        final preview = (day.note ?? '').trim();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FadeSlideIn(
                            child: Slidable(
                              key: ValueKey(day.date.toIso8601String()),

                              endActionPane: ActionPane(
                                dismissible: DismissiblePane(
                                  onDismissed: () async {
                                    await model.deleteNote(day.date);
                                  },
                                ),
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) async {
                                      await model.deleteNote(day.date);
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white30,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    formattedDate,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    preview,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => AddNotePage.create(day.date),
                                      ),
                                    ).then((_) async {
                                      await model.loadDaysWithNotes();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

Widget _buildMonthDropdown(AllNotesViewModel model) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: DropdownButton<String>(
      value: model.selectedMonth,
      dropdownColor: Colors.grey[900],
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      isExpanded: true,
      items:
          model.availableMonths.map((month) {
            return DropdownMenuItem<String>(
              value: month,
              child: Text(
                month == 'All'
                    ? 'All Notes'
                    : '${DateTime.parse('$month-01').month.toString().padLeft(2, '0')}.${month.split('-')[0]}',
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) model.filterByMonth(value);
      },
    ),
  );
}

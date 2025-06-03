import 'package:firebase_flutter_app/domain/models/task_model.dart';
import 'package:firebase_flutter_app/ui/components/radial_progress_bar/progres_bar.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/add_note_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/add_task_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/notes_page.dart';
import 'package:firebase_flutter_app/ui/widgets/main_screen_widgets/main_screen_pages_widget/day_tasks_page/statistics_page/statistics_page.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/add_tasks_view_model.dart';
import 'package:firebase_flutter_app/view_models/tasks_view_models/task_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

///
/// S T R O N A   Z A D A Ń   D Z I E N N Y C H
///
/// Ekran wyświetlający zadania na dany dzień, postęp dnia i ogólną produktywność.
/// Pozwala dodawać notatki, zadania, edytować je, usuwać oraz przesuwać na jutro.
///

class MainTasksPage extends StatelessWidget {
  const MainTasksPage({super.key});

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => DayTasksViewModel()..loadDay(DateTime.now()),
      child: const _MainTasksPageContent(),
    );
  }

  @override
  Widget build(BuildContext context) => create();
}

class _MainTasksPageContent extends StatefulWidget {
  const _MainTasksPageContent();

  @override
  State<_MainTasksPageContent> createState() => _MainTasksPageContentState();
}

/// Główna zawartość strony – zarządza widokiem, kalendarzem i zmianą dat
class _MainTasksPageContentState extends State<_MainTasksPageContent> {
  final ScrollController _dateScrollController = ScrollController();
  bool _showFullCalendar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(context.read<DayTasksViewModel>().selectedDate);
    });
  }

  /// Przewija poziomowy kalendarz do zaznaczonej daty
  void _scrollToSelectedDate(DateTime selectedDay) {
    final int index = selectedDay.difference(DateTime.now()).inDays + 15;
    const double itemWidth = 80.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetScrollOffset =
        index * itemWidth - (screenWidth / 2 - itemWidth / 2);

    _dateScrollController.animateTo(
      targetScrollOffset.clamp(
        0,
        _dateScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DayTasksViewModel>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DateWidget(),

                _ProgressWidget(),

                _TasksWidget(),

                const SizedBox(height: 100),
              ],
            ),
            _CalendarSelector(
              scrollController: _dateScrollController,
              showFullCalendar: _showFullCalendar,
              onToggleCalendar:
                  (show) => setState(() => _showFullCalendar = show),
              onDaySelected: (day) {
                model.changeSelectedDate(day);
                _scrollToSelectedDate(day);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Nagłówek z datą i przyciskiem statystyk
class _DateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<DayTasksViewModel>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat(
                'EEEE, MMMM d',
              ).format(model.selectedDate).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesPageWidget.create(),
                ),
              );
            },
            icon: Icon(Icons.note_rounded, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductivityStatsPage.create(),
                ),
              );
            },
            icon: Icon(Icons.bar_chart, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Sekcja z postępem dnia, średnią produktywnością i przyciskami
class _ProgressWidget extends StatelessWidget {
  const _ProgressWidget();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _DayProgressWidget(),
                  const SizedBox(width: 10),
                  _AverageProgressWidget(),
                ],
              ),

              Container(height: 80, width: 1, color: Colors.white30),

              Row(
                children: [
                  _AddNoteButtonWidget(),
                  const SizedBox(width: 10),
                  _AddTaskButtonWidget(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Postęp konkretnego dnia
class _DayProgressWidget extends StatelessWidget {
  const _DayProgressWidget();

  @override
  Widget build(BuildContext context) {
    final progress = context.select(
      (DayTasksViewModel m) => m.currentDay?.progress ?? 0.0,
    );
    return RadialPercentWidget(
      percent: progress,
      fillColor: Colors.white30,
      freeColor: Colors.white70,
      lineWidth: 10,
      child: Text(
        '${(progress * 100).toInt()}%',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Średnia produktywność użytkownika
class _AverageProgressWidget extends StatelessWidget {
  const _AverageProgressWidget();

  @override
  Widget build(BuildContext context) {
    final averageProgress = context.select(
      (DayTasksViewModel m) => m.totalProductivity ?? 0.0,
    );
    return RadialPercentWidget(
      percent: averageProgress,
      fillColor: Colors.white30,
      freeColor: Colors.white70,
      lineWidth: 10,
      child: Text(
        '${(averageProgress * 100).toInt()}%',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Przycisk dodawania notatki do dnia
class _AddNoteButtonWidget extends StatelessWidget {
  const _AddNoteButtonWidget();

  @override
  Widget build(BuildContext context) {
    final selectedDate = context.read<DayTasksViewModel>().selectedDate;
    final model = context.watch<DayTasksViewModel>();
    final note = model.currentDay?.note;

    final hasNote = note != null && note.trim().isNotEmpty;

    return ElevatedButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddNotePage.create(selectedDate)),
        );

        /// После возврата обновляем состояние
        await context.read<DayTasksViewModel>().loadDay(selectedDate);
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: hasNote ? Colors.green : Colors.white30,
      ),
      child: const Icon(Icons.note_add, color: Colors.white),
    );
  }
}

/// Przycisk dodawania zadania do dnia
class _AddTaskButtonWidget extends StatelessWidget {
  const _AddTaskButtonWidget();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            final model = context.read<DayTasksViewModel>();

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(value: model),
                        ChangeNotifierProvider(
                          create: (_) => AddTaskViewModel(),
                        ),
                      ],
                      child: AddTaskPage(),
                    ),
              ),
            );

            if (result != null && result is String) {
              model.addTask(result);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            backgroundColor: Colors.white30,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }
}

/// Lista zadań dnia – edytowalne, przesuwalne i animowane
class _TasksWidget extends StatelessWidget {
  const _TasksWidget();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DayTasksViewModel>();
    final tasks = context.select<DayTasksViewModel, List<TaskModel>>(
      (vm) => vm.tasks,
    );
    context.watch<DayTasksViewModel>().selectedDate;

    if (model.isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (tasks.isEmpty) {
      return Expanded(
        child: SingleChildScrollView(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.6, // для вертикального центрирования
            child: Center(
              child: FadeSlideIn(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ohh no',
                      style: TextStyle(color: Colors.white70, fontSize: 30),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'images/monkey.JPG',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No tasks for this day. Add right now',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return FadeSlideIn(
                child: Slidable(
                  key: ValueKey(task.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => model.deleteTask(task.id),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (_) async {
                          final dayModel = context.read<DayTasksViewModel>();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider.value(
                                        value: dayModel,
                                      ),
                                      ChangeNotifierProvider(
                                        create: (_) => AddTaskViewModel(),
                                      ),
                                    ],
                                    child: AddTaskPage(existingTask: task),
                                  ),
                            ),
                          );
                        },
                        backgroundColor: Colors.white30,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    dismissible: DismissiblePane(
                      onDismissed: () async {
                        await model.moveTaskToTomorrow(task.id);
                      },
                    ),
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          await model.moveTaskToTomorrow(task.id);
                        },
                        backgroundColor: Colors.white70,
                        foregroundColor: Colors.grey[900],
                        icon: Icons.calendar_today,
                        label: 'Tomorrow',
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: CheckboxListTile(
                      value: task.done,
                      onChanged: (_) => model.toggleTaskDone(task),
                      title: Text(
                        task.text,
                        style: TextStyle(
                          color: Colors.white,
                          decoration:
                              task.done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                          decorationColor: Colors.white,
                          decorationThickness: 2,
                        ),
                      ),
                      checkboxShape: const CircleBorder(),
                      activeColor: Colors.green,
                    ),
                  ),
                ),
              );
            },
          ),
          if (model.showCompletionGif)
            Positioned.fill(
              child: Center(
                child: Lottie.asset('assets/win.json', width: 300, height: 300),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animowane pojawianie się widżetów
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeSlideIn({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 30),
            child: child,
          ),
        );
      },
    );
  }
}

/// Dolny selektor dat:
/// - pozwala przełączać się między datami
/// - przeciągnięcie w górę pokazuje pełny kalendarz (TableCalendar)
class _CalendarSelector extends StatelessWidget {
  final ScrollController scrollController;
  final bool showFullCalendar;
  final void Function(bool) onToggleCalendar;
  final void Function(DateTime) onDaySelected;

  const _CalendarSelector({
    required this.scrollController,
    required this.showFullCalendar,
    required this.onToggleCalendar,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDay = context.watch<DayTasksViewModel>().selectedDate;
    final focusedDay = selectedDay;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Container(
              color: Colors.black,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                onDaySelected: (selected, focused) => onDaySelected(selected),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: Colors.white70),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white70),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            crossFadeState:
                showFullCalendar
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          Container(
            height: 80,
            color: Colors.black,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index - 15));
                final isSelected = isSameDay(date, selectedDay);
                final isToday = isSameDay(date, DateTime.now());

                return GestureDetector(
                  onTap: () => onDaySelected(date),
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy < -5) {
                      onToggleCalendar(true);
                    } else if (details.delta.dy > 5) {
                      onToggleCalendar(false);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d/M').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isToday
                              ? 'TODAY'
                              : DateFormat('E').format(date).toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontSize: 12,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter_app/domain/models/day_model.dart';
import 'package:firebase_flutter_app/services/tasks_servise.dart';
import 'package:firebase_flutter_app/services/stats_service.dart';

// Strona pokazująca statystyki produktywności użytkownika (średnia, wykres, lista dni)

class ProductivityStatsPage extends StatelessWidget {
  const ProductivityStatsPage({super.key});

  // Tworzy stronę i podłącza ViewModel do Provider'a
  static Widget create() {
    return ChangeNotifierProvider(
      create:
          (_) =>
              _StatsViewModel()..loadData(), // Ładowanie danych po utworzeniu
      child: const ProductivityStatsPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<_StatsViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Your Productivity'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          model.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pasek z średnią i filtrem czasowym
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Average: ${(model.averageProductivity * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownButton<StatsFilter>(
                          dropdownColor: Colors.grey[900],
                          value: model.filter,
                          style: const TextStyle(color: Colors.white),
                          items:
                              StatsFilter.values.map((filter) {
                                return DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter.name.toUpperCase()),
                                );
                              }).toList(),
                          onChanged: (value) => model.updateFilter(value!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Wykres produktywności
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white30, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(height: 220, child: _buildChart(model)),
                    ),
                    const SizedBox(height: 20),

                    // Lista dni z produktywnością
                    Expanded(child: _buildDayList(model)),
                  ],
                ),
              ),
    );
  }

  // Rysuje wykres liniowy postępu dziennego
  Widget _buildChart(_StatsViewModel model) {
    final reversed = model.filteredDays.reversed.toList();
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.white24, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index < reversed.length) {
                  final date = reversed[index].date;
                  return Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.25,
              getTitlesWidget:
                  (value, _) => Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots:
                reversed
                    .asMap()
                    .entries
                    .map(
                      (entry) =>
                          FlSpot(entry.key.toDouble(), entry.value.progress),
                    )
                    .toList(),
            isCurved: true,
            color: Colors.blue,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
            dotData: FlDotData(show: true),
            barWidth: 3,
          ),
        ],
      ),
    );
  }

  // Tworzy listę z datą i procentem wykonania zadań
  Widget _buildDayList(_StatsViewModel model) {
    return ListView.builder(
      itemCount: model.filteredDays.length,
      itemBuilder: (context, index) {
        final day = model.filteredDays[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                '${(day.progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Filtr czasowy dla statystyk: tydzień, miesiąc, rok
enum StatsFilter { week, month, year }

class _StatsViewModel extends ChangeNotifier {
  final _dayService = DayService();
  final _statsService = UserStatsService();

  List<DayModel> allDays = [];
  List<DayModel> filteredDays = [];
  bool isLoading = true;
  double averageProductivity = 0.0;
  StatsFilter filter = StatsFilter.week;

  // Pobiera dane z Firestore i przelicza średnią produktywność
  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    allDays =
        (await _dayService.fetchAllUserDays())
            .where((d) => !d.date.isAfter(today) && d.tasks.isNotEmpty)
            .toList();

    allDays.sort((a, b) => b.date.compareTo(a.date));

    averageProductivity = await _statsService.calculateTotalProductivity();
    _filterDays();

    isLoading = false;
    notifyListeners();
  }

  // Zmienia filtr i przelicza listę dni
  void updateFilter(StatsFilter newFilter) {
    filter = newFilter;
    _filterDays();
    notifyListeners();
  }

  // Filtrowanie listy dni w zależności od wybranego zakresu
  void _filterDays() {
    final now = DateTime.now();
    late DateTime fromDate;

    switch (filter) {
      case StatsFilter.week:
        fromDate = now.subtract(const Duration(days: 6));
        break;
      case StatsFilter.month:
        fromDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case StatsFilter.year:
        fromDate = DateTime(now.year - 1, now.month, now.day);
        break;
    }

    filteredDays =
        allDays
            .where((d) => !d.date.isAfter(now) && !d.date.isBefore(fromDate))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
  }
}

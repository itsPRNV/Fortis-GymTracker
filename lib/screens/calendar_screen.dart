import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/database_service.dart';
import '../models/exercise.dart';
import 'workout_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _workoutDates = {};
  List<Workout> _selectedDayWorkouts = [];
  Map<DateTime, int> _workoutCounts = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadWorkoutDates();
  }

  Future<void> _loadWorkoutDates() async {
    final dates = await DatabaseService.instance.getWorkoutDates();
    final counts = await DatabaseService.instance.getWorkoutCounts();
    setState(() {
      _workoutDates = dates;
      _workoutCounts = counts;
    });
    if (_selectedDay != null) {
      await _loadWorkoutsForDay(_selectedDay!);
    }
  }

  Future<void> _loadWorkoutsForDay(DateTime day) async {
    final workouts = await DatabaseService.instance.getWorkoutsForDate(day);
    setState(() {
      _selectedDayWorkouts = workouts;
    });
  }

  bool _isWorkoutDay(DateTime day) {
    return _workoutDates.any((workoutDate) => isSameDay(workoutDate, day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          TableCalendar<String>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadWorkoutsForDay(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_isWorkoutDay(day)) {
                  final dayOnly = DateTime(day.year, day.month, day.day);
                  final count = _workoutCounts[dayOnly] ?? 0;
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (count > 1)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                final dayOnly = DateTime(day.year, day.month, day.day);
                final count = _workoutCounts[dayOnly] ?? 0;
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: _isWorkoutDay(day) 
                        ? Colors.green 
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (count > 1)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: _isWorkoutDay(day) ? Colors.green : Theme.of(context).primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                final dayOnly = DateTime(day.year, day.month, day.day);
                final count = _workoutCounts[dayOnly] ?? 0;
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: _isWorkoutDay(day) 
                        ? Colors.green.shade700 
                        : Theme.of(context).primaryColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (count > 1)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: _isWorkoutDay(day) ? Colors.green.shade700 : Theme.of(context).primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Workout Day'),
                const SizedBox(width: 20),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Rest Day'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null) ...{
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Workouts on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedDayWorkouts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No workouts on this day',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _selectedDayWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = _selectedDayWorkouts[index];
                        return Card(
                          child: ListTile(
                            title: Text(workout.name),
                            subtitle: Text(
                              '${workout.exercises.length} exercises • ${workout.duration ?? 0} min',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutDetailScreen(workout: workout),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          },
        ],
      ),
    );
  }
}
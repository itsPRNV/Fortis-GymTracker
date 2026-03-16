import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/exercise.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fortis_ui.dart';
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
    if (!mounted) return;
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
    if (!mounted) return;
    setState(() {
      _selectedDayWorkouts = workouts;
    });
  }

  bool _isWorkoutDay(DateTime day) {
    return _workoutDates.any((workoutDate) => isSameDay(workoutDate, day));
  }

  @override
  Widget build(BuildContext context) {
    return FortisScaffold(
      appBar: AppBar(title: const Text('Workout Calendar')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: ListView(
          children: [
            FortisCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FortisSectionHeader(
                    title: 'Session map',
                    subtitle: 'Tap any day to revisit what you trained and when.',
                  ),
                  const SizedBox(height: 18),
                  TableCalendar<String>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
                      ),
                      defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
                      weekendTextStyle: Theme.of(context).textTheme.bodyMedium!,
                      todayDecoration: const BoxDecoration(),
                      selectedDecoration: const BoxDecoration(),
                      cellMargin: const EdgeInsets.all(6),
                    ),
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
                      defaultBuilder: (context, day, focusedDay) => _buildDayCell(context, day),
                      todayBuilder: (context, day, focusedDay) => _buildDayCell(context, day, isToday: true),
                      selectedBuilder: (context, day, focusedDay) => _buildDayCell(context, day, isSelected: true),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _LegendChip(label: 'Workout day', color: AppTheme.accentSecondary),
                      _LegendChip(label: 'Today', color: AppTheme.accent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FortisSectionHeader(
              title: _selectedDay == null
                  ? 'Selected day'
                  : 'Workouts on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              subtitle: _selectedDayWorkouts.isEmpty
                  ? 'Nothing logged yet for this date.'
                  : '${_selectedDayWorkouts.length} session${_selectedDayWorkouts.length == 1 ? '' : 's'} found.',
            ),
            const SizedBox(height: 14),
            if (_selectedDayWorkouts.isEmpty)
              const FortisEmptyState(
                icon: Icons.calendar_today_rounded,
                title: 'No workouts logged',
                subtitle: 'Your completed sessions for the selected day will appear here.',
              )
            else
              ..._selectedDayWorkouts.map((workout) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FortisCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workout: workout),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppTheme.accentSecondary.withOpacity(0.14),
                          ),
                          child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accentSecondary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workout.exercises.length} exercises - ${workout.duration ?? 0} min',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    final count = _workoutCounts[dayOnly] ?? 0;
    final hasWorkout = _isWorkoutDay(day);
    final backgroundColor = isSelected
        ? AppTheme.accent
        : hasWorkout
            ? AppTheme.accentSecondary.withOpacity(0.18)
            : Colors.transparent;
    final foregroundColor = isSelected
        ? Colors.white
        : hasWorkout
            ? AppTheme.accentSecondary
            : Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? AppTheme.accent.withOpacity(0.5)
              : hasWorkout
                  ? AppTheme.accentSecondary.withOpacity(0.22)
                  : Colors.transparent,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : AppTheme.accent,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppTheme.accent : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

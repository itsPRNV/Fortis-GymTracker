import 'package:flutter/material.dart';
import '../models/exercise.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareWorkout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(workout.date),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(workout.duration),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${workout.exercises.length} exercises',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Exercises list
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            
            ...workout.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _ExerciseDetailCard(
                exercise: exercise,
                exerciseNumber: index + 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDuration(int? durationMinutes) {
    if (durationMinutes == null) return 'Duration not recorded';
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _shareWorkout(BuildContext context) {
    // Simple share functionality
    final workoutSummary = 'Workout: ${workout.name}\n'
        'Date: ${_formatDate(workout.date)}\n'
        'Duration: ${_formatDuration(workout.duration)}\n'
        'Exercises: ${workout.exercises.length}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout summary copied: $workoutSummary')),
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final int exerciseNumber;

  const _ExerciseDetailCard({
    required this.exercise,
    required this.exerciseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$exerciseNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exercise?.name ?? 'Unknown Exercise',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (exercise.exercise?.category != null)
                        Text(
                          exercise.exercise!.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sets header
            const Row(
              children: [
                Expanded(flex: 1, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            
            // Sets data
            if (exercise.sets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No sets recorded', style: TextStyle(color: Colors.grey)),
              )
            else
              ...exercise.sets.asMap().entries.map((entry) {
                final setIndex = entry.key;
                final set = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Text('${setIndex + 1}')),
                      Expanded(flex: 2, child: Text('${set.reps}')),
                      Expanded(flex: 2, child: Text(set.weight?.toString() ?? '-')),
                      Expanded(flex: 2, child: Text(set.duration != null ? '${set.duration}s' : '-')),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
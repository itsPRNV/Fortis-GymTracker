import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        if (!workoutProvider.isWorkoutActive) {
          return const _NoActiveWorkoutScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(workoutProvider.currentWorkout!.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showExerciseSelector(context),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _finishWorkout(context),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workoutProvider.currentWorkout!.exercises.length,
            itemBuilder: (context, index) {
              final exercise = workoutProvider.currentWorkout!.exercises[index];
              return _ExerciseCard(
                exercise: exercise,
                exerciseIndex: index,
              );
            },
          ),
        );
      },
    );
  }

  void _showExerciseSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _ExerciseSelector(),
    );
  }

  void _finishWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Workout'),
        content: const Text('Are you sure you want to finish this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkoutProvider>().finishWorkout();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}

class _NoActiveWorkoutScreen extends StatelessWidget {
  const _NoActiveWorkoutScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No active workout',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a workout from the home screen',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final int exerciseIndex;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.exercise?.name ?? 'Unknown Exercise',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddSetDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
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
            
            // Sets list
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text('${index + 1}')),
                    Expanded(flex: 2, child: Text('${set.reps}')),
                    Expanded(flex: 2, child: Text(set.weight?.toString() ?? '-')),
                    Expanded(flex: 2, child: Text(set.duration != null ? '${set.duration}s' : '-')),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddSetDialog(BuildContext context) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (seconds)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text) ?? 0;
              final weight = double.tryParse(weightController.text);
              final duration = int.tryParse(durationController.text);

              if (reps > 0) {
                final set = WorkoutSet(
                  workoutExerciseId: 0,
                  reps: reps,
                  weight: weight,
                  duration: duration,
                );
                context.read<WorkoutProvider>().addSetToExercise(exerciseIndex, set);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSelector extends StatelessWidget {
  const _ExerciseSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final exercisesByCategory = <String, List<Exercise>>{};
        for (final exercise in workoutProvider.exercises) {
          exercisesByCategory.putIfAbsent(exercise.category, () => []).add(exercise);
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Exercise', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => _showAddCustomExerciseDialog(context),
                    child: const Text('Add Custom'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: exercisesByCategory.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(entry.key),
                      children: entry.value.map((exercise) {
                        return ListTile(
                          title: Text(exercise.name),
                          onTap: () {
                            workoutProvider.addExerciseToWorkout(exercise);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCustomExerciseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                context.read<WorkoutProvider>().addCustomExercise(
                  nameController.text,
                  categoryController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
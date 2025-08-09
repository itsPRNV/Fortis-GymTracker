import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import 'form_correction_screen.dart';

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
                Expanded(
                  child: Text(
                    exercise.exercise?.name ?? 'Unknown Exercise',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormCorrectionScreen(
                        exerciseName: exercise.exercise?.name ?? 'Exercise',
                      ),
                    ),
                  ),
                  tooltip: 'Form Check',
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
            }),
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

class _ExerciseSelector extends StatefulWidget {
  const _ExerciseSelector();

  @override
  State<_ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<_ExerciseSelector> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final exercisesByCategory = <String, List<Exercise>>{};
        for (final exercise in workoutProvider.exercises) {
          exercisesByCategory.putIfAbsent(exercise.category, () => []).add(exercise);
        }

        // Filter exercises based on search and category
        final filteredExercises = workoutProvider.exercises.where((exercise) {
          final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == null || exercise.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        final categories = exercisesByCategory.keys.toList()..sort();

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
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
              
              // Search bar
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Category filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategory == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                      );
                    }
                    final category = categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Exercise list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return Card(
                      child: ListTile(
                        title: Text(exercise.name),
                        subtitle: Text('${exercise.category}${exercise.description != null ? ' • ${exercise.description}' : ''}'),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          workoutProvider.addExerciseToWorkout(exercise);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fortis_ui.dart';
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

        final workout = workoutProvider.currentWorkout!;

        return FortisScaffold(
          appBar: AppBar(
            title: Text(workout.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => _showExerciseSelector(context),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline_rounded),
                onPressed: () => _finishWorkout(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              FortisCard(
                gradient: [
                  Theme.of(context).cardColor.withOpacity(0.98),
                  Theme.of(context).cardColor.withOpacity(0.82),
                ],
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${workout.exercises.length} exercises in progress',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const FortisBadge(label: 'Live', color: AppTheme.accent),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (workout.exercises.isEmpty)
                const FortisEmptyState(
                  icon: Icons.playlist_add_rounded,
                  title: 'No exercises yet',
                  subtitle: 'Add your first movement to get this workout rolling.',
                )
              else
                ...workout.exercises.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ExerciseCard(
                      exercise: entry.value,
                      exerciseIndex: entry.key,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showExerciseSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    return const FortisScaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FortisEmptyState(
          icon: Icons.fitness_center_rounded,
          title: 'No active workout',
          subtitle: 'Start a workout from the home screen and it will appear here.',
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
    return FortisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exercise?.name ?? 'Unknown Exercise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.videocam_outlined),
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
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: () => _showAddSetDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).cardColor.withOpacity(0.45),
            ),
            child: const Row(
              children: [
                _HeaderCell(label: 'Set', flex: 1),
                _HeaderCell(label: 'Reps', flex: 2),
                _HeaderCell(label: 'Weight', flex: 2),
                _HeaderCell(label: 'Time', flex: 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (exercise.sets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No sets added yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                    ),
              ),
            )
          else
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).cardColor.withOpacity(0.28),
                ),
                child: Row(
                  children: [
                    _ValueCell(value: '${index + 1}', flex: 1),
                    _ValueCell(value: '${set.reps}', flex: 2),
                    _ValueCell(value: set.weight?.toString() ?? '-', flex: 2),
                    _ValueCell(value: set.duration != null ? '${set.duration}s' : '-', flex: 2),
                  ],
                ),
              );
            }),
        ],
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
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
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

        final filteredExercises = workoutProvider.exercises.where((exercise) {
          final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == null || exercise.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        final categories = exercisesByCategory.keys.toList()..sort();

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: FortisCard(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Exercise',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showAddCustomExerciseDialog(context),
                        child: const Text('Add custom'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredExercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return FortisCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            workoutProvider.addExerciseToWorkout(exercise);
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: AppTheme.accentSecondary.withOpacity(0.14),
                                ),
                                child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accentSecondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exercise.description == null
                                          ? exercise.category
                                          : '${exercise.category} - ${exercise.description}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.add_rounded),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
            const SizedBox(height: 12),
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

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _HeaderCell({
    required this.label,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
            ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String value;
  final int flex;

  const _ValueCell({
    required this.value,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

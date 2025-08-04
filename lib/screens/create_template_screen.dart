import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/template_provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_template.dart';
import '../models/exercise.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _nameController = TextEditingController();
  final List<TemplateExercise> _exercises = [];
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Template'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _exercises.isNotEmpty && _nameController.text.isNotEmpty
                ? _saveTemplate
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_exercises.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Selected Exercises (${_exercises.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ListTile(
                    title: Text(exercise.exerciseName ?? ''),
                    subtitle: Text(exercise.exerciseCategory ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          _exercises.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Add Exercises',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WorkoutProvider>(
              builder: (context, workoutProvider, child) {
                final filteredExercises = _selectedCategory == 'All'
                    ? workoutProvider.exercises
                    : workoutProvider.exercises
                        .where((e) => e.category == _selectedCategory)
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    final isSelected = _exercises.any((e) => e.exerciseId == exercise.id);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(exercise.category),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.add_circle_outline),
                        onTap: isSelected
                            ? null
                            : () {
                                setState(() {
                                  _exercises.add(TemplateExercise(
                                    templateId: 0,
                                    exerciseId: exercise.id!,
                                    exerciseName: exercise.name,
                                    exerciseCategory: exercise.category,
                                    sets: [
                                      TemplateSet(
                                        templateExerciseId: 0,
                                        reps: 10,
                                        weight: 0,
                                      ),
                                    ],
                                  ));
                                });
                              },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.isEmpty || _exercises.isEmpty) return;

    final templateProvider = context.read<TemplateProvider>();
    final success = await templateProvider.createTemplate(
      _nameController.text,
      _exercises,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template created successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create more than 3 templates')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import '../models/workout_template.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

class TemplateProvider extends ChangeNotifier {
  List<WorkoutTemplate> _templates = [];
  static const int maxTemplates = 3;

  List<WorkoutTemplate> get templates => _templates;
  bool get canCreateTemplate => _templates.length < maxTemplates;
  int get remainingTemplates => maxTemplates - _templates.length;

  TemplateProvider() {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    _templates = await DatabaseService.instance.getTemplates();
    notifyListeners();
  }

  Future<bool> createTemplate(String name, List<TemplateExercise> exercises) async {
    if (!canCreateTemplate) return false;
    
    final template = WorkoutTemplate(
      name: name,
      createdAt: DateTime.now(),
      exercises: exercises,
    );
    
    await DatabaseService.instance.insertTemplate(template);
    await loadTemplates();
    return true;
  }

  Future<void> deleteTemplate(int templateId) async {
    await DatabaseService.instance.deleteTemplate(templateId);
    await loadTemplates();
  }

  Workout createWorkoutFromTemplate(WorkoutTemplate template) {
    final workoutExercises = template.exercises.map((templateExercise) {
      final sets = templateExercise.sets.map((templateSet) {
        return WorkoutSet(
          workoutExerciseId: 0,
          reps: templateSet.reps,
          weight: templateSet.weight,
          duration: templateSet.duration,
        );
      }).toList();

      return WorkoutExercise(
        workoutId: 0,
        exerciseId: templateExercise.exerciseId,
        exercise: Exercise(
          id: templateExercise.exerciseId,
          name: templateExercise.exerciseName ?? '',
          category: templateExercise.exerciseCategory ?? '',
        ),
        sets: sets,
      );
    }).toList();

    return Workout(
      name: template.name,
      date: DateTime.now(),
      exercises: workoutExercises,
    );
  }
}
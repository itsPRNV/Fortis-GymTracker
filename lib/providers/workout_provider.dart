import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Exercise> _exercises = [];
  List<Workout> _workouts = [];
  Workout? _currentWorkout;
  DateTime? _workoutStartTime;

  List<Exercise> get exercises => _exercises;
  List<Workout> get workouts => _workouts;
  Workout? get currentWorkout => _currentWorkout;
  bool get isWorkoutActive => _currentWorkout != null;

  WorkoutProvider() {
    loadExercises();
  }

  Future<void> loadExercises() async {
    _exercises = await DatabaseService.instance.getExercises();
    notifyListeners();
  }

  Future<void> loadWorkouts() async {
    _workouts = await DatabaseService.instance.getWorkouts();
    notifyListeners();
  }

  void startWorkout(String name) {
    _currentWorkout = Workout(
      name: name,
      date: DateTime.now(),
      exercises: [],
    );
    _workoutStartTime = DateTime.now();
    notifyListeners();
  }

  void startWorkoutFromTemplate(Workout templateWorkout) {
    _currentWorkout = Workout(
      name: templateWorkout.name,
      date: DateTime.now(),
      exercises: templateWorkout.exercises,
    );
    _workoutStartTime = DateTime.now();
    notifyListeners();
  }

  void addExerciseToWorkout(Exercise exercise) {
    if (_currentWorkout != null) {
      final workoutExercise = WorkoutExercise(
        workoutId: 0,
        exerciseId: exercise.id!,
        exercise: exercise,
        sets: [],
      );
      _currentWorkout = Workout(
        id: _currentWorkout!.id,
        name: _currentWorkout!.name,
        date: _currentWorkout!.date,
        duration: _currentWorkout!.duration,
        exercises: [..._currentWorkout!.exercises, workoutExercise],
      );
      notifyListeners();
    }
  }

  void addSetToExercise(int exerciseIndex, WorkoutSet set) {
    if (_currentWorkout != null && exerciseIndex < _currentWorkout!.exercises.length) {
      final exercise = _currentWorkout!.exercises[exerciseIndex];
      final updatedExercise = WorkoutExercise(
        id: exercise.id,
        workoutId: exercise.workoutId,
        exerciseId: exercise.exerciseId,
        exercise: exercise.exercise,
        sets: [...exercise.sets, set],
      );
      
      final updatedExercises = List<WorkoutExercise>.from(_currentWorkout!.exercises);
      updatedExercises[exerciseIndex] = updatedExercise;
      
      _currentWorkout = Workout(
        id: _currentWorkout!.id,
        name: _currentWorkout!.name,
        date: _currentWorkout!.date,
        duration: _currentWorkout!.duration,
        exercises: updatedExercises,
      );
      notifyListeners();
    }
  }

  Future<void> finishWorkout() async {
    if (_currentWorkout != null && _workoutStartTime != null) {
      final duration = DateTime.now().difference(_workoutStartTime!).inMinutes;
      final completedWorkout = Workout(
        name: _currentWorkout!.name,
        date: _currentWorkout!.date,
        duration: duration,
        exercises: _currentWorkout!.exercises,
      );
      
      await DatabaseService.instance.insertWorkout(completedWorkout);
      _currentWorkout = null;
      _workoutStartTime = null;
      await loadWorkouts();
      notifyListeners();
    }
  }

  void cancelWorkout() {
    _currentWorkout = null;
    _workoutStartTime = null;
    notifyListeners();
  }

  Future<void> addCustomExercise(String name, String category) async {
    final exercise = Exercise(name: name, category: category);
    await DatabaseService.instance.insertExercise(exercise);
    await loadExercises();
  }


}
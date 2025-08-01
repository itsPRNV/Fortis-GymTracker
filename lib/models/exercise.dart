class Exercise {
  final int? id;
  final String name;
  final String category;
  final String? description;

  Exercise({
    this.id,
    required this.name,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
    );
  }


}

class WorkoutSet {
  final int? id;
  final int workoutExerciseId;
  final int reps;
  final double? weight;
  final int? duration;

  WorkoutSet({
    this.id,
    required this.workoutExerciseId,
    required this.reps,
    this.weight,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_exercise_id': workoutExerciseId,
      'reps': reps,
      'weight': weight,
      'duration': duration,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      workoutExerciseId: map['workout_exercise_id'],
      reps: map['reps'],
      weight: map['weight']?.toDouble(),
      duration: map['duration'],
    );
  }
}

class WorkoutExercise {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final Exercise? exercise;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    this.exercise,
    this.sets = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'],
      workoutId: map['workout_id'],
      exerciseId: map['exercise_id'],
    );
  }
}

class Workout {
  final int? id;
  final String name;
  final DateTime date;
  final int? duration;
  final List<WorkoutExercise> exercises;

  Workout({
    this.id,
    required this.name,
    required this.date,
    this.duration,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'duration': duration,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
    );
  }


}
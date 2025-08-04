class WorkoutTemplate {
  final int? id;
  final String name;
  final DateTime createdAt;
  final List<TemplateExercise> exercises;

  WorkoutTemplate({
    this.id,
    required this.name,
    required this.createdAt,
    this.exercises = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkoutTemplate.fromMap(Map<String, dynamic> map) {
    return WorkoutTemplate(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class TemplateExercise {
  final int? id;
  final int templateId;
  final int exerciseId;
  final String? exerciseName;
  final String? exerciseCategory;
  final List<TemplateSet> sets;

  TemplateExercise({
    this.id,
    required this.templateId,
    required this.exerciseId,
    this.exerciseName,
    this.exerciseCategory,
    this.sets = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_id': templateId,
      'exercise_id': exerciseId,
    };
  }

  factory TemplateExercise.fromMap(Map<String, dynamic> map) {
    return TemplateExercise(
      id: map['id'],
      templateId: map['template_id'],
      exerciseId: map['exercise_id'],
      exerciseName: map['exercise_name'],
      exerciseCategory: map['exercise_category'],
    );
  }
}

class TemplateSet {
  final int? id;
  final int templateExerciseId;
  final int reps;
  final double? weight;
  final int? duration;

  TemplateSet({
    this.id,
    required this.templateExerciseId,
    required this.reps,
    this.weight,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'template_exercise_id': templateExerciseId,
      'reps': reps,
      'weight': weight,
      'duration': duration,
    };
  }

  factory TemplateSet.fromMap(Map<String, dynamic> map) {
    return TemplateSet(
      id: map['id'],
      templateExerciseId: map['template_exercise_id'],
      reps: map['reps'],
      weight: map['weight']?.toDouble(),
      duration: map['duration'],
    );
  }
}
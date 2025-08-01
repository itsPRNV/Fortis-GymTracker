import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/exercise.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gym_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Clear and reload exercises with new comprehensive list
      await db.delete('exercises');
      await _insertDefaultExercises(db);
    }
    if (oldVersion < 3) {
      // Remove inappropriate exercises and duplicates
      await db.delete('exercises', where: 'name = ?', whereArgs: ['fuck him']);
      await db.delete('exercises', where: 'name LIKE ?', whereArgs: ['%fuck%']);
      // Remove duplicates
      await db.execute('''
        DELETE FROM exercises 
        WHERE id NOT IN (
          SELECT MIN(id) 
          FROM exercises 
          GROUP BY name, category
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        duration INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id),
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_exercise_id INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL,
        duration INTEGER,
        FOREIGN KEY (workout_exercise_id) REFERENCES workout_exercises (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        profile_image TEXT,
        current_weight REAL,
        height REAL,
        target_weight REAL,
        fitness_goal TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE body_metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        body_fat REAL,
        muscle_mass REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        unlocked_date TEXT
      )
    ''');

    // Insert default exercises
    await _insertDefaultExercises(db);
    await _insertDefaultAchievements(db);
  }

  Future _insertDefaultExercises(Database db) async {
    final exercises = [
      // Chest Exercises
      {'name': 'Bench Press', 'category': 'Chest', 'description': 'Barbell bench press for chest development'},
      {'name': 'Incline Bench Press', 'category': 'Chest', 'description': 'Incline barbell press for upper chest'},
      {'name': 'Decline Bench Press', 'category': 'Chest', 'description': 'Decline barbell press for lower chest'},
      {'name': 'Dumbbell Press', 'category': 'Chest', 'description': 'Flat dumbbell chest press'},
      {'name': 'Incline Dumbbell Press', 'category': 'Chest', 'description': 'Incline dumbbell press'},
      {'name': 'Decline Dumbbell Press', 'category': 'Chest', 'description': 'Decline dumbbell press'},
      {'name': 'Push-ups', 'category': 'Chest', 'description': 'Bodyweight chest exercise'},
      {'name': 'Incline Push-ups', 'category': 'Chest', 'description': 'Push-ups with feet elevated'},
      {'name': 'Diamond Push-ups', 'category': 'Chest', 'description': 'Close-grip push-ups for triceps'},
      {'name': 'Chest Flyes', 'category': 'Chest', 'description': 'Dumbbell flyes for chest isolation'},
      {'name': 'Incline Flyes', 'category': 'Chest', 'description': 'Incline dumbbell flyes'},
      {'name': 'Cable Flyes', 'category': 'Chest', 'description': 'Cable crossover flyes'},
      {'name': 'Pec Deck', 'category': 'Chest', 'description': 'Machine chest flyes'},
      {'name': 'Chest Dips', 'category': 'Chest', 'description': 'Parallel bar dips for chest'},
      
      // Back Exercises
      {'name': 'Deadlift', 'category': 'Back', 'description': 'Conventional deadlift'},
      {'name': 'Sumo Deadlift', 'category': 'Back', 'description': 'Wide stance deadlift'},
      {'name': 'Romanian Deadlift', 'category': 'Back', 'description': 'Hip hinge deadlift variation'},
      {'name': 'Pull-ups', 'category': 'Back', 'description': 'Bodyweight vertical pull'},
      {'name': 'Chin-ups', 'category': 'Back', 'description': 'Underhand grip pull-ups'},
      {'name': 'Wide Grip Pull-ups', 'category': 'Back', 'description': 'Wide grip lat pulldown motion'},
      {'name': 'Lat Pulldown', 'category': 'Back', 'description': 'Cable lat pulldown'},
      {'name': 'Wide Grip Lat Pulldown', 'category': 'Back', 'description': 'Wide grip cable pulldown'},
      {'name': 'Close Grip Lat Pulldown', 'category': 'Back', 'description': 'Narrow grip pulldown'},
      {'name': 'Barbell Rows', 'category': 'Back', 'description': 'Bent over barbell rows'},
      {'name': 'T-Bar Rows', 'category': 'Back', 'description': 'T-bar rowing exercise'},
      {'name': 'Dumbbell Rows', 'category': 'Back', 'description': 'Single arm dumbbell rows'},
      {'name': 'Seated Cable Rows', 'category': 'Back', 'description': 'Seated cable rowing'},
      {'name': 'Face Pulls', 'category': 'Back', 'description': 'Cable face pulls for rear delts'},
      {'name': 'Reverse Flyes', 'category': 'Back', 'description': 'Rear delt flyes'},
      {'name': 'Shrugs', 'category': 'Back', 'description': 'Barbell or dumbbell shrugs'},
      
      // Leg Exercises
      {'name': 'Squats', 'category': 'Legs', 'description': 'Barbell back squats'},
      {'name': 'Front Squats', 'category': 'Legs', 'description': 'Front-loaded squats'},
      {'name': 'Goblet Squats', 'category': 'Legs', 'description': 'Dumbbell goblet squats'},
      {'name': 'Bulgarian Split Squats', 'category': 'Legs', 'description': 'Single leg rear-foot elevated squats'},
      {'name': 'Lunges', 'category': 'Legs', 'description': 'Forward lunges'},
      {'name': 'Reverse Lunges', 'category': 'Legs', 'description': 'Backward stepping lunges'},
      {'name': 'Walking Lunges', 'category': 'Legs', 'description': 'Moving forward lunges'},
      {'name': 'Lateral Lunges', 'category': 'Legs', 'description': 'Side-to-side lunges'},
      {'name': 'Leg Press', 'category': 'Legs', 'description': 'Machine leg press'},
      {'name': 'Hack Squats', 'category': 'Legs', 'description': 'Hack squat machine'},
      {'name': 'Leg Extensions', 'category': 'Legs', 'description': 'Quadriceps isolation'},
      {'name': 'Leg Curls', 'category': 'Legs', 'description': 'Hamstring curls'},
      {'name': 'Stiff Leg Deadlifts', 'category': 'Legs', 'description': 'Straight leg deadlifts'},
      {'name': 'Calf Raises', 'category': 'Legs', 'description': 'Standing calf raises'},
      {'name': 'Seated Calf Raises', 'category': 'Legs', 'description': 'Seated calf raises'},
      {'name': 'Jump Squats', 'category': 'Legs', 'description': 'Explosive squat jumps'},
      
      // Shoulder Exercises
      {'name': 'Overhead Press', 'category': 'Shoulders', 'description': 'Standing barbell press'},
      {'name': 'Seated Press', 'category': 'Shoulders', 'description': 'Seated barbell press'},
      {'name': 'Dumbbell Press', 'category': 'Shoulders', 'description': 'Seated dumbbell press'},
      {'name': 'Arnold Press', 'category': 'Shoulders', 'description': 'Rotating dumbbell press'},
      {'name': 'Lateral Raises', 'category': 'Shoulders', 'description': 'Side lateral raises'},
      {'name': 'Front Raises', 'category': 'Shoulders', 'description': 'Front delt raises'},
      {'name': 'Rear Delt Flyes', 'category': 'Shoulders', 'description': 'Rear deltoid flyes'},
      {'name': 'Upright Rows', 'category': 'Shoulders', 'description': 'Barbell upright rows'},
      {'name': 'Pike Push-ups', 'category': 'Shoulders', 'description': 'Inverted push-ups'},
      {'name': 'Handstand Push-ups', 'category': 'Shoulders', 'description': 'Wall handstand push-ups'},
      
      // Arm Exercises - Biceps
      {'name': 'Barbell Curls', 'category': 'Arms', 'description': 'Standing barbell bicep curls'},
      {'name': 'Dumbbell Curls', 'category': 'Arms', 'description': 'Alternating dumbbell curls'},
      {'name': 'Hammer Curls', 'category': 'Arms', 'description': 'Neutral grip dumbbell curls'},
      {'name': 'Preacher Curls', 'category': 'Arms', 'description': 'Preacher bench curls'},
      {'name': 'Cable Curls', 'category': 'Arms', 'description': 'Cable bicep curls'},
      {'name': 'Concentration Curls', 'category': 'Arms', 'description': 'Seated concentration curls'},
      {'name': '21s', 'category': 'Arms', 'description': '7 bottom half + 7 top half + 7 full reps'},
      
      // Arm Exercises - Triceps
      {'name': 'Close Grip Bench Press', 'category': 'Arms', 'description': 'Narrow grip bench press'},
      {'name': 'Tricep Dips', 'category': 'Arms', 'description': 'Parallel bar or bench dips'},
      {'name': 'Overhead Tricep Extension', 'category': 'Arms', 'description': 'Seated overhead extension'},
      {'name': 'Lying Tricep Extension', 'category': 'Arms', 'description': 'Skull crushers'},
      {'name': 'Tricep Pushdowns', 'category': 'Arms', 'description': 'Cable tricep pushdowns'},
      {'name': 'Kickbacks', 'category': 'Arms', 'description': 'Dumbbell tricep kickbacks'},
      
      // Core Exercises
      {'name': 'Plank', 'category': 'Core', 'description': 'Standard plank hold'},
      {'name': 'Side Plank', 'category': 'Core', 'description': 'Lateral plank hold'},
      {'name': 'Crunches', 'category': 'Core', 'description': 'Basic abdominal crunches'},
      {'name': 'Bicycle Crunches', 'category': 'Core', 'description': 'Alternating bicycle motion'},
      {'name': 'Russian Twists', 'category': 'Core', 'description': 'Seated torso rotations'},
      {'name': 'Mountain Climbers', 'category': 'Core', 'description': 'Dynamic plank movement'},
      {'name': 'Dead Bug', 'category': 'Core', 'description': 'Lying core stability exercise'},
      {'name': 'Hanging Leg Raises', 'category': 'Core', 'description': 'Hanging knee/leg raises'},
      {'name': 'Ab Wheel Rollouts', 'category': 'Core', 'description': 'Ab wheel exercise'},
      {'name': 'Leg Raises', 'category': 'Core', 'description': 'Lying leg raises'},
      {'name': 'Sit-ups', 'category': 'Core', 'description': 'Full sit-up movement'},
      {'name': 'V-ups', 'category': 'Core', 'description': 'V-shaped crunch movement'},
      
      // Cardio Exercises
      {'name': 'Treadmill', 'category': 'Cardio', 'description': 'Treadmill running/walking'},
      {'name': 'Elliptical', 'category': 'Cardio', 'description': 'Elliptical machine'},
      {'name': 'Stationary Bike', 'category': 'Cardio', 'description': 'Exercise bike'},
      {'name': 'Rowing Machine', 'category': 'Cardio', 'description': 'Indoor rowing'},
      {'name': 'Stair Climber', 'category': 'Cardio', 'description': 'Stair climbing machine'},
      {'name': 'Burpees', 'category': 'Cardio', 'description': 'Full body burpee exercise'},
      {'name': 'Jumping Jacks', 'category': 'Cardio', 'description': 'Jumping jack exercise'},
      {'name': 'High Knees', 'category': 'Cardio', 'description': 'High knee running in place'},
      {'name': 'Jump Rope', 'category': 'Cardio', 'description': 'Skipping rope exercise'},
      
      // Functional/Olympic Exercises
      {'name': 'Clean and Press', 'category': 'Olympic', 'description': 'Olympic clean and press'},
      {'name': 'Snatch', 'category': 'Olympic', 'description': 'Olympic snatch lift'},
      {'name': 'Clean and Jerk', 'category': 'Olympic', 'description': 'Olympic clean and jerk'},
      {'name': 'Thrusters', 'category': 'Functional', 'description': 'Squat to overhead press'},
      {'name': 'Turkish Get-ups', 'category': 'Functional', 'description': 'Full body get-up movement'},
      {'name': 'Farmers Walk', 'category': 'Functional', 'description': 'Heavy carry exercise'},
      {'name': 'Battle Ropes', 'category': 'Functional', 'description': 'Heavy rope training'},
      {'name': 'Kettlebell Swings', 'category': 'Functional', 'description': 'Hip hinge kettlebell movement'},
      {'name': 'Box Jumps', 'category': 'Functional', 'description': 'Plyometric box jumps'},
      
      // Stretching/Mobility
      {'name': 'Foam Rolling', 'category': 'Mobility', 'description': 'Self-myofascial release'},
      {'name': 'Hip Flexor Stretch', 'category': 'Mobility', 'description': 'Hip flexor stretching'},
      {'name': 'Hamstring Stretch', 'category': 'Mobility', 'description': 'Hamstring flexibility'},
      {'name': 'Shoulder Stretch', 'category': 'Mobility', 'description': 'Shoulder mobility work'},
      {'name': 'Cat-Cow Stretch', 'category': 'Mobility', 'description': 'Spinal mobility exercise'},
      
      // Arm Exercises - Triceps
      {'name': 'Close Grip Bench Press', 'category': 'Arms', 'description': 'Narrow grip bench press'},
      {'name': 'Tricep Dips', 'category': 'Arms', 'description': 'Parallel bar or bench dips'},
      {'name': 'Overhead Tricep Extension', 'category': 'Arms', 'description': 'Seated overhead extension'},
      {'name': 'Lying Tricep Extension', 'category': 'Arms', 'description': 'Skull crushers'},
      {'name': 'Tricep Pushdowns', 'category': 'Arms', 'description': 'Cable tricep pushdowns'},
      {'name': 'Diamond Push-ups', 'category': 'Arms', 'description': 'Close grip push-ups'},
      {'name': 'Kickbacks', 'category': 'Arms', 'description': 'Dumbbell tricep kickbacks'},
      
      // Core Exercises
      {'name': 'Plank', 'category': 'Core', 'description': 'Standard plank hold'},
      {'name': 'Side Plank', 'category': 'Core', 'description': 'Lateral plank hold'},
      {'name': 'Crunches', 'category': 'Core', 'description': 'Basic abdominal crunches'},
      {'name': 'Bicycle Crunches', 'category': 'Core', 'description': 'Alternating bicycle motion'},
      {'name': 'Russian Twists', 'category': 'Core', 'description': 'Seated torso rotations'},
      {'name': 'Mountain Climbers', 'category': 'Core', 'description': 'Dynamic plank movement'},
      {'name': 'Dead Bug', 'category': 'Core', 'description': 'Lying core stability exercise'},
      {'name': 'Hanging Leg Raises', 'category': 'Core', 'description': 'Hanging knee/leg raises'},
      {'name': 'Ab Wheel Rollouts', 'category': 'Core', 'description': 'Ab wheel exercise'},
      {'name': 'Leg Raises', 'category': 'Core', 'description': 'Lying leg raises'},
      {'name': 'Sit-ups', 'category': 'Core', 'description': 'Full sit-up movement'},
      {'name': 'V-ups', 'category': 'Core', 'description': 'V-shaped crunch movement'},
      
      // Cardio Exercises
      {'name': 'Treadmill', 'category': 'Cardio', 'description': 'Treadmill running/walking'},
      {'name': 'Elliptical', 'category': 'Cardio', 'description': 'Elliptical machine'},
      {'name': 'Stationary Bike', 'category': 'Cardio', 'description': 'Exercise bike'},
      {'name': 'Rowing Machine', 'category': 'Cardio', 'description': 'Indoor rowing'},
      {'name': 'Stair Climber', 'category': 'Cardio', 'description': 'Stair climbing machine'},
      {'name': 'Burpees', 'category': 'Cardio', 'description': 'Full body burpee exercise'},
      {'name': 'Jumping Jacks', 'category': 'Cardio', 'description': 'Jumping jack exercise'},
      {'name': 'High Knees', 'category': 'Cardio', 'description': 'High knee running in place'},
      {'name': 'Jump Rope', 'category': 'Cardio', 'description': 'Skipping rope exercise'},
      
      // Functional/Olympic Exercises
      {'name': 'Clean and Press', 'category': 'Olympic', 'description': 'Olympic clean and press'},
      {'name': 'Snatch', 'category': 'Olympic', 'description': 'Olympic snatch lift'},
      {'name': 'Clean and Jerk', 'category': 'Olympic', 'description': 'Olympic clean and jerk'},
      {'name': 'Thrusters', 'category': 'Functional', 'description': 'Squat to overhead press'},
      {'name': 'Turkish Get-ups', 'category': 'Functional', 'description': 'Full body get-up movement'},
      {'name': 'Farmers Walk', 'category': 'Functional', 'description': 'Heavy carry exercise'},
      {'name': 'Battle Ropes', 'category': 'Functional', 'description': 'Heavy rope training'},
      {'name': 'Kettlebell Swings', 'category': 'Functional', 'description': 'Hip hinge kettlebell movement'},
      {'name': 'Box Jumps', 'category': 'Functional', 'description': 'Plyometric box jumps'},
      
      // Stretching/Mobility
      {'name': 'Foam Rolling', 'category': 'Mobility', 'description': 'Self-myofascial release'},
      {'name': 'Hip Flexor Stretch', 'category': 'Mobility', 'description': 'Hip flexor stretching'},
      {'name': 'Hamstring Stretch', 'category': 'Mobility', 'description': 'Hamstring flexibility'},
      {'name': 'Shoulder Stretch', 'category': 'Mobility', 'description': 'Shoulder mobility work'},
      {'name': 'Cat-Cow Stretch', 'category': 'Mobility', 'description': 'Spinal mobility exercise'},
    ];

    for (final exercise in exercises) {
      await db.insert('exercises', exercise);
    }
  }

  Future _insertDefaultAchievements(Database db) async {
    final achievements = [
      {'name': 'First Workout', 'description': 'Complete your first workout', 'icon': '🏋️'},
      {'name': 'Week Warrior', 'description': 'Work out 7 days in a row', 'icon': '🔥'},
      {'name': 'Century Club', 'description': 'Complete 100 workouts', 'icon': '💯'},
      {'name': 'Heavy Lifter', 'description': 'Lift over 100kg in any exercise', 'icon': '💪'},
    ];

    for (final achievement in achievements) {
      await db.insert('achievements', achievement);
    }
  }

  // Exercise operations
  Future<List<Exercise>> getExercises() async {
    final db = await instance.database;
    final result = await db.query('exercises');
    return result.map((json) => Exercise.fromMap(json)).toList();
  }

  Future<int> insertExercise(Exercise exercise) async {
    final db = await instance.database;
    return await db.insert('exercises', exercise.toMap());
  }

  // Workout operations
  Future<int> insertWorkout(Workout workout) async {
    final db = await instance.database;
    final workoutId = await db.insert('workouts', workout.toMap());
    
    // Insert workout exercises and sets
    for (final workoutExercise in workout.exercises) {
      final workoutExerciseId = await db.insert('workout_exercises', {
        'workout_id': workoutId,
        'exercise_id': workoutExercise.exerciseId,
      });
      
      // Insert sets for this exercise
      for (final set in workoutExercise.sets) {
        await db.insert('workout_sets', {
          'workout_exercise_id': workoutExerciseId,
          'reps': set.reps,
          'weight': set.weight,
          'duration': set.duration,
        });
      }
    }
    
    return workoutId;
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await instance.database;
    final workoutResults = await db.query('workouts', orderBy: 'date DESC');
    
    return _buildWorkoutsFromResults(workoutResults);
  }

  Future<List<Workout>> getWorkoutsLast30Days() async {
    final db = await instance.database;
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30)).toIso8601String();
    final workoutResults = await db.query(
      'workouts',
      where: 'date >= ?',
      whereArgs: [thirtyDaysAgo],
      orderBy: 'date DESC',
    );
    
    return _buildWorkoutsFromResults(workoutResults);
  }

  Future<List<Workout>> _buildWorkoutsFromResults(List<Map<String, dynamic>> workoutResults) async {
    final db = await instance.database;
    
    final workouts = <Workout>[];
    
    for (final workoutMap in workoutResults) {
      final workoutId = workoutMap['id'] as int;
      
      // Get workout exercises
      final workoutExerciseResults = await db.rawQuery('''
        SELECT we.*, e.name, e.category, e.description
        FROM workout_exercises we
        JOIN exercises e ON we.exercise_id = e.id
        WHERE we.workout_id = ?
      ''', [workoutId]);
      
      final workoutExercises = <WorkoutExercise>[];
      
      for (final weMap in workoutExerciseResults) {
        final workoutExerciseId = weMap['id'] as int;
        
        // Get sets for this exercise
        final setResults = await db.query(
          'workout_sets',
          where: 'workout_exercise_id = ?',
          whereArgs: [workoutExerciseId],
        );
        
        final sets = setResults.map((setMap) => WorkoutSet(
          id: setMap['id'] as int?,
          workoutExerciseId: setMap['workout_exercise_id'] as int,
          reps: setMap['reps'] as int,
          weight: setMap['weight'] as double?,
          duration: setMap['duration'] as int?,
        )).toList();
        
        final exercise = Exercise(
          id: weMap['exercise_id'] as int,
          name: weMap['name'] as String,
          category: weMap['category'] as String,
          description: weMap['description'] as String?,
        );
        
        workoutExercises.add(WorkoutExercise(
          id: workoutExerciseId,
          workoutId: workoutId,
          exerciseId: weMap['exercise_id'] as int,
          exercise: exercise,
          sets: sets,
        ));
      }
      
      workouts.add(Workout(
        id: workoutId,
        name: workoutMap['name'] as String,
        date: DateTime.parse(workoutMap['date'] as String),
        duration: workoutMap['duration'] as int?,
        exercises: workoutExercises,
      ));
    }
    
    return workouts;
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser() async {
    final db = await instance.database;
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await instance.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  // Body metrics operations
  Future<int> insertBodyMetric(BodyMetric metric) async {
    final db = await instance.database;
    return await db.insert('body_metrics', metric.toMap());
  }

  Future<List<BodyMetric>> getBodyMetrics() async {
    final db = await instance.database;
    final result = await db.query('body_metrics', orderBy: 'date DESC');
    return result.map((json) => BodyMetric.fromMap(json)).toList();
  }

  // Method to clear and reload exercises (useful for updates)
  Future<void> clearAndReloadExercises() async {
    final db = await instance.database;
    await db.delete('exercises');
    await _insertDefaultExercises(db);
  }

  // Method to remove inappropriate exercises
  Future<void> removeInappropriateExercises() async {
    final db = await instance.database;
    await db.delete('exercises', where: 'name = ?', whereArgs: ['fuck him']);
    await db.delete('exercises', where: 'name LIKE ?', whereArgs: ['%fuck%']);
  }

  // Method to remove duplicate exercises
  Future<void> removeDuplicateExercises() async {
    final db = await instance.database;
    await db.execute('''
      DELETE FROM exercises 
      WHERE id NOT IN (
        SELECT MIN(id) 
        FROM exercises 
        GROUP BY name, category
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
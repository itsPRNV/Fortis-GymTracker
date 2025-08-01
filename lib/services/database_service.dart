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
      version: 1,
      onCreate: _createDB,
    );
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
      {'name': 'Push-ups', 'category': 'Chest'},
      {'name': 'Squats', 'category': 'Legs'},
      {'name': 'Pull-ups', 'category': 'Back'},
      {'name': 'Bench Press', 'category': 'Chest'},
      {'name': 'Deadlift', 'category': 'Back'},
      {'name': 'Shoulder Press', 'category': 'Shoulders'},
      {'name': 'Bicep Curls', 'category': 'Arms'},
      {'name': 'Tricep Dips', 'category': 'Arms'},
      {'name': 'Lunges', 'category': 'Legs'},
      {'name': 'Plank', 'category': 'Core'},
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
    return await db.insert('workouts', workout.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await instance.database;
    final result = await db.query('workouts', orderBy: 'date DESC');
    return result.map((json) => Workout.fromMap(json)).toList();
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
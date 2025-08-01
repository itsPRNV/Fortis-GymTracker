class User {
  final int? id;
  final String name;
  final String? email;
  final String? profileImage;
  final double? currentWeight;
  final double? height;
  final double? targetWeight;
  final String? fitnessGoal;

  User({
    this.id,
    required this.name,
    this.email,
    this.profileImage,
    this.currentWeight,
    this.height,
    this.targetWeight,
    this.fitnessGoal,
  });

  double? get bmi {
    if (currentWeight != null && height != null && height! > 0) {
      return currentWeight! / ((height! / 100) * (height! / 100));
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'current_weight': currentWeight,
      'height': height,
      'target_weight': targetWeight,
      'fitness_goal': fitnessGoal,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profile_image'],
      currentWeight: map['current_weight']?.toDouble(),
      height: map['height']?.toDouble(),
      targetWeight: map['target_weight']?.toDouble(),
      fitnessGoal: map['fitness_goal'],
    );
  }
}

class BodyMetric {
  final int? id;
  final DateTime date;
  final double weight;
  final double? bodyFat;
  final double? muscleMass;

  BodyMetric({
    this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'body_fat': bodyFat,
      'muscle_mass': muscleMass,
    };
  }

  factory BodyMetric.fromMap(Map<String, dynamic> map) {
    return BodyMetric(
      id: map['id'],
      date: DateTime.parse(map['date']),
      weight: map['weight'].toDouble(),
      bodyFat: map['body_fat']?.toDouble(),
      muscleMass: map['muscle_mass']?.toDouble(),
    );
  }
}

class Achievement {
  final int? id;
  final String name;
  final String description;
  final String icon;
  final DateTime? unlockedDate;

  Achievement({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.unlockedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'unlocked_date': unlockedDate?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      unlockedDate: map['unlocked_date'] != null 
          ? DateTime.parse(map['unlocked_date']) 
          : null,
    );
  }
}
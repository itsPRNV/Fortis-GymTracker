import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  List<BodyMetric> _bodyMetrics = [];
  int _currentStreak = 0;

  User? get user => _user;
  List<BodyMetric> get bodyMetrics => _bodyMetrics;
  int get currentStreak => _currentStreak;

  UserProvider() {
    loadUser();
    loadBodyMetrics();
  }

  Future<void> loadUser() async {
    _user = await DatabaseService.instance.getUser();
    notifyListeners();
  }

  Future<void> loadBodyMetrics() async {
    _bodyMetrics = await DatabaseService.instance.getBodyMetrics();
    notifyListeners();
  }

  Future<void> createUser(String name, {String? email}) async {
    final user = User(name: name, email: email);
    await DatabaseService.instance.insertUser(user);
    await loadUser();
  }

  Future<void> updateUser(User updatedUser) async {
    await DatabaseService.instance.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> addBodyMetric(double weight, {double? bodyFat, double? muscleMass}) async {
    final metric = BodyMetric(
      date: DateTime.now(),
      weight: weight,
      bodyFat: bodyFat,
      muscleMass: muscleMass,
    );
    await DatabaseService.instance.insertBodyMetric(metric);
    await loadBodyMetrics();
  }

  void updateStreak(int streak) {
    _currentStreak = streak;
    notifyListeners();
  }
}
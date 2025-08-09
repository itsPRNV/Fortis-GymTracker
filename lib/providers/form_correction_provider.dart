import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FormCorrectionProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isEnabled = true;
  String _currentExercise = '';
  String? _lastFeedback;
  DateTime? _lastFeedbackTime;

  bool get isEnabled => _isEnabled;
  String get currentExercise => _currentExercise;

  FormCorrectionProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(0.8);
    await _flutterTts.setPitch(1.0);
  }

  void toggleFormCorrection() {
    _isEnabled = !_isEnabled;
    notifyListeners();
  }

  void setCurrentExercise(String exercise) {
    _currentExercise = exercise;
    notifyListeners();
  }

  Future<void> provideFeedback(String feedback) async {
    if (!_isEnabled || feedback.isEmpty) return;

    // Avoid repeating the same feedback too frequently
    final now = DateTime.now();
    if (_lastFeedback == feedback && 
        _lastFeedbackTime != null && 
        now.difference(_lastFeedbackTime!).inSeconds < 3) {
      return;
    }

    _lastFeedback = feedback;
    _lastFeedbackTime = now;

    try {
      await _flutterTts.speak(feedback);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class TimerProvider extends ChangeNotifier {
  // Stopwatch state
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;
  String _stopwatchTime = '00:00:00';

  // Rest timer state
  Timer? _restTimer;
  int _remainingSeconds = 60;
  int _totalSeconds = 60;
  bool _isRestTimerRunning = false;
  bool _hasTimerCompleted = false;

  TimerProvider() {
    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 100), _updateStopwatch);
  }

  // Stopwatch getters
  String get stopwatchTime => _stopwatchTime;
  bool get isStopwatchRunning => _stopwatch.isRunning;

  // Rest timer getters
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isRestTimerRunning => _isRestTimerRunning;
  bool get hasTimerCompleted => _hasTimerCompleted;
  double get restTimerProgress => _totalSeconds > 0 ? (_totalSeconds - _remainingSeconds) / _totalSeconds : 0;

  void _updateStopwatch(Timer timer) {
    if (_stopwatch.isRunning) {
      _stopwatchTime = _formatStopwatchTime(_stopwatch.elapsedMilliseconds);
      notifyListeners();
    }
  }

  String _formatStopwatchTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String formatRestTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  // Stopwatch methods
  void startStopwatch() {
    _stopwatch.start();
    notifyListeners();
  }

  void stopStopwatch() {
    _stopwatch.stop();
    notifyListeners();
  }

  void resetStopwatch() {
    _stopwatch.reset();
    _stopwatchTime = '00:00:00';
    notifyListeners();
  }

  // Rest timer methods
  void setRestTimerDuration(int seconds) {
    if (!_isRestTimerRunning) {
      _totalSeconds = seconds;
      _remainingSeconds = seconds;
      _hasTimerCompleted = false;
      notifyListeners();
    }
  }

  void startRestTimer() {
    _isRestTimerRunning = true;
    _remainingSeconds = _totalSeconds;
    _hasTimerCompleted = false;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _isRestTimerRunning = false;
        _hasTimerCompleted = true;
        timer.cancel();
        _onRestTimerComplete();
        notifyListeners();
      }
    });
  }

  void stopRestTimer() {
    _isRestTimerRunning = false;
    _hasTimerCompleted = false;
    _restTimer?.cancel();
    notifyListeners();
  }

  void resetRestTimer() {
    _isRestTimerRunning = false;
    _remainingSeconds = _totalSeconds;
    _hasTimerCompleted = false;
    _restTimer?.cancel();
    notifyListeners();
  }

  Future<void> _onRestTimerComplete() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
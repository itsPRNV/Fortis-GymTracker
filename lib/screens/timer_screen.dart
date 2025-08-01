import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stopwatch'),
            Tab(text: 'Rest Timer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StopwatchTab(),
          _RestTimerTab(),
        ],
      ),
    );
  }
}

class _StopwatchTab extends StatefulWidget {
  const _StopwatchTab();

  @override
  State<_StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<_StopwatchTab> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _timeText = '00:00:00';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _updateTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _timeText = _formatTime(_stopwatch.elapsedMilliseconds);
      });
    }
  }

  String _formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _timeText,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 64),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _stop : _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stopwatch.isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
              ),
              
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _start() {
    setState(() {
      _stopwatch.start();
    });
  }

  void _stop() {
    setState(() {
      _stopwatch.stop();
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _timeText = '00:00:00';
    });
  }
}

class _RestTimerTab extends StatefulWidget {
  const _RestTimerTab();

  @override
  State<_RestTimerTab> createState() => _RestTimerTabState();
}

class _RestTimerTabState extends State<_RestTimerTab> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 60;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _remainingSeconds = _totalSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isRunning = false;
          timer.cancel();
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
      _timer?.cancel();
    });
  }

  void _onTimerComplete() async {
    // Vibrate when timer completes
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rest Complete!'),
          content: const Text('Time to get back to your workout!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Time presets
          Text(
            'Quick Set',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PresetButton(
                label: '30s',
                seconds: 30,
                isSelected: _totalSeconds == 30,
                onTap: () => setState(() => _totalSeconds = 30),
              ),
              _PresetButton(
                label: '60s',
                seconds: 60,
                isSelected: _totalSeconds == 60,
                onTap: () => setState(() => _totalSeconds = 60),
              ),
              _PresetButton(
                label: '90s',
                seconds: 90,
                isSelected: _totalSeconds == 90,
                onTap: () => setState(() => _totalSeconds = 90),
              ),
              _PresetButton(
                label: '2m',
                seconds: 120,
                isSelected: _totalSeconds == 120,
                onTap: () => setState(() => _totalSeconds = 120),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Timer display
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _totalSeconds > 0 ? (_totalSeconds - _remainingSeconds) / _totalSeconds : 0,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              Column(
                children: [
                  Text(
                    _formatTime(_isRunning ? _remainingSeconds : _totalSeconds),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isRunning)
                    Text(
                      'Rest Time',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(_isRunning ? 'Stop' : 'Start'),
              ),
              
              ElevatedButton(
                onPressed: _resetTimer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final int seconds;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.seconds,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
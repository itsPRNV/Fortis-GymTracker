import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/tab_state_provider.dart';

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
    final tabState = context.read<TabStateProvider>();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: tabState.timerTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<TabStateProvider>().setTimerTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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

class _StopwatchTab extends StatelessWidget {
  const _StopwatchTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timerProvider.stopwatchTime,
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
                    onPressed: timerProvider.isStopwatchRunning 
                        ? timerProvider.stopStopwatch 
                        : timerProvider.startStopwatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerProvider.isStopwatchRunning ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(timerProvider.isStopwatchRunning ? 'Stop' : 'Start'),
                  ),
                  
                  ElevatedButton(
                    onPressed: timerProvider.resetStopwatch,
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
      },
    );
  }
}

class _RestTimerTab extends StatelessWidget {
  const _RestTimerTab();

  void _onTimerComplete(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rest Complete!'),
        content: const Text('Time to get back to your workout!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              timerProvider.resetRestTimer();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        // Show dialog when timer completes
        if (timerProvider.hasTimerCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onTimerComplete(context, timerProvider);
          });
        }

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
                    isSelected: timerProvider.totalSeconds == 30,
                    onTap: () => timerProvider.setRestTimerDuration(30),
                  ),
                  _PresetButton(
                    label: '60s',
                    seconds: 60,
                    isSelected: timerProvider.totalSeconds == 60,
                    onTap: () => timerProvider.setRestTimerDuration(60),
                  ),
                  _PresetButton(
                    label: '90s',
                    seconds: 90,
                    isSelected: timerProvider.totalSeconds == 90,
                    onTap: () => timerProvider.setRestTimerDuration(90),
                  ),
                  _PresetButton(
                    label: '2m',
                    seconds: 120,
                    isSelected: timerProvider.totalSeconds == 120,
                    onTap: () => timerProvider.setRestTimerDuration(120),
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
                      value: timerProvider.restTimerProgress,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        timerProvider.formatRestTime(
                          timerProvider.isRestTimerRunning 
                              ? timerProvider.remainingSeconds 
                              : timerProvider.totalSeconds
                        ),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (timerProvider.isRestTimerRunning)
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
                    onPressed: timerProvider.isRestTimerRunning 
                        ? timerProvider.stopRestTimer 
                        : timerProvider.startRestTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerProvider.isRestTimerRunning ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(timerProvider.isRestTimerRunning ? 'Stop' : 'Start'),
                  ),
                  
                  ElevatedButton(
                    onPressed: timerProvider.resetRestTimer,
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
      },
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
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
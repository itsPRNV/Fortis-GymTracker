import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/tab_state_provider.dart';
import 'exercise_tracking_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabState = context.read<TabStateProvider>();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: tabState.progressTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<TabStateProvider>().setProgressTabIndex(_tabController.index);
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
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Exercise Tracking',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExerciseTrackingScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Workouts'),
            Tab(text: 'Body Metrics'),
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _WorkoutProgressTab(),
          _BodyMetricsTab(),
          _AchievementsTab(),
        ],
      ),
    );
  }
}

class _WorkoutProgressTab extends StatelessWidget {
  const _WorkoutProgressTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final workouts = workoutProvider.workouts;
        
        // Generate weekly workout data
        final weeklyData = _generateWeeklyWorkoutData(workouts);
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Workouts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: weeklyData.values.isEmpty ? 10 : weeklyData.values.reduce((a, b) => a > b ? a : b) + 2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            return Text(days[value.toInt() % 7]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: const SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: weeklyData.entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: Theme.of(context).primaryColor,
                            width: 20,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Recent Workouts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Card(
                      child: ListTile(
                        title: Text(workout.name),
                        subtitle: Text(
                          '${workout.date.day}/${workout.date.month}/${workout.date.year} • ${workout.exercises.length} exercises',
                        ),
                        trailing: Text('${workout.duration ?? 0} min'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<int, double> _generateWeeklyWorkoutData(List<dynamic> workouts) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final data = <int, double>{};
    
    for (int i = 0; i < 7; i++) {
      data[i] = 0;
    }
    
    for (final workout in workouts) {
      final workoutDate = workout.date;
      if (workoutDate.isAfter(weekStart) && workoutDate.isBefore(now.add(const Duration(days: 1)))) {
        final dayIndex = workoutDate.weekday - 1;
        data[dayIndex] = (data[dayIndex] ?? 0) + 1;
      }
    }
    
    return data;
  }
}

class _BodyMetricsTab extends StatelessWidget {
  const _BodyMetricsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final metrics = userProvider.bodyMetrics;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weight Progress',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddMetricDialog(context),
                    child: const Text('Add Entry'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (metrics.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < metrics.length) {
                                final date = metrics[value.toInt()].date;
                                return Text('${date.day}/${date.month}');
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: const SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: metrics.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.weight);
                          }).toList(),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              
              // Current stats
              if (userProvider.user != null) ...[
                Text(
                  'Current Stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Weight',
                        value: userProvider.user!.currentWeight?.toStringAsFixed(1) ?? '-',
                        unit: 'kg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'BMI',
                        value: userProvider.user!.bmi?.toStringAsFixed(1) ?? '-',
                        unit: '',
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: metrics.length,
                  itemBuilder: (context, index) {
                    final metric = metrics[index];
                    return Card(
                      child: ListTile(
                        title: Text('${metric.weight.toStringAsFixed(1)} kg'),
                        subtitle: Text(
                          '${metric.date.day}/${metric.date.month}/${metric.date.year}',
                        ),
                        trailing: metric.bodyFat != null
                            ? Text('${metric.bodyFat!.toStringAsFixed(1)}% BF')
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMetricDialog(BuildContext context) {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Body Metric'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bodyFatController,
              decoration: const InputDecoration(labelText: 'Body Fat % (optional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final bodyFat = double.tryParse(bodyFatController.text);
              
              if (weight != null) {
                context.read<UserProvider>().addBodyMetric(weight, bodyFat: bodyFat);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _AchievementCard(
            icon: '🏋️',
            title: 'First Workout',
            description: 'Complete your first workout',
            isUnlocked: true,
          ),
          _AchievementCard(
            icon: '🔥',
            title: 'Week Warrior',
            description: 'Work out 7 days in a row',
            isUnlocked: false,
          ),
          _AchievementCard(
            icon: '💯',
            title: 'Century Club',
            description: 'Complete 100 workouts',
            isUnlocked: false,
          ),
          _AchievementCard(
            icon: '💪',
            title: 'Heavy Lifter',
            description: 'Lift over 100kg in any exercise',
            isUnlocked: false,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: value,
                style: Theme.of(context).textTheme.headlineMedium,
                children: [
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(
          icon,
          style: TextStyle(
            fontSize: 32,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}
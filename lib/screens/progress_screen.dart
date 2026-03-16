import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tab_state_provider.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fortis_ui.dart';
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
    return FortisScaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart_rounded),
            tooltip: 'Exercise Tracking',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExerciseTrackingScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: AppTheme.accentGradient()),
          ),
          indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
          tabs: const [
            Tab(text: 'Workouts'),
            Tab(text: 'Body'),
            Tab(text: 'Wins'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: TabBarView(
          controller: _tabController,
          children: const [
            _WorkoutProgressTab(),
            _BodyMetricsTab(),
            _AchievementsTab(),
          ],
        ),
      ),
    );
  }
}

class _WorkoutProgressTab extends StatefulWidget {
  const _WorkoutProgressTab();

  @override
  State<_WorkoutProgressTab> createState() => _WorkoutProgressTabState();
}

class _WorkoutProgressTabState extends State<_WorkoutProgressTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final workouts = workoutProvider.workouts;
        final weeklyData = _generateWeeklyWorkoutData(workouts);
        final totalMinutes = workouts.fold<int>(0, (sum, workout) => sum + (workout.duration ?? 0));

        return ListView(
          children: [
            FortisCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FortisSectionHeader(
                    title: 'Weekly volume',
                    subtitle: 'Your sessions across the current week.',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyData.values.isEmpty ? 4 : weeklyData.values.reduce((a, b) => a > b ? a : b) + 1,
                        barTouchData: BarTouchData(enabled: true),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Theme.of(context).dividerColor,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(days[value.toInt() % 7]),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
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
                                width: 18,
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: AppTheme.accentGradient()),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InsightTile(
                    title: 'Sessions',
                    value: '${workouts.length}',
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightTile(
                    title: 'Minutes',
                    value: '$totalMinutes',
                    color: AppTheme.accentSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const FortisSectionHeader(
              title: 'Recent workouts',
              subtitle: 'A quick recap of your latest training blocks.',
            ),
            const SizedBox(height: 12),
            if (workouts.isEmpty)
              const FortisEmptyState(
                icon: Icons.insights_rounded,
                title: 'No workout data yet',
                subtitle: 'Complete a session and your progress story will start here.',
              )
            else
              ...workouts.map((workout) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FortisCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppTheme.accent.withOpacity(0.14),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: AppTheme.accent),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${workout.date.day}/${workout.date.month}/${workout.date.year} - ${workout.exercises.length} exercises',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${workout.duration ?? 0} min',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.accentSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Map<int, double> _generateWeeklyWorkoutData(List<dynamic> workouts) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final data = <int, double>{};

    for (int i = 0; i < 7; i++) {
      data[i] = 0;
    }

    for (final workout in workouts) {
      final workoutDate = DateTime(workout.date.year, workout.date.month, workout.date.day);
      final daysDiff = workoutDate.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        data[daysDiff] = (data[daysDiff] ?? 0) + 1;
      }
    }

    return data;
  }
}

class _BodyMetricsTab extends StatefulWidget {
  const _BodyMetricsTab();

  @override
  State<_BodyMetricsTab> createState() => _BodyMetricsTabState();
}

class _BodyMetricsTabState extends State<_BodyMetricsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
      context.read<UserProvider>().loadBodyMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final metrics = userProvider.bodyMetrics;

        return ListView(
          children: [
            FortisCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FortisSectionHeader(
                    title: 'Weight trend',
                    subtitle: 'Track body changes over time.',
                    trailing: ElevatedButton(
                      onPressed: () => _showAddMetricDialog(context),
                      child: const Text('Add entry'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (metrics.isEmpty)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: Text('Add a body metric to start charting progress.'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).dividerColor,
                              strokeWidth: 1,
                            ),
                            drawVerticalLine: false,
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < metrics.length) {
                                    final date = metrics[value.toInt()].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text('${date.day}/${date.month}'),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: metrics.asMap().entries.map((entry) {
                                return FlSpot(entry.key.toDouble(), entry.value.weight);
                              }).toList(),
                              isCurved: true,
                              gradient: LinearGradient(colors: AppTheme.accentGradient()),
                              barWidth: 4,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (userProvider.user != null)
              Row(
                children: [
                  Expanded(
                    child: _InsightTile(
                      title: 'Weight',
                      value: '${userProvider.user!.currentWeight?.toStringAsFixed(1) ?? '-'} kg',
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InsightTile(
                      title: 'BMI',
                      value: userProvider.user!.bmi?.toStringAsFixed(1) ?? '-',
                      color: AppTheme.accentSecondary,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const FortisSectionHeader(
              title: 'Entries',
              subtitle: 'Recent body metrics and body-fat logs.',
            ),
            const SizedBox(height: 12),
            if (metrics.isEmpty)
              const FortisEmptyState(
                icon: Icons.monitor_weight_rounded,
                title: 'No body metrics yet',
                subtitle: 'Log your weight to make this tab useful and motivating.',
              )
            else
              ...metrics.map((metric) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FortisCard(
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppTheme.accentGold.withOpacity(0.16),
                          ),
                          child: const Icon(Icons.monitor_weight_rounded, color: AppTheme.accentGold),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${metric.weight.toStringAsFixed(1)} kg',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${metric.date.day}/${metric.date.month}/${metric.date.year}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (metric.bodyFat != null)
                          FortisBadge(
                            label: '${metric.bodyFat!.toStringAsFixed(1)}% BF',
                            color: AppTheme.accent,
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
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
            const SizedBox(height: 12),
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
    return ListView(
      children: const [
        _AchievementCard(
          icon: Icons.workspace_premium_rounded,
          title: 'First Workout',
          description: 'Complete your first workout',
          isUnlocked: true,
        ),
        SizedBox(height: 12),
        _AchievementCard(
          icon: Icons.local_fire_department_rounded,
          title: 'Week Warrior',
          description: 'Work out 7 days in a row',
          isUnlocked: false,
        ),
        SizedBox(height: 12),
        _AchievementCard(
          icon: Icons.emoji_events_rounded,
          title: 'Century Club',
          description: 'Complete 100 workouts',
          isUnlocked: false,
        ),
        SizedBox(height: 12),
        _AchievementCard(
          icon: Icons.fitness_center_rounded,
          title: 'Heavy Lifter',
          description: 'Lift over 100kg in any exercise',
          isUnlocked: false,
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InsightTile({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FortisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
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
    final color = isUnlocked ? AppTheme.accentSecondary : Theme.of(context).colorScheme.outline;

    return FortisCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: color.withOpacity(0.14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isUnlocked ? null : Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnlocked
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.68)
                            : Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: isUnlocked ? Colors.green : Theme.of(context).colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

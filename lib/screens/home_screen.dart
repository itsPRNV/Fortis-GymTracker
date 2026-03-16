import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import 'workout_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'timer_screen.dart';

import 'workout_history_screen.dart';
import 'calendar_screen.dart';
import 'exercise_tracking_screen.dart';
import 'template_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/fortis_ui.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TemplateScreen(),
    const CalendarScreen(),
    const ProgressScreen(),
    const TimerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FortisScaffold(
      appBar: AppBar(
        title: const Text('Fortis'),
        leading: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: themeProvider.toggleTheme,
            );
          },
        ),
      ),
      body: Consumer2<WorkoutProvider, UserProvider>(
        builder: (context, workoutProvider, userProvider, child) {
          final user = userProvider.user;
          final activeWorkout = workoutProvider.currentWorkout;
          final totalExercises = workoutProvider.workouts.fold<int>(
            0,
            (sum, workout) => sum + workout.exercises.length,
          );

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: ListView(
              children: [
                FortisCard(
                  gradient: [
                    AppTheme.accent.withOpacity(0.92),
                    const Color(0xFFFF8A7A),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user == null ? 'Train with intent.' : 'Welcome back, ${user.name.split(' ').first}.',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeWorkout != null
                            ? 'Your ${activeWorkout.name} session is ready to continue.'
                            : 'Build a plan, hit your sets, and keep the momentum rolling.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.86),
                            ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _HeroMetric(
                            label: 'Workouts',
                            value: '${workoutProvider.workouts.length}',
                          ),
                          _HeroMetric(
                            label: 'Streak',
                            value: '${userProvider.currentStreak} days',
                          ),
                          _HeroMetric(
                            label: 'Exercises',
                            value: '$totalExercises logged',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const FortisSectionHeader(
                  title: 'Quick pulse',
                  subtitle: 'Snapshot of the progress you have already built.',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total workouts',
                        value: '${workoutProvider.workouts.length}',
                        icon: Icons.fitness_center,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Current streak',
                        value: '${userProvider.currentStreak}',
                        icon: Icons.local_fire_department,
                        color: AppTheme.accentSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FortisSectionHeader(
                  title: 'Launchpad',
                  subtitle: 'Shortcuts for the screens you reach for most.',
                ),
                const SizedBox(height: 14),
                if (workoutProvider.isWorkoutActive)
                  _ActionCard(
                    icon: Icons.play_circle_fill_rounded,
                    title: 'Resume Workout',
                    subtitle: workoutProvider.currentWorkout!.name,
                    color: AppTheme.accentSecondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                    ),
                  )
                else
                  _ActionCard(
                    icon: Icons.add_circle_rounded,
                    title: 'Start New Workout',
                    subtitle: 'Kick off a fresh session with one tap',
                    color: AppTheme.accent,
                    onTap: () => _showStartWorkoutDialog(context),
                  ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.show_chart_rounded,
                  title: 'Exercise Tracking',
                  subtitle: 'Dig into charts, volume, and movement trends',
                  color: AppTheme.accentGold,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExerciseTrackingScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.history_rounded,
                  title: 'Workout History',
                  subtitle: 'Review past sessions and spot consistency',
                  color: const Color(0xFF7C8CFF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.bookmark_rounded,
                  title: 'Workout Templates',
                  subtitle: 'Create repeatable training blocks that save time',
                  color: const Color(0xFF3AA0FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TemplateScreen()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStartWorkoutDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Workout'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Workout Name',
            hintText: 'e.g., Push Day, Leg Day',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<WorkoutProvider>().startWorkout(controller.text);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                );
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FortisCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.22),
                  color.withOpacity(0.08),
                ],
              ),
            ),
            child: Icon(icon, size: 26, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
            ),
            child: Icon(Icons.arrow_forward_rounded, size: 18, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FortisCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(0.14),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.72),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

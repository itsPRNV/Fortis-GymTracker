import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/template_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fortis_ui.dart';
import 'create_template_screen.dart';
import 'workout_history_screen.dart';
import 'workout_screen.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FortisScaffold(
      appBar: AppBar(
        title: const Text('Fortis'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
            child: ListView(
              children: [
                FortisCard(
                  gradient: [
                    Theme.of(context).cardColor.withOpacity(0.98),
                    Theme.of(context).cardColor.withOpacity(0.82),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FortisSectionHeader(
                        title: 'Workout templates',
                        subtitle: 'Save your best splits and spin them up faster.',
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          FortisBadge(
                            label: '${templateProvider.templates.length}/3 saved',
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              templateProvider.canCreateTemplate
                                  ? 'You still have room for another routine.'
                                  : 'You have reached the current template cap.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                          ),
                          icon: const Icon(Icons.history_rounded),
                          label: const Text('Open workout history'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(
                              color: AppTheme.accentSecondary.withOpacity(0.35),
                            ),
                            foregroundColor: AppTheme.accentSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: templateProvider.canCreateTemplate
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CreateTemplateScreen(),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create template'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const FortisSectionHeader(
                  title: 'Library',
                  subtitle: 'Your saved sessions, ready whenever you are.',
                ),
                const SizedBox(height: 14),
                if (templateProvider.templates.isEmpty)
                  const FortisEmptyState(
                    icon: Icons.fitness_center_rounded,
                    title: 'No templates yet',
                    subtitle: 'Create your first repeatable workout and keep your setup friction low.',
                  )
                else
                  ...templateProvider.templates.map((template) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: FortisCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    template.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'use',
                                      child: Row(
                                        children: [
                                          Icon(Icons.play_arrow_rounded),
                                          SizedBox(width: 8),
                                          Text('Start workout'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'use') {
                                      final workoutProvider = context.read<WorkoutProvider>();
                                      final workout = templateProvider.createWorkoutFromTemplate(template);
                                      workoutProvider.startWorkoutFromTemplate(workout);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                                      );
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(context, template, templateProvider);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                FortisBadge(
                                  label: '${template.exercises.length} exercises',
                                  color: AppTheme.accentSecondary,
                                ),
                                FortisBadge(
                                  label: 'Created ${_formatDate(template.createdAt)}',
                                  color: AppTheme.accentGold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context, dynamic template, TemplateProvider templateProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await templateProvider.deleteTemplate(template.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

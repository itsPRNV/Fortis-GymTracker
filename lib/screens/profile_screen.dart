import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fortis_ui.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FortisScaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) {
            return const _CreateProfileView();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Current',
                      value: user.currentWeight?.toStringAsFixed(1) ?? '-',
                      unit: 'kg',
                      icon: Icons.monitor_weight_rounded,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Target',
                      value: user.targetWeight?.toStringAsFixed(1) ?? '-',
                      unit: 'kg',
                      icon: Icons.flag_rounded,
                      color: AppTheme.accentSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Height',
                      value: user.height?.toStringAsFixed(0) ?? '-',
                      unit: 'cm',
                      icon: Icons.height_rounded,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'BMI',
                      value: user.bmi?.toStringAsFixed(1) ?? '-',
                      unit: '',
                      icon: Icons.insights_rounded,
                      color: const Color(0xFF7C8CFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FortisCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppTheme.accentGold.withOpacity(0.14),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: AppTheme.accentGold),
                  ),
                  title: const Text('Fitness Goal'),
                  subtitle: Text(user.fitnessGoal ?? 'Not set'),
                  trailing: const Icon(Icons.edit_rounded),
                  onTap: () => _showEditGoalDialog(context, user),
                ),
              ),
              const SizedBox(height: 16),
              FortisCard(
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.edit_outlined,
                      title: 'Edit profile',
                      subtitle: 'Update your personal details and targets',
                      onTap: () => _showEditProfileDialog(context, user),
                    ),
                    Divider(color: Theme.of(context).dividerColor),
                    _ActionRow(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Health data sync',
                      subtitle: 'Connect to Google Fit or Apple Health',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) => _showHealthSyncDialog(context),
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerColor),
                    _ActionRow(
                      icon: Icons.backup_outlined,
                      title: 'Backup data',
                      subtitle: 'Keep your workouts safe and portable',
                      onTap: () => _showBackupDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email ?? '');
    final weightController = TextEditingController(text: user.currentWeight?.toString() ?? '');
    final heightController = TextEditingController(text: user.height?.toString() ?? '');
    final targetWeightController = TextEditingController(text: user.targetWeight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Current Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetWeightController,
                decoration: const InputDecoration(labelText: 'Target Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedUser = User(
                id: user.id,
                name: nameController.text,
                email: emailController.text.isEmpty ? null : emailController.text,
                profileImage: user.profileImage,
                currentWeight: double.tryParse(weightController.text),
                height: double.tryParse(heightController.text),
                targetWeight: double.tryParse(targetWeightController.text),
                fitnessGoal: user.fitnessGoal,
              );
              context.read<UserProvider>().updateUser(updatedUser);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, User user) {
    final goals = [
      'Lose Weight',
      'Gain Muscle',
      'Maintain Weight',
      'Improve Strength',
      'Improve Endurance',
      'General Fitness',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Fitness Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) {
            return RadioListTile<String>(
              title: Text(goal),
              value: goal,
              groupValue: user.fitnessGoal,
              onChanged: (value) {
                final updatedUser = User(
                  id: user.id,
                  name: user.name,
                  email: user.email,
                  profileImage: user.profileImage,
                  currentWeight: user.currentWeight,
                  height: user.height,
                  targetWeight: user.targetWeight,
                  fitnessGoal: value,
                );
                context.read<UserProvider>().updateUser(updatedUser);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHealthSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Data Sync'),
        content: const Text(
          'This feature would connect to Google Fit or Apple Health to sync your health data. '
          'Implementation requires platform-specific setup and permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'This feature would allow you to backup your workout data to cloud storage. '
          'Implementation requires cloud storage integration.',
        ),
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

class _CreateProfileView extends StatelessWidget {
  const _CreateProfileView();

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Center(
        child: FortisCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.14),
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, size: 34, color: AppTheme.accent),
              ),
              const SizedBox(height: 16),
              Text(
                'Create your profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your identity once and Fortis will personalize the rest.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email (optional)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      context.read<UserProvider>().createUser(
                            nameController.text,
                            email: emailController.text.isEmpty ? null : emailController.text,
                          );
                    }
                  },
                  child: const Text('Create profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return FortisCard(
      gradient: [
        Theme.of(context).cardColor.withOpacity(0.98),
        Theme.of(context).cardColor.withOpacity(0.82),
      ],
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppTheme.accent.withOpacity(0.14),
                  backgroundImage: user.profileImage != null ? FileImage(File(user.profileImage!)) : null,
                  child: user.profileImage == null
                      ? const Icon(Icons.person_rounded, size: 44, color: AppTheme.accent)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: AppTheme.accentGradient()),
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            user.email ?? 'No email added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (user.fitnessGoal != null)
                FortisBadge(label: user.fitnessGoal!, color: AppTheme.accentSecondary),
              FortisBadge(
                label: user.currentWeight != null ? '${user.currentWeight!.toStringAsFixed(1)} kg current' : 'Weight not set',
                color: AppTheme.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        profileImage: image.path,
        currentWeight: user.currentWeight,
        height: user.height,
        targetWeight: user.targetWeight,
        fitnessGoal: user.fitnessGoal,
      );
      if (context.mounted) {
        context.read<UserProvider>().updateUser(updatedUser);
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FortisCard(
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
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              text: value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              children: [
                TextSpan(
                  text: unit.isEmpty ? '' : ' $unit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.accent.withOpacity(0.12),
        ),
        child: Icon(icon, color: AppTheme.accent),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.arrow_forward_rounded),
    );
  }
}

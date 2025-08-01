import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_provider.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          
          if (user == null) {
            return const _CreateProfileView();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _ProfileHeader(user: user),
                const SizedBox(height: 32),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Current Weight',
                        value: user.currentWeight?.toStringAsFixed(1) ?? '-',
                        unit: 'kg',
                        icon: Icons.monitor_weight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Target Weight',
                        value: user.targetWeight?.toStringAsFixed(1) ?? '-',
                        unit: 'kg',
                        icon: Icons.flag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Height',
                        value: user.height?.toStringAsFixed(0) ?? '-',
                        unit: 'cm',
                        icon: Icons.height,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'BMI',
                        value: user.bmi?.toStringAsFixed(1) ?? '-',
                        unit: '',
                        icon: Icons.analytics,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Fitness Goal
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Fitness Goal'),
                    subtitle: Text(user.fitnessGoal ?? 'Not set'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditGoalDialog(context, user),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showEditProfileDialog(context, user),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.health_and_safety),
                        title: const Text('Health Data Sync'),
                        subtitle: const Text('Connect to Google Fit / Apple Health'),
                        trailing: Switch(
                          value: false,
                          onChanged: (value) => _showHealthSyncDialog(context),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.backup),
                        title: const Text('Backup Data'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showBackupDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Reload Exercise Database'),
                        subtitle: const Text('Update to latest exercise collection'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showReloadExercisesDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        themeProvider.setThemeMode(mode);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Current Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
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

  void _showReloadExercisesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reload Exercise Database'),
        content: const Text(
          'This will reload the exercise database with the latest collection of exercises. '
          'Your custom exercises will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Reloading exercises...'),
                    ],
                  ),
                ),
              );
              
              try {
                await context.read<WorkoutProvider>().reloadExercisesDatabase();
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exercise database reloaded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error reloading exercises: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Reload'),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Create Your Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<UserProvider>().createUser(
                  nameController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                );
              }
            },
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(context),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: user.profileImage != null
                ? FileImage(File(user.profileImage!))
                : null,
            child: user.profileImage == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (user.email != null)
          Text(
            user.email!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
      ],
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: value,
                style: Theme.of(context).textTheme.headlineSmall,
                children: [
                  TextSpan(
                    text: ' $unit',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
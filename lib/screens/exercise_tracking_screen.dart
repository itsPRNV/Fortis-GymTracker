import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../models/exercise.dart';

class ExerciseTrackingScreen extends StatefulWidget {
  const ExerciseTrackingScreen({super.key});

  @override
  State<ExerciseTrackingScreen> createState() => _ExerciseTrackingScreenState();
}

class _ExerciseTrackingScreenState extends State<ExerciseTrackingScreen> {
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  Exercise? _selectedExercise;
  List<ExerciseProgress> _progressData = [];
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'Name';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    final exercises = await DatabaseService.instance.getExercises();
    setState(() {
      _allExercises = exercises;
      _filteredExercises = exercises;
      _isLoading = false;
    });
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        final matchesSearch = exercise.name.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || exercise.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
      
      _sortExercises();
    });
  }

  void _sortExercises() {
    _filteredExercises.sort((a, b) {
      switch (_sortBy) {
        case 'Name':
          return a.name.compareTo(b.name);
        case 'Category':
          return a.category.compareTo(b.category);
        default:
          return a.name.compareTo(b.name);
      }
    });
  }

  Future<void> _loadExerciseProgress(Exercise exercise) async {
    setState(() => _isLoading = true);
    final progress = await DatabaseService.instance.getExerciseProgress(exercise.id!);
    setState(() {
      _selectedExercise = exercise;
      _progressData = progress;
      _isLoading = false;
    });
  }

  List<String> get _categories {
    final categories = _allExercises.map((e) => e.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Tracking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and filter bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search exercises...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter and sort row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                                _filterExercises();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _sortBy,
                              decoration: const InputDecoration(
                                labelText: 'Sort by',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: ['Name', 'Category'].map((sort) {
                                return DropdownMenuItem(
                                  value: sort,
                                  child: Text(sort),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _sortBy = value!;
                                });
                                _filterExercises();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main content
                Expanded(
                  child: _selectedExercise == null
                      ? _ExerciseListView(
                          exercises: _filteredExercises,
                          onExerciseSelected: _loadExerciseProgress,
                        )
                      : _ExerciseProgressView(
                          exercise: _selectedExercise!,
                          progressData: _progressData,
                          onBack: () => setState(() => _selectedExercise = null),
                        ),
                ),
              ],
            ),
    );
  }
}

class _ExerciseListView extends StatelessWidget {
  final List<Exercise> exercises;
  final Function(Exercise) onExerciseSelected;

  const _ExerciseListView({
    required this.exercises,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.fitness_center,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.category),
                if (exercise.description != null)
                  Text(
                    exercise.description!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () => onExerciseSelected(exercise),
          ),
        );
      },
    );
  }
}

class _ExerciseProgressView extends StatefulWidget {
  final Exercise exercise;
  final List<ExerciseProgress> progressData;
  final VoidCallback onBack;

  const _ExerciseProgressView({
    required this.exercise,
    required this.progressData,
    required this.onBack,
  });

  @override
  State<_ExerciseProgressView> createState() => _ExerciseProgressViewState();
}

class _ExerciseProgressViewState extends State<_ExerciseProgressView> {
  String _selectedMetric = 'weight';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      widget.exercise.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: widget.progressData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No data available for this exercise',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Complete workouts with this exercise to see progress',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metric selector
                      Text(
                        'Select Metric',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'weight', label: Text('Weight (kg)')),
                          ButtonSegment(value: 'reps', label: Text('Reps')),
                          ButtonSegment(value: 'duration', label: Text('Duration (s)')),
                        ],
                        selected: {_selectedMetric},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _selectedMetric = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Chart
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < widget.progressData.length) {
                                      final date = widget.progressData[value.toInt()].date;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${date.day}/${date.month}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (value, meta) {
                                    String unit = '';
                                    switch (_selectedMetric) {
                                      case 'weight':
                                        unit = 'kg';
                                        break;
                                      case 'duration':
                                        unit = 's';
                                        break;
                                    }
                                    return Text('${value.toInt()}$unit');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getSpots(),
                                isCurved: true,
                                color: _getMetricColor(),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: _getMetricColor().withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Stats summary
                      _buildStatsSummary(),
                      
                      const SizedBox(height: 24),
                      
                      // Data table
                      Text(
                        'Progress History',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildDataTable(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Weight (kg)')),
            DataColumn(label: Text('Reps')),
            DataColumn(label: Text('Duration (s)')),
          ],
          rows: widget.progressData.map((progress) {
            return DataRow(
              cells: [
                DataCell(Text('${progress.date.day}/${progress.date.month}/${progress.date.year}')),
                DataCell(Text(progress.maxWeight?.toStringAsFixed(1) ?? '-')),
                DataCell(Text(progress.maxReps.toString())),
                DataCell(Text(progress.maxDuration?.toString() ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return widget.progressData.asMap().entries.map((entry) {
      double value = 0;
      switch (_selectedMetric) {
        case 'weight':
          value = entry.value.maxWeight ?? 0;
          break;
        case 'reps':
          value = entry.value.maxReps.toDouble();
          break;
        case 'duration':
          value = (entry.value.maxDuration ?? 0).toDouble();
          break;
      }
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  Color _getMetricColor() {
    switch (_selectedMetric) {
      case 'weight':
        return Colors.blue;
      case 'reps':
        return Colors.green;
      case 'duration':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildStatsSummary() {
    if (widget.progressData.isEmpty) return const SizedBox();

    final latest = widget.progressData.last;
    final first = widget.progressData.first;

    double latestValue = 0;
    double firstValue = 0;
    String unit = '';

    switch (_selectedMetric) {
      case 'weight':
        latestValue = latest.maxWeight ?? 0;
        firstValue = first.maxWeight ?? 0;
        unit = 'kg';
        break;
      case 'reps':
        latestValue = latest.maxReps.toDouble();
        firstValue = first.maxReps.toDouble();
        unit = '';
        break;
      case 'duration':
        latestValue = (latest.maxDuration ?? 0).toDouble();
        firstValue = (first.maxDuration ?? 0).toDouble();
        unit = 's';
        break;
    }

    final improvement = latestValue - firstValue;
    final improvementPercent = firstValue > 0 ? (improvement / firstValue * 100) : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'Current',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${latestValue.toStringAsFixed(1)}$unit',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Improvement',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${improvement >= 0 ? '+' : ''}${improvement.toStringAsFixed(1)}$unit',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: improvement >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${improvementPercent >= 0 ? '+' : ''}${improvementPercent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: improvementPercent >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


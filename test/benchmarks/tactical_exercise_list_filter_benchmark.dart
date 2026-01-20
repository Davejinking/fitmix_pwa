// test/benchmarks/tactical_exercise_list_filter_benchmark.dart

import 'package:benchmark_harness/benchmark_harness.dart';

// Simulating ExerciseLibraryItem for benchmark
class ExerciseLibraryItem {
  final String id;
  final String targetPart;
  final String equipmentType;
  final String nameKr;
  final String nameEn;
  final String nameJp;

  ExerciseLibraryItem({
    required this.id,
    required this.targetPart,
    required this.equipmentType,
    required this.nameKr,
    required this.nameEn,
    required this.nameJp,
  });

  // Simulating getLocalizedName for benchmark (assuming English context)
  String getLocalizedName() {
    return nameEn;
  }
}

// Generate dummy data
List<ExerciseLibraryItem> generateExercises(int count) {
  final List<String> parts = ['chest', 'back', 'legs', 'shoulders', 'arms', 'abs', 'cardio', 'stretching', 'fullBody'];
  final List<String> equipment = ['barbell', 'dumbbell', 'machine', 'cable', 'bodyweight', 'band'];

  return List.generate(count, (index) {
    return ExerciseLibraryItem(
      id: 'ex_$index',
      targetPart: parts[index % parts.length],
      equipmentType: equipment[index % equipment.length],
      nameKr: '운동 $index',
      nameEn: 'Exercise $index',
      nameJp: '運動 $index',
    );
  });
}

// Current Implementation Benchmark
class ChainedFilterBenchmark extends BenchmarkBase {
  final List<ExerciseLibraryItem> _allExercises;
  final Set<String> _bookmarkedIds = {'ex_1', 'ex_10', 'ex_20'};

  // Filter parameters
  final String _selectedBodyPart = 'chest';
  final String? _selectedEquipmentKey = 'barbell';
  final String _searchQuery = 'exercise';

  ChainedFilterBenchmark(this._allExercises) : super('ChainedFilterBenchmark');

  @override
  void run() {
    List<ExerciseLibraryItem> filteredExercises;

    // Step 1: Body Part Filter
    if (_selectedBodyPart == 'all') {
      filteredExercises = List.from(_allExercises);
    } else if (_selectedBodyPart == 'favorites') {
      filteredExercises = _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
    } else {
      filteredExercises = _allExercises.where((ex) => ex.targetPart.toLowerCase() == _selectedBodyPart.toLowerCase()).toList();
    }

    // Step 2: Equipment Filter
    if (_selectedEquipmentKey != null) {
      filteredExercises = filteredExercises.where((ex) => ex.equipmentType.toLowerCase() == _selectedEquipmentKey!.toLowerCase()).toList();
    }

    // Step 3: Search Query Filter
    if (_searchQuery.isNotEmpty) {
      filteredExercises = filteredExercises.where((ex) => ex.getLocalizedName().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }
}

// Optimized Implementation Benchmark
class CombinedFilterBenchmark extends BenchmarkBase {
  final List<ExerciseLibraryItem> _allExercises;
  final Set<String> _bookmarkedIds = {'ex_1', 'ex_10', 'ex_20'};

  // Filter parameters
  final String _selectedBodyPart = 'chest';
  final String? _selectedEquipmentKey = 'barbell';
  final String _searchQuery = 'exercise';

  CombinedFilterBenchmark(this._allExercises) : super('CombinedFilterBenchmark');

  @override
  void run() {
    final searchLower = _searchQuery.toLowerCase();
    final equipmentLower = _selectedEquipmentKey?.toLowerCase();
    final bodyPartLower = _selectedBodyPart.toLowerCase();

    final filteredExercises = _allExercises.where((ex) {
      // Step 1: Body Part Filter
      if (_selectedBodyPart == 'favorites') {
        if (!_bookmarkedIds.contains(ex.id)) return false;
      } else if (_selectedBodyPart != 'all') {
        if (ex.targetPart.toLowerCase() != bodyPartLower) return false;
      }

      // Step 2: Equipment Filter
      if (equipmentLower != null) {
        if (ex.equipmentType.toLowerCase() != equipmentLower) return false;
      }

      // Step 3: Search Query Filter
      if (searchLower.isNotEmpty) {
        if (!ex.getLocalizedName().toLowerCase().contains(searchLower)) return false;
      }

      return true;
    }).toList();
  }
}

void main() {
  final exercises = generateExercises(5000); // 5000 items

  print('Running benchmarks with ${exercises.length} items...');
  ChainedFilterBenchmark(exercises).report();
  CombinedFilterBenchmark(exercises).report();
}


import 'package:flutter_test/flutter_test.dart';

// Mock ExerciseLibraryItem structure for benchmark
class MockExerciseLibraryItem {
  final String id;
  final String targetPart;
  final String equipmentType;
  final String name;

  MockExerciseLibraryItem({
    required this.id,
    required this.targetPart,
    required this.equipmentType,
    required this.name,
  });
}

// Logic extracted from TacticalExerciseList for benchmarking
class TacticalExerciseListLogic {
  List<MockExerciseLibraryItem> _allExercises = [];
  Set<String> _bookmarkedIds = {};
  String _selectedBodyPart = 'all';

  void setExercises(List<MockExerciseLibraryItem> exercises) {
    _allExercises = exercises;
  }

  void setBodyPart(String part) {
    _selectedBodyPart = part;
  }

  void setBookmarks(Set<String> bookmarks) {
    _bookmarkedIds = bookmarks;
  }

  // Original implementation of _bodyPartFilteredExercises
  List<MockExerciseLibraryItem> get _bodyPartFilteredExercises {
    if (_selectedBodyPart == 'all') {
      return List.from(_allExercises);
    } else if (_selectedBodyPart == 'favorites') {
      return _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
    } else {
      return _allExercises.where((ex) => ex.targetPart.toLowerCase() == _selectedBodyPart.toLowerCase()).toList();
    }
  }

  // Original implementation of _availableEquipmentKeys (The target for optimization)
  List<String> get _availableEquipmentKeys {
    return _bodyPartFilteredExercises
        .map((ex) => ex.equipmentType.toLowerCase())
        .toSet()
        .toList()
      ..sort();
  }
}

// Optimized version
class OptimizedTacticalExerciseListLogic {
  List<MockExerciseLibraryItem> _allExercises = [];
  Set<String> _bookmarkedIds = {};
  String _selectedBodyPart = 'all';

  // Cache
  List<String>? _cachedAvailableEquipmentKeys;

  void setExercises(List<MockExerciseLibraryItem> exercises) {
    _allExercises = exercises;
    _invalidateCache();
  }

  void setBodyPart(String part) {
    if (_selectedBodyPart != part) {
      _selectedBodyPart = part;
      _invalidateCache();
    }
  }

  void setBookmarks(Set<String> bookmarks) {
    _bookmarkedIds = bookmarks;
    if (_selectedBodyPart == 'favorites') {
      _invalidateCache();
    }
  }

  void _invalidateCache() {
    _cachedAvailableEquipmentKeys = null;
  }

  List<MockExerciseLibraryItem> get _bodyPartFilteredExercises {
    if (_selectedBodyPart == 'all') {
      return List.from(_allExercises);
    } else if (_selectedBodyPart == 'favorites') {
      return _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
    } else {
      return _allExercises.where((ex) => ex.targetPart.toLowerCase() == _selectedBodyPart.toLowerCase()).toList();
    }
  }

  List<String> get _availableEquipmentKeys {
    if (_cachedAvailableEquipmentKeys != null) {
      return _cachedAvailableEquipmentKeys!;
    }

    _cachedAvailableEquipmentKeys = _bodyPartFilteredExercises
        .map((ex) => ex.equipmentType.toLowerCase())
        .toSet()
        .toList()
      ..sort();

    return _cachedAvailableEquipmentKeys!;
  }
}

void main() {
  test('Benchmark _availableEquipmentKeys', () {
    // Setup data
    final exercises = List.generate(1000, (i) => MockExerciseLibraryItem(
      id: 'ex_$i',
      targetPart: i % 10 == 0 ? 'chest' : (i % 10 == 1 ? 'back' : 'legs'),
      equipmentType: i % 5 == 0 ? 'barbell' : (i % 5 == 1 ? 'dumbbell' : 'machine'),
      name: 'Exercise $i',
    ));

    final logic = TacticalExerciseListLogic();
    logic.setExercises(exercises);
    logic.setBodyPart('chest');

    final stopwatch = Stopwatch()..start();

    // Simulate multiple accesses during build/rebuilds
    // 1000 iterations to simulate 1000 frames or rebuilds
    for (int i = 0; i < 1000; i++) {
      final keys = logic._availableEquipmentKeys;
      expect(keys.length, greaterThan(0));
    }

    stopwatch.stop();
    print('Baseline time: ${stopwatch.elapsedMicroseconds}us');

    final optimizedLogic = OptimizedTacticalExerciseListLogic();
    optimizedLogic.setExercises(exercises);
    optimizedLogic.setBodyPart('chest');

    final stopwatch2 = Stopwatch()..start();

    for (int i = 0; i < 1000; i++) {
      final keys = optimizedLogic._availableEquipmentKeys;
      expect(keys.length, greaterThan(0));
    }

    stopwatch2.stop();
    print('Optimized time: ${stopwatch2.elapsedMicroseconds}us');

    final improvement = (stopwatch.elapsedMicroseconds - stopwatch2.elapsedMicroseconds) / stopwatch.elapsedMicroseconds * 100;
    print('Improvement: ${improvement.toStringAsFixed(2)}%');
  });
}

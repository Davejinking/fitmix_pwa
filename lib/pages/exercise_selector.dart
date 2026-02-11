import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';

// 🎨 Theme Colors
const Color kPrimaryBlue = Color(0xFF007AFF);
const Color kDesaturatedBlue = Color(0xFF4A6E94);
const Color kDarkBg = Color(0xFF0A0A0A);
const Color kDivider = Color(0xFF1F1F1F);
const Color kSelectedBg = Color(0xFF007AFF);

class ExerciseSelector extends StatefulWidget {
  final Set<String> initialSelectedExercises;
  
  const ExerciseSelector({
    super.key,
    this.initialSelectedExercises = const {},
  });

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  late SessionRepo repo;
  Map<String, int> exerciseCounts = {};
  Set<String> selectedExercises = {};
  bool isLoading = true;
  bool showSearch = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    repo = getIt<SessionRepo>();
    selectedExercises = Set.from(widget.initialSelectedExercises);
    _loadExercises();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final result = await repo.getAllSessionDates();
    final counts = <String, int>{};
    
    for (final ymd in result.workoutDates) {
      final session = await repo.get(ymd);
      if (session != null) {
        for (final exercise in session.exercises) {
          counts[exercise.name] = (counts[exercise.name] ?? 0) + 1;
        }
      }
    }
    
    // Sort by count descending
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final sortedCounts = Map<String, int>.fromEntries(sortedEntries);
    
    if (mounted) {
      setState(() {
        exerciseCounts = sortedCounts;
        isLoading = false;
      });
    }
  }

  void _toggleExercise(String exerciseName) {
    setState(() {
      if (selectedExercises.contains(exerciseName)) {
        selectedExercises.remove(exerciseName);
      } else {
        selectedExercises.add(exerciseName);
      }
    });
  }

  List<MapEntry<String, int>> _getFilteredExercises() {
    if (searchQuery.isEmpty) {
      return exerciseCounts.entries.toList();
    }
    
    return exerciseCounts.entries
        .where((entry) => entry.key.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? kDarkBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryBlue,
                  ),
                ),
              )
            else
              Expanded(
                child: _buildExerciseList(isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: isDark ? kDarkBg : const Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(
            color: kDivider,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, selectedExercises),
            child: Icon(
              Icons.close,
              size: 24,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Exercise',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Filter logs by exercise',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                showSearch = !showSearch;
                if (!showSearch) {
                  searchController.clear();
                  searchQuery = '';
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                showSearch ? Icons.close : Icons.search,
                size: 24,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(bool isDark) {
    final filteredExercises = _getFilteredExercises();
    
    return Column(
      children: [
        if (showSearch)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: TextField(
              controller: searchController,
              autofocus: true,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(
                  color: const Color(0xFF525252),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: kDivider,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: kDivider,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: kPrimaryBlue,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              final entry = filteredExercises[index];
              final exerciseName = entry.key;
              final count = entry.value;
              final isSelected = selectedExercises.contains(exerciseName);
              
              return _buildExerciseItem(
                exerciseName: exerciseName,
                count: count,
                isSelected: isSelected,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem({
    required String exerciseName,
    required int count,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _toggleExercise(exerciseName),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.02)
              : Colors.transparent,
        ),
        child: Stack(
          children: [
            // Left accent bar for selected items
            if (isSelected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: Container(
                  color: kSelectedBg,
                ),
              ),
            
            // Content
            Container(
              padding: EdgeInsets.fromLTRB(
                isSelected ? 24 : 24,
                16,
                24,
                16,
              ),
              decoration: BoxDecoration(
                border: isSelected ? null : Border(
                  bottom: BorderSide(
                    color: kDivider.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exerciseName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                        letterSpacing: isSelected ? 0.2 : 0,
                      ),
                    ),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kDesaturatedBlue.withValues(
                        alpha: isSelected ? 1.0 : 0.7,
                      ),
                      fontFamily: 'monospace',
                    ),
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

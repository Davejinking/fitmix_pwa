import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_library.dart';
import '../services/exercise_seeding_service.dart';
import '../l10n/app_localizations.dart';

/// Iron Log 다국어 지원 운동 선택 페이지
class ExerciseSelectionPageV2 extends StatefulWidget {
  const ExerciseSelectionPageV2({super.key});

  @override
  State<ExerciseSelectionPageV2> createState() => _ExerciseSelectionPageV2State();
}

class _ExerciseSelectionPageV2State extends State<ExerciseSelectionPageV2> {
  final List<Exercise> _selectedExercises = [];
  List<ExerciseLibraryItem> _allExercises = [];
  List<ExerciseLibraryItem> _filteredExercises = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedBodyPart = 'all';
  String _selectedEquipment = 'all';

  late ExerciseSeedingService _seedingService;

  @override
  void initState() {
    super.initState();
    _seedingService = ExerciseSeedingService();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      setState(() => _isLoading = true);
      
      // 시딩 서비스에서 운동 데이터 로드
      await _seedingService.initializeAndSeed();
      final exercises = await _seedingService.getAllExercises();
      
      if (mounted) {
        setState(() {
          _allExercises = exercises;
          _filteredExercises = exercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 운동 데이터 로드 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        // 검색어 필터
        final matchesSearch = _searchQuery.isEmpty ||
            exercise.getLocalizedName(context).toLowerCase().contains(_searchQuery.toLowerCase());
        
        // 부위 필터
        final matchesBodyPart = _selectedBodyPart == 'all' ||
            exercise.targetPart.toLowerCase() == _selectedBodyPart.toLowerCase();
        
        // 장비 필터
        final matchesEquipment = _selectedEquipment == 'all' ||
            exercise.equipmentType.toLowerCase() == _selectedEquipment.toLowerCase();
        
        return matchesSearch && matchesBodyPart && matchesEquipment;
      }).toList();
    });
  }

  void _toggleExercise(ExerciseLibraryItem libraryItem) {
    setState(() {
      final exerciseName = libraryItem.getLocalizedName(context);
      final index = _selectedExercises.indexWhere((e) => e.name == exerciseName);
      
      if (index >= 0) {
        _selectedExercises.removeAt(index);
      } else {
        _selectedExercises.add(Exercise(
          name: exerciseName,
          bodyPart: _getLocalizedBodyPart(libraryItem.targetPart),
        ));
      }
    });
  }

  bool _isSelected(ExerciseLibraryItem libraryItem) {
    final exerciseName = libraryItem.getLocalizedName(context);
    return _selectedExercises.any((e) => e.name == exerciseName);
  }

  String _getLocalizedBodyPart(String targetPart) {
    final l10n = AppLocalizations.of(context)!;
    switch (targetPart.toLowerCase()) {
      case 'chest': return l10n.chest;
      case 'back': return l10n.back;
      case 'legs': return l10n.legs;
      case 'shoulders': return l10n.shoulders;
      case 'arms': return l10n.arms;
      case 'abs': return l10n.abs;
      case 'cardio': return l10n.cardio;
      case 'stretching': return l10n.stretching;
      case 'fullbody': return l10n.fullBody;
      default: return targetPart;
    }
  }

  String _getLocalizedEquipment(String equipmentType) {
    final l10n = AppLocalizations.of(context)!;
    switch (equipmentType.toLowerCase()) {
      case 'barbell': return l10n.barbell;
      case 'dumbbell': return l10n.dumbbell;
      case 'machine': return l10n.machine;
      case 'cable': return l10n.cable;
      case 'bodyweight': return l10n.bodyweight;
      case 'band': return l10n.band;
      default: return equipmentType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          l10n.selectExercise,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedExercises.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedExercises),
              child: Text(
                '${l10n.add} (${_selectedExercises.length})',
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
          : Column(
              children: [
                // 검색 및 필터 섹션
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1E1E1E),
                  child: Column(
                    children: [
                      // 검색바
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n.searchExercise,
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterExercises();
                        },
                      ),
                      const SizedBox(height: 12),
                      // 필터 버튼들
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _selectedBodyPart,
                              items: [
                                'all',
                                'chest',
                                'back',
                                'legs',
                                'shoulders',
                                'arms',
                                'abs',
                                'cardio',
                                'stretching',
                                'fullbody',
                              ],
                              onChanged: (value) {
                                _selectedBodyPart = value!;
                                _filterExercises();
                              },
                              getLabel: (value) => value == 'all' ? l10n.all : _getLocalizedBodyPart(value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFilterDropdown(
                              value: _selectedEquipment,
                              items: [
                                'all',
                                'barbell',
                                'dumbbell',
                                'machine',
                                'cable',
                                'bodyweight',
                                'band',
                              ],
                              onChanged: (value) {
                                _selectedEquipment = value!;
                                _filterExercises();
                              },
                              getLabel: (value) => value == 'all' ? l10n.all : _getLocalizedEquipment(value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 운동 목록
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noExercises,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            final isSelected = _isSelected(exercise);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected 
                                    ? Border.all(color: const Color(0xFF2196F3), width: 2)
                                    : null,
                              ),
                              child: ListTile(
                                title: Text(
                                  exercise.getLocalizedName(context),
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${_getLocalizedBodyPart(exercise.targetPart)} • ${_getLocalizedEquipment(exercise.equipmentType)}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFF2196F3))
                                    : const Icon(Icons.add_circle_outline, color: Colors.grey),
                                onTap: () => _toggleExercise(exercise),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String Function(String) getLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              getLabel(item),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: const Color(0xFF2A2A2A),
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _seedingService.close();
    super.dispose();
  }
}
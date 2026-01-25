import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/exercise_library.dart';
import '../models/exercise.dart';
import '../services/exercise_seeding_service.dart';
import '../widgets/modals/exercise_filter_modal.dart';

/// 🔥 Tactical Exercise Selection Page - Cyberpunk/Noir Design
class ExerciseSelectionPageV2 extends StatefulWidget {
  const ExerciseSelectionPageV2({super.key});

  @override
  State<ExerciseSelectionPageV2> createState() => _ExerciseSelectionPageV2State();
}

class _ExerciseSelectionPageV2State extends State<ExerciseSelectionPageV2> {
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ExerciseLibraryItem> _allExercises = [];
  List<ExerciseLibraryItem> _filteredExercises = [];
  final List<Exercise> _selectedExercises = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  Set<String> _selectedMuscles = {};
  Set<String> _selectedEquipment = {};

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredExercises = _allExercises.where((ex) {
        // Search filter
        final matchesSearch = _searchQuery.isEmpty ||
            ex.nameEn.toLowerCase().contains(_searchQuery) ||
            ex.nameKr.toLowerCase().contains(_searchQuery) ||
            ex.targetPart.toLowerCase().contains(_searchQuery) ||
            ex.equipmentType.toLowerCase().contains(_searchQuery);

        // Muscle filter
        final matchesMuscle = _selectedMuscles.isEmpty ||
            _selectedMuscles.any((muscle) =>
                ex.targetPart.toLowerCase() == muscle.toLowerCase());

        // Equipment filter
        final matchesEquipment = _selectedEquipment.isEmpty ||
            _selectedEquipment.any((equipment) =>
                ex.equipmentType.toLowerCase() == equipment.toLowerCase());

        return matchesSearch && matchesMuscle && matchesEquipment;
      }).toList();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ExerciseFilterModal(
          selectedMuscles: _selectedMuscles,
          selectedEquipment: _selectedEquipment,
          onApply: (muscles, equipment) {
            setState(() {
              _selectedMuscles = muscles;
              _selectedEquipment = equipment;
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _toggleExercise(ExerciseLibraryItem item) {
    setState(() {
      final exercise = Exercise(
        name: item.nameEn,
        bodyPart: item.targetPart,
      );
      
      final existingIndex = _selectedExercises.indexWhere((e) => e.name == item.nameEn);
      if (existingIndex >= 0) {
        _selectedExercises.removeAt(existingIndex);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  bool _isSelected(ExerciseLibraryItem item) {
    return _selectedExercises.any((e) => e.name == item.nameEn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            _buildSearchBar(l10n),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D59F2)))
                  : _buildExerciseList(),
            ),
            if (_selectedExercises.isNotEmpty) _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0C12).withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF0D59F2), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0D59F2),
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.selectWorkout,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: isEnglish ? 2.0 : 0.5,
              fontFamily: isEnglish ? 'Courier' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: [
          // Expanded Search Field
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _applySearch,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Courier',
                  letterSpacing: 1.0,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  hintText: l10n.searchDatabase,
                  hintStyle: TextStyle(
                    color: Colors.grey[700],
                    fontFamily: 'Courier',
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Compact Filter Button (Icon Only)
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showFilterModal,
                child: const Center(
                  child: Icon(
                    Icons.tune,
                    color: Color(0xFF0D59F2),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        final isSelected = _isSelected(exercise);
        
        return _buildExerciseCard(exercise, isSelected);
      },
    );
  }

  Widget _buildExerciseCard(ExerciseLibraryItem exercise, bool isSelected) {
    final l10n = AppLocalizations.of(context);
    final engName = exercise.nameEn.replaceAll('_', ' ');
    
    // Get localized name based on current locale
    String localName = '';
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    
    switch (locale.languageCode) {
      case 'ko':
        localName = exercise.nameKr;
        break;
      case 'ja':
        localName = exercise.nameJp;
        break;
      default:
        localName = exercise.nameEn;
    }
    
    // Determine main title and subtitle based on locale
    final String mainTitle;
    final String? subTitle;
    
    if (isEnglish) {
      // English users: Show English as main, no subtitle
      mainTitle = engName;
      subTitle = null;
    } else {
      // Non-English users: Show localized as main, English as subtitle
      mainTitle = (localName.isNotEmpty && localName != exercise.nameEn) 
          ? localName 
          : engName;
      subTitle = (localName.isNotEmpty && localName != exercise.nameEn) 
          ? engName 
          : null;
    }
    
    // Get localized muscle and equipment
    final localizedMuscle = _getLocalizedBodyPart(exercise.targetPart, l10n);
    final localizedEquipment = _getLocalizedEquipment(exercise.equipmentType, l10n);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        // Premium matte black gradient
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A), // Lighter top-left
            Color(0xFF151515), // Darker bottom-right
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          // Selected state: add blue glow
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF0D59F2).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleExercise(exercise),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Left glowing indicator pill (shorter)
                Container(
                  width: 3,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF0D59F2)
                        : const Color(0xFF0D59F2).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1.5),
                    // Glow effect for selected state
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0D59F2).withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content Area (Dense)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row: Title + Metadata (inline)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Main Title
                          Flexible(
                            child: Text(
                              mainTitle.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF0D59F2) : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                height: 1.2,
                                shadows: isSelected
                                    ? [
                                        Shadow(
                                          color: const Color(0xFF0D59F2).withValues(alpha: 0.4),
                                          blurRadius: 5,
                                        ),
                                      ]
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Metadata (inline with title)
                          Text(
                            isEnglish 
                                ? '$localizedMuscle • $localizedEquipment'.toUpperCase()
                                : '$localizedMuscle • $localizedEquipment',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontFamily: isEnglish ? 'Courier' : null,
                              fontWeight: FontWeight.w500,
                              letterSpacing: isEnglish ? 0.5 : 0.0,
                            ),
                          ),
                        ],
                      ),
                      
                      // SUBTITLE (English name for non-English users)
                      if (subTitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subTitle.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Courier',
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Add/Check Button (Compact)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    // Filled blue background when selected
                    color: isSelected 
                        ? const Color(0xFF0D59F2)
                        : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D59F2)
                          : const Color(0xFF0D59F2).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    // Glowing shadow effect
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0D59F2).withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () => Navigator.pop(context, _selectedExercises),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0D59F2),
            border: Border.all(
              color: const Color(0xFF0D59F2).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D59F2).withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.addExercisesCount(_selectedExercises.length),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: isEnglish ? 2.0 : 0.5,
                  fontFamily: isEnglish ? 'Courier' : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for localization
  String _getLocalizedBodyPart(String targetPart, AppLocalizations l10n) {
    switch (targetPart.toLowerCase()) {
      case 'chest': return l10n.chest;
      case 'back': return l10n.back;
      case 'legs': return l10n.legs;
      case 'shoulders': return l10n.shoulders;
      case 'arms': return l10n.arms;
      case 'abs': return l10n.abs;
      case 'cardio': return l10n.cardio;
      default: return targetPart;
    }
  }
  
  String _getLocalizedEquipment(String equipmentType, AppLocalizations l10n) {
    switch (equipmentType.toLowerCase()) {
      case 'barbell': return l10n.barbell;
      case 'dumbbell': return l10n.dumbbell;
      case 'machine': return l10n.machine;
      case 'cable': return l10n.cable;
      case 'bodyweight': return l10n.bodyweight;
      case 'band': return l10n.band;
      case 'kettlebell': return l10n.kettlebell;
      default: return equipmentType;
    }
  }
}

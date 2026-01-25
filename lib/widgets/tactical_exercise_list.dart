import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercise_library.dart';
import '../models/exercise.dart';
import '../services/exercise_seeding_service.dart';
import '../l10n/app_localizations.dart';
import '../core/iron_theme.dart';
import '../core/body_part_colors.dart';
import '../widgets/modals/exercise_detail_modal.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../core/service_locator.dart';

/// 🔥 TACTICAL EXERCISE LIST - Reusable Exercise Browser Component
/// 
/// This widget can operate in two modes:
/// - **View Mode** (isSelectionMode = false): Browse exercises, tap to view details
/// - **Selection Mode** (isSelectionMode = true): Select exercises with checkmarks, confirm with bottom button
class TacticalExerciseList extends StatefulWidget {
  /// Selection mode: true = multi-select with checkmarks, false = view-only
  final bool isSelectionMode;
  
  /// Callback when exercises are selected and confirmed (Selection Mode only)
  final Function(List<Exercise>)? onExercisesSelected;
  
  /// Optional: Pre-selected body part filter
  final String? initialBodyPart;
  
  /// Optional: Show bookmarks functionality
  final bool showBookmarks;
  
  /// Optional: Header widget to display between filters and list
  final Widget? headerWidget;
  
  /// Optional: External muscle filter (from modal)
  final Set<String>? selectedMuscles;
  
  /// Optional: External equipment filter (from modal)
  final Set<String>? selectedEquipment;

  const TacticalExerciseList({
    super.key,
    this.isSelectionMode = false,
    this.onExercisesSelected,
    this.initialBodyPart,
    this.showBookmarks = true,
    this.headerWidget,
    this.selectedMuscles,
    this.selectedEquipment,
  });

  @override
  State<TacticalExerciseList> createState() => _TacticalExerciseListState();
}

class _TacticalExerciseListState extends State<TacticalExerciseList> {
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();
  
  // Filter State
  String _selectedBodyPart = 'all';
  final List<String> _bodyPartKeys = [
    'all', 'favorites', 'chest', 'back', 'legs', 'shoulders', 'arms', 'abs', 'cardio', 'stretching', 'fullBody',
  ];
  
  String? _selectedEquipmentKey;
  
  // Data State
  List<ExerciseLibraryItem> _allExercises = [];
  List<ExerciseLibraryItem> _filteredExercises = [];

  bool _isLoading = false;
  String? _error;
  
  // Selection State (for Selection Mode)
  final List<Exercise> _selectedExercises = [];
  
  // Bookmarks
  final Set<String> _bookmarkedIds = {};

  // Cache available equipment keys based on body part filter to avoid re-calculation on every build
  List<String>? _cachedAvailableEquipmentKeys;
  
  // Search
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.initialBodyPart != null) {
      _selectedBodyPart = widget.initialBodyPart!;
    }
    _loadAllExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllExercises() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      await _seedingService.initializeAndSeed();
      final exercises = await _seedingService.getAllExercises();
      
      if (mounted) {
        setState(() {
          _allExercises = exercises;
          _cachedAvailableEquipmentKeys = null; // Invalidate cache
          _isLoading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<ExerciseLibraryItem> get _bodyPartFilteredExercises {
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

  void _applyFilter() {
    final searchLower = _searchQuery.toLowerCase();
    final equipmentLower = _selectedEquipmentKey?.toLowerCase();
    final bodyPartLower = _selectedBodyPart.toLowerCase();
    final isAllBodyParts = _selectedBodyPart == 'all';
    final isFavorites = _selectedBodyPart == 'favorites';
    
    // 🔥 External filters from modal (Library page)
    final hasExternalMuscleFilter = widget.selectedMuscles != null && widget.selectedMuscles!.isNotEmpty;
    final hasExternalEquipmentFilter = widget.selectedEquipment != null && widget.selectedEquipment!.isNotEmpty;

    setState(() {
      _filteredExercises = _allExercises.where((ex) {
        // Step 1: Body Part Filter (internal or external)
        if (hasExternalMuscleFilter) {
          // Use external muscle filter from modal
          final matchesMuscle = widget.selectedMuscles!.any((muscle) =>
              ex.targetPart.toLowerCase() == muscle.toLowerCase());
          if (!matchesMuscle) return false;
        } else {
          // Use internal body part filter
          if (isFavorites) {
            if (!_bookmarkedIds.contains(ex.id)) return false;
          } else if (!isAllBodyParts) {
            if (ex.targetPart.toLowerCase() != bodyPartLower) return false;
          }
        }

        // Step 2: Equipment Filter (internal or external)
        if (hasExternalEquipmentFilter) {
          // Use external equipment filter from modal
          final matchesEquipment = widget.selectedEquipment!.any((equipment) =>
              ex.equipmentType.toLowerCase() == equipment.toLowerCase());
          if (!matchesEquipment) return false;
        } else if (equipmentLower != null) {
          // Use internal equipment filter
          if (ex.equipmentType.toLowerCase() != equipmentLower) return false;
        }

        // Step 3: Search Query Filter
        if (searchLower.isNotEmpty) {
          if (!ex.getLocalizedName(context).toLowerCase().contains(searchLower)) return false;
        }

        return true;
      }).toList();
    });
  }

  String _getEquipmentLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'bodyweight': return l10n.bodyweight;
      case 'machine': return l10n.machine;
      case 'barbell': return l10n.barbell;
      case 'dumbbell': return l10n.dumbbell;
      case 'cable': return l10n.cable;
      case 'band': return l10n.band;
      default: return key;
    }
  }
  
  String _getLocalizedBodyPart(String targetPart) {
    final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);
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

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
      if (_selectedBodyPart == 'favorites') {
        _cachedAvailableEquipmentKeys = null; // Invalidate cache
        _applyFilter();
      }
    });
  }

  void _toggleExerciseSelection(ExerciseLibraryItem item) {
    if (!widget.isSelectionMode) return;
    
    // 🔥 햅틱 피드백 추가
    HapticFeedback.lightImpact();
    
    final name = item.getLocalizedName(context);
    setState(() {
      final idx = _selectedExercises.indexWhere((e) => e.name == name);
      if (idx >= 0) {
        _selectedExercises.removeAt(idx);
      } else {
        _selectedExercises.add(Exercise(
          name: name,
          bodyPart: _getLocalizedBodyPart(item.targetPart),
        ));
      }
    });
  }

  bool _isExerciseSelected(ExerciseLibraryItem item) {
    if (!widget.isSelectionMode) return false;
    return _selectedExercises.any((e) => e.name == item.getLocalizedName(context));
  }

  void _confirmSelection() {
    if (widget.onExercisesSelected != null && _selectedExercises.isNotEmpty) {
      // 🔥 확인 시 햅틱 피드백
      HapticFeedback.mediumImpact();
      widget.onExercisesSelected!(_selectedExercises);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        _buildSearchBar(l10n),
        _buildBodyPartTabs(l10n),
        if (_selectedBodyPart != 'all' && _selectedBodyPart != 'favorites')
          _buildEquipmentFilter(l10n),
        // 🔥 Header Widget (e.g., Create Button)
        if (widget.headerWidget != null) widget.headerWidget!,
        Expanded(child: _buildExerciseList(l10n)),
        if (widget.isSelectionMode && _selectedExercises.isNotEmpty)
          _buildSelectionBottomBar(l10n),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: l10n.searchExercise.toUpperCase(),
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
            fontFamily: 'Courier',
            letterSpacing: 1.0,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 20.0,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilter();
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Colors.white24, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Colors.white, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.black,
          isDense: true,
        ),
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
          fontFamily: 'Courier',
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
            _applyFilter();
          });
        },
      ),
    );
  }

  Widget _buildBodyPartTabs(AppLocalizations l10n) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: IronTheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _bodyPartKeys.length,
        itemBuilder: (context, index) {
          final key = _bodyPartKeys[index];
          final isSelected = key == _selectedBodyPart;
          
          // Get color for this body part (skip for 'all' and 'favorites')
          final Color? categoryColor = (key != 'all' && key != 'favorites') 
              ? BodyPartColors.getColor(key) 
              : null;
          
          // Determine text and border colors based on selection state
          final Color textColor = isSelected 
              ? (categoryColor ?? Colors.white)
              : Colors.grey;
          
          final Color borderColor = isSelected 
              ? (categoryColor ?? Colors.white)
              : Colors.transparent;
          
          final Color backgroundColor = isSelected && categoryColor != null
              ? categoryColor.withValues(alpha: 0.1)
              : Colors.transparent;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _getBodyPartLabel(l10n, key),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                  color: textColor,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedBodyPart = key;
                  _cachedAvailableEquipmentKeys = null; // Invalidate cache
                  _selectedEquipmentKey = null;
                  _applyFilter();
                });
              },
              backgroundColor: backgroundColor,
              selectedColor: backgroundColor,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: borderColor,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  String _getBodyPartLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'all': return l10n.all;
      case 'favorites': return l10n.favorites;
      case 'chest': return l10n.chest;
      case 'back': return l10n.back;
      case 'legs': return l10n.legs;
      case 'shoulders': return l10n.shoulders;
      case 'arms': return l10n.arms;
      case 'abs': return l10n.abs;
      case 'cardio': return l10n.cardio;
      case 'stretching': return l10n.stretching;
      case 'fullBody': return l10n.fullBody;
      default: return key;
    }
  }

  Widget _buildEquipmentFilter(AppLocalizations l10n) {
    final availableKeys = _availableEquipmentKeys;
    
    if (availableKeys.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: IronTheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableKeys.length,
        itemBuilder: (context, index) {
          final key = availableKeys[index];
          final isSelected = key == _selectedEquipmentKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(
                _getEquipmentLabel(l10n, key),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedEquipmentKey = isSelected ? null : key;
                  _applyFilter();
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Colors.transparent,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isSelected ? Colors.white : Colors.white12,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList(AppLocalizations l10n) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: IronTheme.primary));
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 48, color: Colors.red), const SizedBox(height: 16), Text(l10n.errorOccurred(_error!), style: const TextStyle(color: IronTheme.textHigh)), const SizedBox(height: 16), ElevatedButton(onPressed: _loadAllExercises, style: ElevatedButton.styleFrom(backgroundColor: IronTheme.primary, foregroundColor: IronTheme.background), child: Text(l10n.retry))]));
    if (_filteredExercises.isEmpty) return Center(child: Text(l10n.noExercises, style: TextStyle(color: IronTheme.textLow, fontSize: 16)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        final isBookmarked = _bookmarkedIds.contains(exercise.id);
        final isSelected = _isExerciseSelected(exercise);
        
        return _buildPremiumExerciseCard(exercise, isSelected, isBookmarked, l10n);
      },
    );
  }

  // 🔥 Premium Exercise Card (matching Exercise Selection Page)
  Widget _buildPremiumExerciseCard(
    ExerciseLibraryItem exercise,
    bool isSelected,
    bool isBookmarked,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    final engName = exercise.nameEn.replaceAll('_', ' ');
    final localName = exercise.getLocalizedName(context);
    
    // Determine main title and subtitle
    final String mainTitle;
    final String? subTitle;
    
    if (isEnglish) {
      mainTitle = engName;
      subTitle = null;
    } else {
      mainTitle = (localName.isNotEmpty && localName != exercise.nameEn) 
          ? localName 
          : engName;
      subTitle = (localName.isNotEmpty && localName != exercise.nameEn) 
          ? engName 
          : null;
    }
    
    // Get localized muscle and equipment
    final localizedMuscle = _getLocalizedBodyPart(exercise.targetPart);
    final localizedEquipment = _getLocalizedEquipment(exercise.equipmentType);
    
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
          onTap: () {
            if (widget.isSelectionMode) {
              _toggleExerciseSelection(exercise);
            } else {
              // View mode: Show detail modal
              showExerciseDetailModal(
                context,
                exerciseName: exercise.nameEn,
                sessionRepo: getIt<SessionRepo>(),
                exerciseRepo: getIt<ExerciseLibraryRepo>(),
              );
            }
          },
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
                
                // Right side actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bookmark button (if enabled and not in selection mode)
                    if (widget.showBookmarks && !widget.isSelectionMode) ...[
                      GestureDetector(
                        onTap: () => _toggleBookmark(exercise.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? const Color(0xFF0D59F2) : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    
                    // Selection checkbox or info button
                    if (widget.isSelectionMode)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
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
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          showExerciseDetailModal(
                            context,
                            exerciseName: exercise.nameEn,
                            sessionRepo: getIt<SessionRepo>(),
                            exerciseRepo: getIt<ExerciseLibraryRepo>(),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,  // 🎯 배경은 검정
        border: Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _confirmSelection,
            icon: const Icon(Icons.add, size: 22, color: Colors.black),
            label: Text(
              l10n.addExercises(_selectedExercises.length),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                fontFamily: 'Courier',
                color: Colors.black,  // 🎯 텍스트는 검정
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,  // 🎯 버튼은 흰색
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

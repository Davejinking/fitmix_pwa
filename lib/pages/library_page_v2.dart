import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/service_locator.dart';
import '../services/exercise_seeding_service.dart';
import '../models/exercise_library.dart';
import '../models/routine.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../l10n/app_localizations.dart';
import '../widgets/modals/exercise_detail_modal.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/routine_repo.dart';
import '../data/user_repo.dart';
import '../core/error_handler.dart';
import '../core/subscription_limits.dart';
import '../core/iron_theme.dart';
import 'shell_page.dart';
import 'exercise_selection_page_v2.dart';

class LibraryPageV2 extends StatefulWidget {
  const LibraryPageV2({super.key});

  @override
  State<LibraryPageV2> createState() => _LibraryPageV2State();
}

class _LibraryPageV2State extends State<LibraryPageV2> {
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();
  
  // 🔥 TACTICAL SWITCH: Routine Mode vs Exercise Mode
  bool _isRoutineMode = true;
  
  // Exercise Tab State
  String _selectedBodyPart = 'all'; // 🔥 Default: ALL
  final List<String> _bodyPartKeys = [
    'all', 'favorites', 'chest', 'back', 'legs', 'shoulders', 'arms', 'abs', 'cardio', 'stretching', 'fullBody',
  ];
  
  String? _selectedEquipmentKey; // 🔥 Nullable: null = ALL
  
  // Routine Tab State
  final List<String> _systemRoutineFilterKeys = ['all', 'push', 'pull', 'legs', 'upper', 'lower', 'fullBody'];
  String _selectedRoutineFilterKey = 'all';
  List<String> _allRoutineFilterKeys = [];
  
  List<ExerciseLibraryItem> _allExercises = [];
  List<ExerciseLibraryItem> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;
  
  final Set<String> _bookmarkedIds = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  String _routineSearchQuery = '';
  final TextEditingController _routineSearchController = TextEditingController();
  
  int _routineListKey = 0;
  
  @override
  void initState() {
    super.initState();
    _loadAllExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _routineSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllExercises() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      await _seedingService.initializeAndSeed();
      final exercises = await _seedingService.getAllExercises();
      
      if (mounted) {
        setState(() { _allExercises = exercises; _isLoading = false; });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  // 🔥 SMART AMMO CHECK: Get exercises filtered by body part only (before equipment filter)
  List<ExerciseLibraryItem> get _bodyPartFilteredExercises {
    if (_selectedBodyPart == 'all') {
      return List.from(_allExercises);
    } else if (_selectedBodyPart == 'favorites') {
      return _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
    } else {
      return _allExercises.where((ex) => ex.targetPart.toLowerCase() == _selectedBodyPart.toLowerCase()).toList();
    }
  }
  
  // 🔥 DYNAMIC EQUIPMENT TAGS: Extract available equipment from body part filtered exercises
  List<String> get _availableEquipmentKeys {
    return _bodyPartFilteredExercises
        .map((ex) => ex.equipmentType.toLowerCase())
        .toSet() // Remove duplicates
        .toList()
      ..sort(); // Sort alphabetically
  }

  void _applyFilter() {
    setState(() {
      // 🔥 Step 1: Body Part Filter
      if (_selectedBodyPart == 'all') {
        // Show ALL exercises
        _filteredExercises = List.from(_allExercises);
      } else if (_selectedBodyPart == 'favorites') {
        // Show only bookmarked exercises
        _filteredExercises = _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
      } else {
        // Show exercises matching body part
        _filteredExercises = _allExercises.where((ex) => ex.targetPart.toLowerCase() == _selectedBodyPart.toLowerCase()).toList();
      }
      
      // 🔥 Step 2: Equipment Filter (null = ALL)
      if (_selectedEquipmentKey != null) {
        _filteredExercises = _filteredExercises.where((ex) => ex.equipmentType.toLowerCase() == _selectedEquipmentKey!.toLowerCase()).toList();
      }
      
      // 🔥 Step 3: Search Query Filter
      if (_searchQuery.isNotEmpty) {
        _filteredExercises = _filteredExercises.where((ex) => ex.getLocalizedName(context).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
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
      if (_selectedBodyPart == 'favorites') _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        // 🔥 TACTICAL TOGGLE SWITCH
        _buildTacticalSwitch(l10n),
        
        // Content based on mode
        if (_isRoutineMode) ...[
          _buildRoutineSearchBar(l10n),
          _buildRoutineFilter(l10n),
          Expanded(child: _buildRoutinesList(l10n)),
        ] else ...[
          _buildSearchBar(l10n),
          _buildBodyPartTabs(l10n),
          // 🔥 CONDITIONAL: Show equipment filter ONLY when specific body part is selected
          if (_selectedBodyPart != 'all' && _selectedBodyPart != 'favorites')
            _buildEquipmentFilter(l10n),
          Expanded(child: _buildExerciseList(l10n)),
        ],
      ],
    );
  }
  
  // 🔥 TACTICAL TOGGLE SWITCH
  Widget _buildTacticalSwitch(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white24, width: 1.0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Left: ROUTINES
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isRoutineMode = true),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isRoutineMode ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.routines.toUpperCase(),
                    style: TextStyle(
                      color: _isRoutineMode ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      fontFamily: 'Courier',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // Right: EXERCISES
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isRoutineMode = false),
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isRoutineMode ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'EXERCISES', // TODO: Add i18n
                    style: TextStyle(
                      color: !_isRoutineMode ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      fontFamily: 'Courier',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // 🔥 Reduced vertical padding
      child: TextField(
        controller: _searchController,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: l10n.searchExercise.toUpperCase(),
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14.0, // 🔥 IRON STANDARD
            fontFamily: 'Courier',
            letterSpacing: 1.0,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 20.0, // 🔥 IRON STANDARD
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 20.0, // 🔥 IRON STANDARD
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
          fontSize: 14.0, // 🔥 IRON STANDARD
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
      height: 48, // 🔥 Reduced height
      padding: const EdgeInsets.symmetric(vertical: 6), // 🔥 Tighter padding
      color: IronTheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _bodyPartKeys.length,
        itemBuilder: (context, index) {
          final key = _bodyPartKeys[index];
          final isSelected = key == _selectedBodyPart;
          
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
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedBodyPart = key;
                  // 🔥 Reset equipment filter when changing body part
                  _selectedEquipmentKey = null;
                  _applyFilter();
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Colors.transparent,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isSelected ? Colors.white : Colors.white24,
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
      case 'all': return l10n.all; // 🔥 ALL (全て)
      case 'favorites': return l10n.favorites; // お気に入り
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
    // 🔥 SMART AMMO CHECK: Only show equipment tags that exist for current body part
    final availableKeys = _availableEquipmentKeys;
    
    // 🔥 If no equipment available (empty list), don't render anything
    if (availableKeys.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 44, // 🔥 Reduced height
      padding: const EdgeInsets.symmetric(vertical: 6), // 🔥 Tighter padding
      color: IronTheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableKeys.length,
        itemBuilder: (context, index) {
          final key = availableKeys[index];
          final isSelected = key == _selectedEquipmentKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 6), // 🔥 Tighter spacing
            child: FilterChip(
              label: Text(
                _getEquipmentLabel(l10n, key),
                style: TextStyle(
                  fontSize: 10, // 🔥 Smaller font (secondary filter)
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                  color: isSelected ? Colors.white : Colors.grey[700], // 🔥 Darker when unselected
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  // 🔥 Toggle Logic: Click again to deselect (return to ALL)
                  _selectedEquipmentKey = isSelected ? null : key;
                  _applyFilter();
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Colors.transparent,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // 🔥 Compact padding
              visualDensity: VisualDensity.compact, // 🔥 Thinner chips
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isSelected ? Colors.white : Colors.white12, // 🔥 Dimmer border
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutineSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), // 🔥 Reduced vertical padding
      child: TextField(
        controller: _routineSearchController,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "ルーティン検索", // TODO: Add i18n
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14.0, // 🔥 IRON STANDARD
            fontFamily: 'Courier',
            letterSpacing: 1.0,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 20.0, // 🔥 IRON STANDARD
          ),
          suffixIcon: _routineSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.grey,
                    size: 20.0, // 🔥 IRON STANDARD
                  ),
                  onPressed: () {
                    _routineSearchController.clear();
                    setState(() {
                      _routineSearchQuery = '';
                      _routineListKey++;
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
          fontSize: 14.0, // 🔥 IRON STANDARD
          color: Colors.white,
          fontFamily: 'Courier',
        ),
        onChanged: (query) {
          setState(() {
            _routineSearchQuery = query;
            _routineListKey++;
          });
        },
      ),
    );
  }

  // 🔥 루틴 필터 (Dynamic Tags)
  Widget _buildRoutineFilter(AppLocalizations l10n) {
    return Container(
      height: 48, // 🔥 Reduced height
      padding: const EdgeInsets.symmetric(vertical: 6), // 🔥 Tighter padding
      color: IronTheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _allRoutineFilterKeys.length,
        itemBuilder: (context, index) {
          final key = _allRoutineFilterKeys[index];
          final isSelected = key == _selectedRoutineFilterKey;
          final isSystemTag = _systemRoutineFilterKeys.contains(key);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _getRoutineFilterLabel(l10n, key),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Courier',
                  letterSpacing: 0.5,
                  color: isSelected ? Colors.white : (isSystemTag ? Colors.grey : Colors.grey[600]),
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedRoutineFilterKey = key;
                  _routineListKey++;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Colors.transparent,
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isSelected ? Colors.white : (isSystemTag ? Colors.white24 : Colors.white12),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 루틴 필터 라벨
  String _getRoutineFilterLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'all': return l10n.all;
      case 'push': return 'PUSH';
      case 'pull': return 'PULL';
      case 'legs': return l10n.legs.toUpperCase();
      case 'upper': return 'UPPER';
      case 'lower': return 'LOWER';
      case 'fullBody': return l10n.fullBody.toUpperCase();
      default: return key.toUpperCase();
    }
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
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: IronTheme.surface, 
            borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // 컴팩트한 아이콘
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: IronTheme.primary.withValues(alpha: 0.15), 
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: const Icon(Icons.fitness_center, color: IronTheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                // 운동 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.getLocalizedName(context), 
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: IronTheme.textHigh)
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getLocalizedBodyPart(exercise.targetPart)} • ${_getLocalizedEquipment(exercise.equipmentType)}', 
                        style: TextStyle(fontSize: 12, color: IronTheme.textMedium)
                      ),
                    ],
                  ),
                ),
                // 운동 상세 정보 버튼 (i) - 캘린더와 동일한 스타일
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
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: IronTheme.textMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 북마크 버튼
                GestureDetector(
                  onTap: () => _toggleBookmark(exercise.id),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border, 
                      color: isBookmarked ? IronTheme.primary : IronTheme.textLow, 
                      size: 20
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Routines List Widget
  Widget _buildRoutinesList(AppLocalizations l10n) {
    final routineRepo = getIt<RoutineRepo>();
    
    return ValueListenableBuilder<Box<Routine>>(
      valueListenable: routineRepo.listenable(),
      builder: (context, box, child) {
        var routines = box.values.toList()
          ..sort((a, b) {
            final aTime = a.lastUsedAt ?? a.createdAt;
            final bTime = b.lastUsedAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });

        // 🔥 동적 태그 수집: System Tags + User Tags
        final userTags = routines
            .expand((r) => r.tags)
            .toSet()
            .where((t) => !_systemRoutineFilterKeys.contains(t.toLowerCase()))
            .toList()
          ..sort();
        
        _allRoutineFilterKeys = [..._systemRoutineFilterKeys, ...userTags];

        // 🔥 검색 필터 적용
        if (_routineSearchQuery.isNotEmpty) {
          routines = routines.where((routine) {
            return routine.name.toLowerCase().contains(_routineSearchQuery.toLowerCase()) ||
                   routine.exercises.any((ex) => ex.name.toLowerCase().contains(_routineSearchQuery.toLowerCase()));
          }).toList();
        }

        // 🔥 태그 필터 적용
        if (_selectedRoutineFilterKey != 'all') {
          routines = routines.where((routine) {
            return routine.tags.any((tag) => tag.toLowerCase() == _selectedRoutineFilterKey.toLowerCase());
          }).toList();
        }

        return Column(
          children: [
            // "새 루틴 만들기" 버튼 (Tactical Invert)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _createNewRoutine,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    l10n.createRoutine.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontFamily: 'Courier',
                    ),
                  ),
                  style: ButtonStyle(
                    // Border: Always White
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    // Shape: Sharp corners
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    // BACKGROUND: Transparent → White when pressed
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.white;
                      }
                      return Colors.transparent;
                    }),
                    // TEXT COLOR: White → Black when pressed
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.black;
                      }
                      return Colors.white;
                    }),
                    // Remove default overlay
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            
            // 루틴 목록
            if (routines.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                      Icon(Icons.bookmark_border, size: 64, color: IronTheme.textLow),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noRoutines,
                        style: TextStyle(color: IronTheme.textLow, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.createRoutineHint,
                        style: TextStyle(color: IronTheme.textMedium, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    
                    // 🎯 TACTICAL ACCORDION CARD
                    return _RoutineAccordionCard(
                      routine: routine,
                      onEdit: () => _editRoutine(routine),
                      onDelete: () => _deleteRoutine(routine, l10n),
                      onLoad: () => _loadRoutine(routine, l10n),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  // Load Routine
  Future<void> _loadRoutine(Routine routine, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IronTheme.surface,
        title: Text(
          l10n.loadRoutine,
          style: const TextStyle(color: IronTheme.textHigh),
        ),
        content: Text(
          l10n.loadThisRoutine,
          style: const TextStyle(color: IronTheme.textMedium),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              l10n.loadRoutine.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: IronTheme.primary,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        final sessionRepo = getIt<SessionRepo>();
        final routineRepo = getIt<RoutineRepo>();
        final today = DateTime.now();
        final todayYmd = sessionRepo.ymd(today);
        
        print('🔍 Loading routine: ${routine.name}');
        print('🔍 Exercises count: ${routine.exercises.length}');
        for (var ex in routine.exercises) {
          print('  - ${ex.name}');
        }
        
        // Create new session with routine exercises AND routine name
        final session = Session(
          ymd: todayYmd,
          exercises: routine.exercises.map((e) => e.copyWith()).toList(),
          routineName: routine.name, // 🔥 루틴 이름 저장!
        );
        
        print('🔍 Session created with routineName: ${session.routineName}');
        print('🔍 Session exercises count: ${session.exercises.length}');
        
        await sessionRepo.put(session);
        await routineRepo.updateLastUsed(routine.id);
        
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, l10n.routineLoaded);
          
          // Navigate to calendar (home)
          final shellState = context.findAncestorStateOfType<ShellPageState>();
          shellState?.navigateToCalendar();
        }
      } catch (e) {
        print('❌ Error loading routine: $e');
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  // Delete Routine
  Future<void> _deleteRoutine(Routine routine, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IronTheme.surface,
        title: Text(
          l10n.deleteRoutine,
          style: const TextStyle(color: IronTheme.textHigh),
        ),
        content: Text(
          '${l10n.deleteRoutine} "${routine.name}"?',
          style: const TextStyle(color: IronTheme.textMedium),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text(
              l10n.delete.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        final routineRepo = getIt<RoutineRepo>();
        await routineRepo.delete(routine.id);
        
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, l10n.routineDeleted);
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, l10n.errorOccurred(e.toString()));
        }
      }
    }
  }

  // Create New Routine
  Future<void> _createNewRoutine() async {
    // 🚨 CHECKPOINT: Check routine limit BEFORE selecting exercises
    final routineRepo = getIt<RoutineRepo>();
    final userRepo = getIt<UserRepo>();
    
    final routines = await routineRepo.listAll();
    final userProfile = await userRepo.getUserProfile();
    final isPro = userProfile?.isPro ?? false;
    
    // Check if user can save more routines
    if (!SubscriptionLimits.canSaveMoreRoutines(
      isPro: isPro,
      currentCount: routines.length,
    )) {
      // 🚫 BLOCKED: Show upgrade dialog
      _showUpgradeDialog();
      return;
    }

    // ✅ ALLOWED: Proceed to create
    // Step 1: Select exercises
    final selected = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseSelectionPageV2(),
      ),
    );

    if (selected == null || selected.isEmpty || !mounted) return;

    // Step 2: Enter routine name and select tags
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _SaveRoutineDialog(
        exerciseCount: selected.length,
        existingTags: _allRoutineFilterKeys.where((t) => t != 'all').toList(),
      ),
    );

    if (result == null || !mounted) return;
    
    final routineName = result['name'] as String;
    final selectedTags = result['tags'] as List<String>;

    if (routineName.isNotEmpty && mounted) {
      try {
        print('🔍 [CREATE] Selected exercises count: ${selected.length}');
        print('🔍 [CREATE] Selected tags: $selectedTags');
        for (var i = 0; i < selected.length; i++) {
          print('  [$i] ${selected[i].name}');
        }
        
        final routine = Routine(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: routineName,
          exercises: selected.map((e) => e.copyWith()).toList(),
          tags: selectedTags,
        );
        
        print('🔍 [CREATE] Routine created with ${routine.exercises.length} exercises and ${routine.tags.length} tags');
        for (var i = 0; i < routine.exercises.length; i++) {
          print('  [$i] ${routine.exercises[i].name}');
        }
        
        await routineRepo.save(routine);
        
        // Verify what was saved
        final saved = await routineRepo.get(routine.id);
        print('🔍 [CREATE] Saved routine has ${saved?.exercises.length ?? 0} exercises');
        if (saved != null) {
          for (var i = 0; i < saved.exercises.length; i++) {
            print('  [$i] ${saved.exercises[i].name}');
          }
        }
        
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, AppLocalizations.of(context).routineSaved);
        }
      } catch (e) {
        print('❌ [CREATE] Error: $e');
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, AppLocalizations.of(context).errorOccurred(e.toString()));
        }
      }
    }
  }

  // Edit Routine
  Future<void> _editRoutine(Routine routine) async {
    // Step 1: Select exercises (pre-fill with existing)
    final selected = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseSelectionPageV2(),
      ),
    );

    if (selected == null || selected.isEmpty || !mounted) return;

    // Step 2: Edit routine name
    String routineName = routine.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: IronTheme.surface,
          title: Text(
            l10n.editRoutine.toUpperCase(),
            style: const TextStyle(
              color: IronTheme.textHigh,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exerciseCount(selected.length),
                style: TextStyle(color: IronTheme.textMedium, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: IronTheme.textHigh),
                controller: TextEditingController(text: routineName),
                decoration: InputDecoration(
                  hintText: l10n.enterRoutineName,
                  hintStyle: const TextStyle(color: IronTheme.textLow),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: IronTheme.textHigh),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: IronTheme.textHigh, width: 2),
                  ),
                ),
                onChanged: (val) => routineName = val,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(
                l10n.save.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: IronTheme.primary,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && routineName.isNotEmpty && mounted) {
      try {
        final routineRepo = getIt<RoutineRepo>();
        final updatedRoutine = routine.copyWith(
          name: routineName,
          exercises: selected.map((e) => e.copyWith()).toList(),
        );
        await routineRepo.save(updatedRoutine);
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, AppLocalizations.of(context).routineSaved);
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, AppLocalizations.of(context).errorOccurred(e.toString()));
        }
      }
    }
  }

  // Show upgrade to PRO dialog
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: IronTheme.surface,
          title: Text(
            l10n.routineLimitReached.toUpperCase(),
            style: const TextStyle(
              color: IronTheme.textHigh,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
            ),
          ),
          content: Text(
            l10n.routineLimitMessage(SubscriptionLimits.freeRoutineLimit),
            style: const TextStyle(
              color: IronTheme.textMedium,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                l10n.cancel.toUpperCase(),
                style: TextStyle(color: IronTheme.textMedium),
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: IronTheme.primary,
                foregroundColor: IronTheme.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                l10n.upgradeToProShort.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                // TODO: Navigate to subscription/upgrade page
                Navigator.pushNamed(context, '/upgrade');
              },
            ),
          ],
        );
      },
    );
  }
}


// 🔥 Save Routine Dialog with Tag Selection
class _SaveRoutineDialog extends StatefulWidget {
  final int exerciseCount;
  final List<String> existingTags;

  const _SaveRoutineDialog({
    required this.exerciseCount,
    required this.existingTags,
  });

  @override
  State<_SaveRoutineDialog> createState() => _SaveRoutineDialogState();
}

class _SaveRoutineDialogState extends State<_SaveRoutineDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _customTagController = TextEditingController();
  final Set<String> _selectedTags = {};
  
  // System preset tags
  final List<String> _systemTags = ['PUSH', 'PULL', 'LEGS', 'UPPER', 'LOWER', 'FULL BODY'];

  @override
  void dispose() {
    _nameController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim().toUpperCase();
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _customTagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      title: Text(
        l10n.createRoutine.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontFamily: 'Courier',
          letterSpacing: 1.5,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise count
            Text(
              '${widget.exerciseCount} EXERCISES',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontFamily: 'Courier',
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            
            // Routine name input
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
              decoration: InputDecoration(
                hintText: l10n.enterRoutineName,
                hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Courier'),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            
            // Tags section
            const Text(
              'TAGS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            
            // System preset tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _systemTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () => _toggleTag(tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Courier',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            
            // Custom tag input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customTagController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Courier',
                    ),
                    decoration: const InputDecoration(
                      hintText: '+ CUSTOM TAG',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontFamily: 'Courier',
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addCustomTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: _addCustomTag,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            
            // Selected tags display
            if (_selectedTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _toggleTag(tag),
                          child: const Icon(Icons.close, size: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            l10n.cancel.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              letterSpacing: 1.0,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(
            l10n.save.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
            ),
          ),
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, {
                'name': name,
                'tags': _selectedTags.toList(),
              });
            }
          },
        ),
      ],
    );
  }
}


// 🔥 Routine Accordion Card (Collapsible)
class _RoutineAccordionCard extends StatefulWidget {
  final Routine routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLoad;

  const _RoutineAccordionCard({
    required this.routine,
    required this.onEdit,
    required this.onDelete,
    required this.onLoad,
  });

  @override
  State<_RoutineAccordionCard> createState() => _RoutineAccordionCardState();
}

class _RoutineAccordionCardState extends State<_RoutineAccordionCard> {
  bool _isExpanded = false; // Default: Collapsed

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: _isExpanded ? Colors.white : Colors.white24, // 🔥 Highlight when open
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        children: [
          // HEADER (Clickable)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Title & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.routine.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontFamily: 'Courier',
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.routine.exercises.length} EXERCISES',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Courier',
                                letterSpacing: 1.0,
                              ),
                            ),
                            // Tags
                            if (widget.routine.tags.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              ...widget.routine.tags.take(2).map((tag) => Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              )),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Edit/Delete Icons
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                        onPressed: widget.onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                        onPressed: widget.onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      ),
                      const SizedBox(width: 4),
                      // Chevron Icon
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // BODY (Expandable)
          if (_isExpanded) ...[
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise List with Sets x Reps
                  ...widget.routine.exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Exercise Name
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'Courier',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Target Sets x Reps
                        Text(
                          '${exercise.targetSets} × ${exercise.targetReps}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontFamily: 'Courier',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                  // Load Button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: widget.onLoad,
                      style: ButtonStyle(
                        side: WidgetStateProperty.all(
                          const BorderSide(color: Colors.white, width: 1.5),
                        ),
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white;
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.black;
                          }
                          return Colors.white;
                        }),
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Text(
                        l10n.loadRoutine.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

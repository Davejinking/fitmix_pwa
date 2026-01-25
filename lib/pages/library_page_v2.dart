import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/service_locator.dart';
import '../models/routine.dart';
import '../models/routine_tag.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../l10n/app_localizations.dart';
import '../widgets/tactical_exercise_list.dart';
import '../widgets/modals/exercise_filter_modal.dart';
import '../data/session_repo.dart';
import '../data/routine_repo.dart';
import '../data/user_repo.dart';
import '../services/exercise_seeding_service.dart';
import '../core/error_handler.dart';
import '../core/subscription_limits.dart';
import '../core/iron_theme.dart';
import 'shell_page.dart';
import 'exercise_selection_page_v2.dart';
import 'paywall_page.dart';

class LibraryPageV2 extends StatefulWidget {
  const LibraryPageV2({super.key});

  @override
  State<LibraryPageV2> createState() => _LibraryPageV2State();
}

class _LibraryPageV2State extends State<LibraryPageV2> {
  // 🔥 TACTICAL SWITCH: Routine Mode vs Exercise Mode
  bool _isRoutineMode = true;
  
  // Routine Tab State
  final List<String> _systemRoutineFilterKeys = ['all', 'push', 'pull', 'legs', 'upper', 'lower', 'fullBody'];
  String _selectedRoutineFilterKey = 'all';
  List<String> _allRoutineFilterKeys = [];
  Map<String, int> _userTagColors = {}; // 🎨 Store user-defined tag colors
  
  String _routineSearchQuery = '';
  final TextEditingController _routineSearchController = TextEditingController();
  
  // Exercise Tab State
  int _exerciseListKey = 0;
  Set<String> _selectedMuscles = {}; // 🔥 Filter state for exercises
  Set<String> _selectedEquipment = {}; // 🔥 Filter state for exercises
  
  @override
  void initState() {
    super.initState();
    // 🔥 Initialize filter keys with system tags
    _allRoutineFilterKeys = List.from(_systemRoutineFilterKeys);
  }

  @override
  void dispose() {
    _routineSearchController.dispose();
    super.dispose();
  }

  // 🔥 Add Exercise Dialog
  Future<void> _showAddExerciseDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _AddExerciseDialog(),
    );

    if (result != null && mounted) {
      final name = result['name']!;
      final bodyPart = result['bodyPart']!;
      
      try {
        // 🔥 ExerciseSeedingService를 사용하여 커스텀 운동 추가
        final seedingService = ExerciseSeedingService();
        await seedingService.addCustomExercise(
          name: name,
          bodyPart: bodyPart,
        );
        
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            AppLocalizations.of(context).exerciseAddedSuccessfully,
          );
          
          // 🔥 리스트 새로고침을 위해 key 변경
          setState(() {
            _exerciseListKey++;
          });
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            AppLocalizations.of(context).errorOccurred(e.toString()),
          );
        }
      }
    }
  }

  // 🔥 Build Exercises Tab (Matching Routine Tab Style)
  Widget _buildExercisesTab(AppLocalizations l10n) {
    return TacticalExerciseList(
      key: ValueKey(_exerciseListKey), // 🔥 Key for forcing rebuild
      isSelectionMode: false,
      showBookmarks: true,
      selectedMuscles: _selectedMuscles, // 🔥 Pass filter state
      selectedEquipment: _selectedEquipment, // 🔥 Pass filter state
      hideInternalFilters: true, // 🔥 Hide internal filters, use modal instead
      // 🔥 Header Widget: Create Button (PIXEL PERFECT - Matching Routine Tab)
      headerWidget: Container(
        padding: const EdgeInsets.all(16), // 🎯 EXACT MATCH with Routine Tab
        child: SizedBox(
          width: double.infinity,
          height: 50, // 🎯 EXACT MATCH with Routine Tab
          child: OutlinedButton(
            onPressed: _showAddExerciseDialog,
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
            // 🔥 ONLY TEXT - NO ICON
            child: Text(
              '+ ${l10n.addCustomExercise}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        // 🔥 TACTICAL TOGGLE SWITCH
        _buildTacticalSwitch(l10n),
        
        // Search Bar (with filter button for exercises)
        _buildRoutineSearchBar(l10n),
        
        // Content based on mode
        if (_isRoutineMode) ...[
          // Routine Mode (no horizontal filter, uses modal)
          Expanded(child: _buildRoutinesList(l10n)),
        ] else ...[
          // 🔥 Exercise Mode (no horizontal filter, uses modal)
          Expanded(child: _buildExercisesTab(l10n)),
        ],
      ],
    );
  }
  
  // 🔥 TACTICAL TOGGLE SWITCH (3-way: Exercises / Routines / Programs)
  Widget _buildTacticalSwitch(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF27272A), width: 1.0),
      ),
      child: Row(
        children: [
          // EXERCISES
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRoutineMode = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isRoutineMode ? const Color(0xFF0D59F2).withValues(alpha: 0.1) : Colors.transparent,
                  border: !_isRoutineMode 
                      ? const Border(bottom: BorderSide(color: Color(0xFF0D59F2), width: 2))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.tabExercises.toUpperCase(),
                  style: TextStyle(
                    color: !_isRoutineMode ? Colors.white : const Color(0xFF71717A),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
          // ROUTINES
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRoutineMode = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isRoutineMode ? const Color(0xFF0D59F2).withValues(alpha: 0.1) : Colors.transparent,
                  border: _isRoutineMode 
                      ? const Border(bottom: BorderSide(color: Color(0xFF0D59F2), width: 2))
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.tabRoutines.toUpperCase(),
                  style: TextStyle(
                    color: _isRoutineMode ? Colors.white : const Color(0xFF71717A),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
          // PROGRAMS (Coming Soon)
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: Implement programs
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  l10n.tabPrograms.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF71717A),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    fontFamily: 'Courier',
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSearchBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF18181B).withValues(alpha: 0.8),
                border: Border.all(color: const Color(0xFF27272A), width: 1.0),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF71717A),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _routineSearchController,
                      cursorColor: const Color(0xFF0D59F2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Courier',
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchDatabase,
                        hintStyle: const TextStyle(
                          color: Color(0xFF3F3F46),
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: _routineSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Color(0xFF71717A),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _routineSearchController.clear();
                                  setState(() {
                                    _routineSearchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (query) {
                        setState(() {
                          _routineSearchQuery = query;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFF27272A),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Filter Button (show in both modes)
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: const Color(0xFF27272A),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isRoutineMode ? _showRoutineFilterModal : _showFilterModal,
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

  // 🔥 Show Filter Modal (Center Dialog)
  void _showFilterModal() {
    showDialog(
      context: context,
      builder: (context) => ExerciseFilterModal(
        selectedMuscles: _selectedMuscles,
        selectedEquipment: _selectedEquipment,
        onApply: (muscles, equipment) {
          setState(() {
            _selectedMuscles = muscles;
            _selectedEquipment = equipment;
            _exerciseListKey++; // Force rebuild
          });
        },
      ),
    );
  }

  // 🔥 Show Routine Filter Modal (Center Dialog)
  void _showRoutineFilterModal() {
    showDialog(
      context: context,
      builder: (context) => _RoutineFilterDialog(
        selectedTag: _selectedRoutineFilterKey,
        availableTags: _allRoutineFilterKeys,
        onApply: (selectedTag) {
          setState(() {
            _selectedRoutineFilterKey = selectedTag;
          });
        },
      ),
    );
  }

  // Helper to get localized routine filter label
  String _getRoutineFilterLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'all': return l10n.all;
      case 'push': return l10n.push.toUpperCase();
      case 'pull': return l10n.pull.toUpperCase();
      case 'legs': return l10n.legs.toUpperCase();
      case 'upper': return l10n.upper.toUpperCase();
      case 'lower': return l10n.lower.toUpperCase();
      case 'fullBody': return l10n.fullBody.toUpperCase();
      default: return key.toUpperCase();
    }
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

        // 🎨 FIX: Build map of user-defined tag colors from all routines
        _userTagColors.clear();
        for (final routine in routines) {
          _userTagColors.addAll(routine.tagColors);
        }

        // 🔥 FIX: Build unique tag list without duplicates
        // Get all localized system tag labels
        final systemTagLabels = _systemRoutineFilterKeys
            .map((key) => _getRoutineFilterLabel(l10n, key))
            .toSet();
        
        // Get user tags from routines, excluding system tags (by localized label)
        final userTags = routines
            .expand((r) => r.tags)
            .where((tag) => !systemTagLabels.contains(tag))
            .toSet()
            .toList()
          ..sort();
        
        // Combine system keys with user tags (no duplicates)
        _allRoutineFilterKeys = [..._systemRoutineFilterKeys, ...userTags];

        // 🔥 FIX: Validate current filter selection
        // If the selected filter no longer exists, reset to 'all'
        if (!_allRoutineFilterKeys.contains(_selectedRoutineFilterKey)) {
          // Use post-frame callback to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedRoutineFilterKey = 'all';
              });
            }
          });
        }

        // 🔥 검색 필터 적용
        if (_routineSearchQuery.isNotEmpty) {
          final lowerQuery = _routineSearchQuery.toLowerCase();
          routines = routines.where((routine) {
            return routine.name.toLowerCase().contains(lowerQuery) ||
                   routine.exercises.any((ex) => ex.name.toLowerCase().contains(lowerQuery));
          }).toList();
        }

        // 🔥 태그 필터 적용
        if (_selectedRoutineFilterKey != 'all') {
          // Get the localized label for the selected key
          final selectedLabel = _systemRoutineFilterKeys.contains(_selectedRoutineFilterKey)
              ? _getRoutineFilterLabel(l10n, _selectedRoutineFilterKey)
              : _selectedRoutineFilterKey;
          
          routines = routines.where((routine) {
            return routine.tags.contains(selectedLabel);
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
        // 🔥 FIX: Capture current filter BEFORE deletion
        final currentFilterKey = _selectedRoutineFilterKey;
        final currentFilterLabel = _systemRoutineFilterKeys.contains(currentFilterKey)
            ? _getRoutineFilterLabel(l10n, currentFilterKey)
            : currentFilterKey;
        
        final routineRepo = getIt<RoutineRepo>();
        await routineRepo.delete(routine.id);
        
        if (mounted) {
          // 🔥 FIX: Check if the current filter still exists after deletion
          // This prevents RangeError when the last routine with a custom tag is deleted
          final remainingRoutines = await routineRepo.listAll();
          final allTags = remainingRoutines.expand((r) => r.tags).toSet();
          
          // If current filter was a custom tag and no longer exists, reset to 'all'
          if (!_systemRoutineFilterKeys.contains(currentFilterKey) && 
              !allTags.contains(currentFilterLabel)) {
            setState(() {
              _selectedRoutineFilterKey = 'all';
            });
          }
          
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
          tagColors: {}, // Empty map - no custom colors
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
          // 🔥 FIX: Force UI refresh immediately after creation
          setState(() {
            // This will trigger rebuild and update the filter bar
          });
          
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
    // Paywall 페이지로 바로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallPage()),
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
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _nameController.dispose();
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

  void _showCustomTagDialog() {
    final customTagController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF27272A), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF71717A), size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'CUSTOM TAG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Courier',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tag name label
                    const Text(
                      'NAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Tag name input
                    TextField(
                      controller: customTagController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                      decoration: const InputDecoration(
                        hintText: 'TAG NAME',
                        hintStyle: TextStyle(
                          color: Color(0xFF71717A),
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(color: Color(0xFF27272A), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(color: Color(0xFF0D59F2), width: 1.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Color(0xFF71717A),
                            fontFamily: 'Courier',
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () {
                          final tag = customTagController.text.trim().toUpperCase();
                          if (tag.isNotEmpty) {
                            setState(() {
                              _selectedTags.add(tag);
                              // No color stored - will use default blue neon style
                            });
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2962FF), Color(0xFF0039CB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2962FF).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'ADD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              fontFamily: 'Courier',
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A), // Black background (matching tactical style)
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF27272A), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF71717A), size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Text(
                      l10n.createRoutine.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Exercise count
                    Text(
                      '${widget.exerciseCount} EXERCISES',
                      style: const TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 11,
                        fontFamily: 'Courier',
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Routine name label
                    const Text(
                      'NAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier',
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Routine name input
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                      decoration: InputDecoration(
                        hintText: l10n.enterRoutineName,
                        hintStyle: const TextStyle(
                          color: Color(0xFF71717A),
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFF27272A), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFF0D59F2), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
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
                    
                    // System preset tags (Blue Neon Style)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RoutineTag.systemPresets.map((routineTag) {
                        final tag = routineTag.getLabel(context);
                        final isSelected = _selectedTags.contains(tag);
                        
                        return GestureDetector(
                          onTap: () => _toggleTag(tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF0D59F2).withValues(alpha: 0.2) 
                                  : const Color(0xFF1A1A1A),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF0D59F2) 
                                    : const Color(0xFF27272A),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0D59F2).withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF71717A),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontFamily: 'Courier',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Custom tag button
                    GestureDetector(
                      onTap: _showCustomTagDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF27272A), width: 1.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Color(0xFF71717A), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'CUSTOM TAG',
                              style: TextStyle(
                                color: Color(0xFF71717A),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Courier',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Selected tags display (with colors)
                    if (_selectedTags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _selectedTags.map((tag) {
                          // All custom tags use blue neon style
                          const color = Color(0xFF0D59F2);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _toggleTag(tag),
                                  child: Icon(Icons.close, size: 14, color: color),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF71717A),
                          fontFamily: 'Courier',
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save Button (Blue Gradient)
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {
                        final name = _nameController.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.pop(context, {
                            'name': name,
                            'tags': _selectedTags.toList(),
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2962FF), Color(0xFF0039CB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2962FF).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.save.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFamily: 'Courier',
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
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


// 🔥 Routine Filter Dialog
class _RoutineFilterDialog extends StatefulWidget {
  final String selectedTag;
  final List<String> availableTags;
  final Function(String) onApply;

  const _RoutineFilterDialog({
    required this.selectedTag,
    required this.availableTags,
    required this.onApply,
  });

  @override
  State<_RoutineFilterDialog> createState() => _RoutineFilterDialogState();
}

class _RoutineFilterDialogState extends State<_RoutineFilterDialog> {
  late String _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.selectedTag;
  }

  void _reset() {
    setState(() {
      _selectedTag = 'all';
    });
  }

  void _apply() {
    widget.onApply(_selectedTag);
    Navigator.pop(context);
  }

  // Helper to get localized tag label
  String _getLocalizedTag(String key, AppLocalizations l10n) {
    switch (key) {
      case 'all': return l10n.all;
      case 'push': return l10n.push.toUpperCase();
      case 'pull': return l10n.pull.toUpperCase();
      case 'legs': return l10n.legs.toUpperCase();
      case 'upper': return l10n.upper.toUpperCase();
      case 'lower': return l10n.lower.toUpperCase();
      case 'fullBody': return l10n.fullBody.toUpperCase();
      default: return key.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF27272A), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF71717A), size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.filterParameters.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      l10n.reset.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D59F2),
                        letterSpacing: 1.5,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section Header
                  Text(
                    l10n.selectExercise.toUpperCase(), // Using as "SELECT TAG"
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Courier',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tag Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.availableTags.map((tag) {
                      final isSelected = tag == _selectedTag;
                      final localizedLabel = _getLocalizedTag(tag, l10n);
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTag = tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF0D59F2).withValues(alpha: 0.2) 
                                : const Color(0xFF1A1A1A),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF0D59F2) 
                                  : const Color(0xFF27272A),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0D59F2).withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            localizedLabel,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF71717A),
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontFamily: 'Courier',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF71717A),
                          fontFamily: 'Courier',
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _apply,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2962FF), Color(0xFF0039CB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2962FF).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.applyFilters.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFamily: 'Courier',
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
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


// 🔥 Add Exercise Dialog
class _AddExerciseDialog extends StatefulWidget {
  const _AddExerciseDialog();

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedBodyPart = 'Chest';
  
  final List<String> _bodyParts = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Abs',
    'Cardio',
    'Etc',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Helper to get localized body part name
  String _getLocalizedBodyPart(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Chest': return l10n.chest;
      case 'Back': return l10n.back;
      case 'Legs': return l10n.legs;
      case 'Shoulders': return l10n.shoulders;
      case 'Arms': return l10n.arms;
      case 'Abs': return l10n.abs;
      case 'Cardio': return l10n.cardio;
      case 'Etc': return l10n.etc;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A), // 🎯 Darker background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF27272A), width: 1),
      ),
      title: Text(
        l10n.newExercise.toUpperCase(),
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
            // Exercise Name Input
            Text(
              l10n.exerciseNameLabel.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 40,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
              ),
              decoration: InputDecoration(
                hintText: l10n.exerciseNameHint,
                hintStyle: const TextStyle(
                  color: Color(0xFF71717A),
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A), // 🎯 Dark grey fill
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF27272A), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0xFF0D59F2), width: 1.5), // 🎯 Blue focus
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                counterStyle: const TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 11,
                  fontFamily: 'Courier',
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            
            // Muscle Group Selection
            Text(
              l10n.muscleGroupLabel.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            
            // Choice Chips - Tactical Blue Style
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bodyParts.map((bodyPart) {
                final isSelected = bodyPart == _selectedBodyPart;
                final localizedLabel = _getLocalizedBodyPart(bodyPart, l10n);
                return GestureDetector(
                  onTap: () => setState(() => _selectedBodyPart = bodyPart),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF0D59F2).withValues(alpha: 0.2) 
                          : const Color(0xFF1A1A1A),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF0D59F2) 
                            : const Color(0xFF27272A),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0D59F2).withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      localizedLabel.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF71717A),
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: 'Courier',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel Button (Subtle)
        TextButton(
          child: Text(
            l10n.cancel.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF71717A),
              fontFamily: 'Courier',
              letterSpacing: 1.0,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        // Save Button (Blue Gradient Glow)
        InkWell(
          onTap: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, {
                'name': name,
                'bodyPart': _selectedBodyPart,
              });
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF2962FF), Color(0xFF0039CB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2962FF).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              l10n.save.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFamily: 'Courier',
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

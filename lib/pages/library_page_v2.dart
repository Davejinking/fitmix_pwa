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
import 'shell_page.dart';
import 'exercise_selection_page_v2.dart';

class LibraryPageV2 extends StatefulWidget {
  const LibraryPageV2({super.key});

  @override
  State<LibraryPageV2> createState() => _LibraryPageV2State();
}

class _LibraryPageV2State extends State<LibraryPageV2> with SingleTickerProviderStateMixin {
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();
  late TabController _tabController;
  
  final List<String> _mainTabKeys = [
    'routines', 'favorites', 'chest', 'back', 'legs', 'shoulders', 'arms', 'abs', 'cardio', 'stretching', 'fullBody',
  ];
  
  final List<String> _equipmentFilterKeys = ['all', 'bodyweight', 'machine', 'barbell', 'dumbbell', 'cable', 'band'];
  String _selectedEquipmentKey = 'all';
  
  List<ExerciseLibraryItem> _allExercises = [];
  List<ExerciseLibraryItem> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;
  
  final Set<String> _bookmarkedIds = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mainTabKeys.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAllExercises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _applyFilter();
    }
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

  void _applyFilter() {
    final currentTabKey = _mainTabKeys[_tabController.index];
    
    setState(() {
      if (currentTabKey == 'routines') {
        // Routines tab - don't filter exercises
        _filteredExercises = [];
      } else if (currentTabKey == 'favorites') {
        _filteredExercises = _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
      } else {
        _filteredExercises = _allExercises.where((ex) => ex.targetPart.toLowerCase() == currentTabKey.toLowerCase()).toList();
      }
      
      if (_selectedEquipmentKey != 'all' && currentTabKey != 'routines') {
        _filteredExercises = _filteredExercises.where((ex) => ex.equipmentType.toLowerCase() == _selectedEquipmentKey.toLowerCase()).toList();
      }
      
      if (_searchQuery.isNotEmpty && currentTabKey != 'routines') {
        _filteredExercises = _filteredExercises.where((ex) => ex.getLocalizedName(context).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
    });
  }
  
  String _getTabLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'routines': return l10n.routines;
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
  
  String _getEquipmentLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'all': return l10n.all;
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
      if (_mainTabKeys[_tabController.index] == 'favorites') _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentTabKey = _mainTabKeys[_tabController.index];
    final isRoutinesTab = currentTabKey == 'routines';
    
    return Column(
      children: [
        if (!isRoutinesTab) _buildSearchBar(l10n),
        _buildBodyPartTabs(l10n),
        if (!isRoutinesTab) _buildEquipmentFilter(l10n),
        Expanded(child: isRoutinesTab ? _buildRoutinesList(l10n) : _buildExerciseList(l10n)),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchExercise,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93), size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, color: Color(0xFF8E8E93)), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; _applyFilter(); }); })
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[800]!, width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2)),
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
        ),
        style: const TextStyle(fontSize: 15, color: Colors.white),
        onChanged: (query) { setState(() { _searchQuery = query; _applyFilter(); }); },
      ),
    );
  }

  Widget _buildBodyPartTabs(AppLocalizations l10n) {
    return Container(
      color: const Color(0xFF121212),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF2196F3),
        unselectedLabelColor: const Color(0xFF8E8E93),
        indicatorColor: const Color(0xFF2196F3),
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        tabAlignment: TabAlignment.start,
        tabs: _mainTabKeys.map((key) => Tab(text: _getTabLabel(l10n, key))).toList(),
      ),
    );
  }

  Widget _buildEquipmentFilter(AppLocalizations l10n) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF121212),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _equipmentFilterKeys.length,
        itemBuilder: (context, index) {
          final key = _equipmentFilterKeys[index];
          final isSelected = key == _selectedEquipmentKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getEquipmentLabel(l10n, key), style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF8E8E93))),
              selected: isSelected,
              onSelected: (_) { setState(() { _selectedEquipmentKey = key; _applyFilter(); }); },
              backgroundColor: Colors.transparent,
              selectedColor: const Color(0xFF2196F3),
              checkmarkColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? const Color(0xFF2196F3) : const Color(0xFF8E8E93), width: 1.5)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList(AppLocalizations l10n) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
    if (_error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 48, color: Colors.red), const SizedBox(height: 16), Text(l10n.errorOccurred(_error!), style: const TextStyle(color: Colors.white)), const SizedBox(height: 16), ElevatedButton(onPressed: _loadAllExercises, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)), child: Text(l10n.retry))]));
    if (_filteredExercises.isEmpty) return Center(child: Text(l10n.noExercises, style: TextStyle(color: Colors.grey[600], fontSize: 16)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        final isBookmarked = _bookmarkedIds.contains(exercise.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), 
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
                    color: const Color(0xFF2196F3).withValues(alpha: 0.15), 
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFF2196F3), size: 18),
                ),
                const SizedBox(width: 12),
                // 운동 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.getLocalizedName(context), 
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getLocalizedBodyPart(exercise.targetPart)} • ${_getLocalizedEquipment(exercise.equipmentType)}', 
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])
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
                      color: Colors.grey[500],
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
                      color: isBookmarked ? const Color(0xFF2196F3) : Colors.grey[600], 
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
        final routines = box.values.toList()
          ..sort((a, b) {
            final aTime = a.lastUsedAt ?? a.createdAt;
            final bTime = b.lastUsedAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });

        return Column(
          children: [
            // "새 루틴 만들기" 버튼
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createNewRoutine,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    l10n.createRoutine.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noRoutines,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.createRoutineHint,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
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
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        routine.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.exerciseCount(routine.exercises.length),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Edit button
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: Colors.grey[400]),
                                  onPressed: () => _editRoutine(routine),
                                ),
                                // Delete button
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
                                  onPressed: () => _deleteRoutine(routine, l10n),
                                ),
                              ],
                            ),
                            // 🔥 운동 목록 표시
                            if (routine.exercises.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    print('🔍 [UI] Displaying routine "${routine.name}" with ${routine.exercises.length} exercises');
                                    for (var i = 0; i < routine.exercises.length; i++) {
                                      print('  [$i] ${routine.exercises[i].name}');
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...routine.exercises.take(3).map((exercise) => Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.fitness_center,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  exercise.name,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[300],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                        if (routine.exercises.length > 3)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '+${routine.exercises.length - 3} more',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Load button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _loadRoutine(routine, l10n),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  l10n.loadRoutine.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
        backgroundColor: Colors.grey[900],
        title: Text(
          l10n.loadRoutine,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.loadThisRoutine,
          style: const TextStyle(color: Colors.white70),
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
                color: Color(0xFF2196F3),
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
        backgroundColor: Colors.grey[900],
        title: Text(
          l10n.deleteRoutine,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${l10n.deleteRoutine} "${routine.name}"?',
          style: const TextStyle(color: Colors.white70),
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

    // Step 2: Enter routine name
    String routineName = "";
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            l10n.createRoutine.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
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
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.enterRoutineName,
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
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
                  color: Color(0xFF2196F3),
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
        print('🔍 [CREATE] Selected exercises count: ${selected.length}');
        for (var i = 0; i < selected.length; i++) {
          print('  [$i] ${selected[i].name}');
        }
        
        final routine = Routine(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: routineName,
          exercises: selected.map((e) => e.copyWith()).toList(),
        );
        
        print('🔍 [CREATE] Routine created with ${routine.exercises.length} exercises');
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
          backgroundColor: Colors.grey[900],
          title: Text(
            l10n.editRoutine.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
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
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: TextEditingController(text: routineName),
                decoration: InputDecoration(
                  hintText: l10n.enterRoutineName,
                  hintStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
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
                  color: Color(0xFF2196F3),
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
          backgroundColor: Colors.grey[900],
          title: Text(
            l10n.routineLimitReached.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
            ),
          ),
          content: Text(
            l10n.routineLimitMessage(SubscriptionLimits.freeRoutineLimit),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                l10n.cancel.toUpperCase(),
                style: TextStyle(color: Colors.grey[400]),
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
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

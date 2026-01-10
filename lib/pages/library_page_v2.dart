import 'package:flutter/material.dart';
import '../services/exercise_seeding_service.dart';
import '../models/exercise_library.dart';
import '../l10n/app_localizations.dart';
import '../pages/exercise_detail_page.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';

class LibraryPageV2 extends StatefulWidget {
  final SessionRepo? sessionRepo;
  final ExerciseLibraryRepo? exerciseRepo;

  const LibraryPageV2({
    super.key,
    this.sessionRepo,
    this.exerciseRepo,
  });

  @override
  State<LibraryPageV2> createState() => _LibraryPageV2State();
}

class _LibraryPageV2State extends State<LibraryPageV2> with SingleTickerProviderStateMixin {
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();
  late TabController _tabController;
  
  final List<String> _mainTabKeys = [
    'favorites', 'chest', 'back', 'legs', 'shoulders', 'arms', 'abs', 'cardio', 'stretching', 'fullBody',
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
      if (currentTabKey == 'favorites') {
        _filteredExercises = _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
      } else {
        _filteredExercises = _allExercises.where((ex) => ex.targetPart.toLowerCase() == currentTabKey.toLowerCase()).toList();
      }
      
      if (_selectedEquipmentKey != 'all') {
        _filteredExercises = _filteredExercises.where((ex) => ex.equipmentType.toLowerCase() == _selectedEquipmentKey.toLowerCase()).toList();
      }
      
      if (_searchQuery.isNotEmpty) {
        _filteredExercises = _filteredExercises.where((ex) => ex.getLocalizedName(context).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
    });
  }
  
  String _getTabLabel(AppLocalizations l10n, String key) {
    switch (key) {
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
    
    return Column(
      children: [
        _buildHeader(l10n),
        _buildSearchBar(l10n),
        _buildBodyPartTabs(l10n),
        _buildEquipmentFilter(l10n),
        Expanded(child: _buildExerciseList(l10n)),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final canPop = Navigator.of(context).canPop();
    
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        color: const Color(0xFF121212),
        child: Row(
          children: [
            if (canPop) IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            if (canPop) const SizedBox(width: 8),
            Text(l10n.library, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
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
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.exerciseSelected(exercise.getLocalizedName(context))), backgroundColor: const Color(0xFF2196F3)));
            },
            borderRadius: BorderRadius.circular(10),
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
                  // 운동 상세 정보 버튼 (i)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailPage(
                            exerciseName: exercise.nameEn, // nameEn 사용
                            sessionRepo: widget.sessionRepo,
                            exerciseRepo: widget.exerciseRepo,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
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
          ),
        );
      },
    );
  }
}
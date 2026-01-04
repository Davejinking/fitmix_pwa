import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_library.dart';
import '../services/exercise_seeding_service.dart';
import '../l10n/app_localizations.dart';

class ExerciseSelectionPageV2 extends StatefulWidget {
  const ExerciseSelectionPageV2({super.key});
  @override
  State<ExerciseSelectionPageV2> createState() => _ExerciseSelectionPageV2State();
}

class _ExerciseSelectionPageV2State extends State<ExerciseSelectionPageV2> with SingleTickerProviderStateMixin {
  final ExerciseSeedingService _seedingService = ExerciseSeedingService();
  late TabController _tabController;
  final List<String> _mainTabKeys = ['favorites', 'chest', 'back', 'legs', 'shoulders', 'arms', 'abs', 'cardio', 'stretching', 'fullBody'];
  final List<String> _equipmentFilterKeys = ['all', 'bodyweight', 'machine', 'barbell', 'dumbbell', 'cable', 'band'];
  String _selectedEquipmentKey = 'all';
  List<ExerciseLibraryItem> _allExercises = [];
  List<ExerciseLibraryItem> _filteredExercises = [];
  final List<Exercise> _selectedExercises = [];
  final Set<String> _bookmarkedIds = {};
  bool _isLoading = false;
  String? _error;
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

  void _onTabChanged() { if (_tabController.indexIsChanging) _applyFilter(); }

  Future<void> _loadAllExercises() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await _seedingService.initializeAndSeed();
      final exercises = await _seedingService.getAllExercises();
      if (mounted) { setState(() { _allExercises = exercises; _isLoading = false; }); _applyFilter(); }
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _isLoading = false; }); }
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

  void _toggleExercise(ExerciseLibraryItem item) {
    final name = item.getLocalizedName(context);
    setState(() {
      final idx = _selectedExercises.indexWhere((e) => e.name == name);
      if (idx >= 0) { _selectedExercises.removeAt(idx); }
      else { _selectedExercises.add(Exercise(name: name, bodyPart: _getLocalizedBodyPart(item.targetPart))); }
    });
  }

  bool _isSelected(ExerciseLibraryItem item) => _selectedExercises.any((e) => e.name == item.getLocalizedName(context));

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedIds.contains(id)) { _bookmarkedIds.remove(id); } else { _bookmarkedIds.add(id); }
      if (_mainTabKeys[_tabController.index] == 'favorites') _applyFilter();
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

  String _getLocalizedBodyPart(String part) {
    final l10n = AppLocalizations.of(context);
    switch (part.toLowerCase()) {
      case 'chest': return l10n.chest;
      case 'back': return l10n.back;
      case 'legs': return l10n.legs;
      case 'shoulders': return l10n.shoulders;
      case 'arms': return l10n.arms;
      case 'abs': return l10n.abs;
      case 'cardio': return l10n.cardio;
      case 'stretching': return l10n.stretching;
      case 'fullbody': return l10n.fullBody;
      default: return part;
    }
  }

  String _getLocalizedEquipment(String eq) {
    final l10n = AppLocalizations.of(context);
    switch (eq.toLowerCase()) {
      case 'barbell': return l10n.barbell;
      case 'dumbbell': return l10n.dumbbell;
      case 'machine': return l10n.machine;
      case 'cable': return l10n.cable;
      case 'bodyweight': return l10n.bodyweight;
      case 'band': return l10n.band;
      default: return eq;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(children: [
        _buildHeader(l10n),
        _buildSearchBar(l10n),
        _buildBodyPartTabs(l10n),
        _buildEquipmentFilter(l10n),
        Expanded(child: _buildExerciseList(l10n)),
      ]),
      bottomNavigationBar: _selectedExercises.isEmpty ? null : _buildBottomBar(l10n),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF121212),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 8),
          Text(l10n.selectExercise, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          if (_selectedExercises.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(16)),
              child: Text('\${_selectedExercises.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
        ]),
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
          hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93)),
          suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Color(0xFF8E8E93)), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; _applyFilter(); }); }) : null,
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (q) { setState(() { _searchQuery = q; _applyFilter(); }); },
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
        tabAlignment: TabAlignment.start,
        tabs: _mainTabKeys.map((k) => Tab(text: _getTabLabel(l10n, k))).toList(),
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
        itemBuilder: (ctx, i) {
          final k = _equipmentFilterKeys[i];
          final sel = k == _selectedEquipmentKey;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getEquipmentLabel(l10n, k), style: TextStyle(color: sel ? Colors.white : const Color(0xFF8E8E93))),
              selected: sel,
              onSelected: (_) { setState(() { _selectedEquipmentKey = k; _applyFilter(); }); },
              backgroundColor: Colors.transparent,
              selectedColor: const Color(0xFF2196F3),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: sel ? const Color(0xFF2196F3) : const Color(0xFF8E8E93))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList(AppLocalizations l10n) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
    if (_error != null) return Center(child: Text('Error: \$_error', style: const TextStyle(color: Colors.red)));
    if (_filteredExercises.isEmpty) return Center(child: Text(l10n.noExercises, style: TextStyle(color: Colors.grey[600])));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredExercises.length,
      itemBuilder: (ctx, i) {
        final ex = _filteredExercises[i];
        final sel = _isSelected(ex);
        final bm = _bookmarkedIds.contains(ex.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF2196F3).withValues(alpha: 0.1) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: sel ? Border.all(color: const Color(0xFF2196F3), width: 2) : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: const Color(0xFF2196F3).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.fitness_center, color: Color(0xFF2196F3)),
            ),
            title: Text(ex.getLocalizedName(context), style: TextStyle(fontWeight: FontWeight.w600, color: sel ? const Color(0xFF2196F3) : Colors.white)),
            subtitle: Text('\${_getLocalizedBodyPart(ex.targetPart)} • \${_getLocalizedEquipment(ex.equipmentType)}', style: TextStyle(color: Colors.grey[500])),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: Icon(bm ? Icons.bookmark : Icons.bookmark_border, color: bm ? const Color(0xFF2196F3) : Colors.grey[600]), onPressed: () => _toggleBookmark(ex.id)),
              Icon(sel ? Icons.check_circle : Icons.add_circle_outline, color: sel ? const Color(0xFF2196F3) : Colors.grey[600]),
            ]),
            onTap: () => _toggleExercise(ex),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF121212), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedExercises),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(l10n.addExercises(_selectedExercises.length), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}

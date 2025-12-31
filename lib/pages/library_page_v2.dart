import 'package:flutter/material.dart';
import '../services/exercise_db_service.dart';
import '../models/exercise_db.dart';
import '../l10n/app_localizations.dart';
import '../data/exercise_library_repo.dart';
import 'exercise_detail_page.dart';

class LibraryPageV2 extends StatefulWidget {
  const LibraryPageV2({super.key});

  @override
  State<LibraryPageV2> createState() => _LibraryPageV2State();
}

class _LibraryPageV2State extends State<LibraryPageV2> with SingleTickerProviderStateMixin {
  final ExerciseDBService _service = ExerciseDBService();
  final ExerciseLibraryRepo _customRepo = HiveExerciseLibraryRepo();
  late TabController _tabController;
  
  // 메인 탭 키 (i18n용)
  final List<String> _mainTabKeys = [
    'favorites',
    'chest',
    'back',
    'legs',
    'shoulders',
    'arms',
    'abs',
    'cardio',
    'stretching',
    'fullBody',
  ];
  
  // 탭 키 -> API bodyPart 매핑
  final Map<String, List<String>> _tabToBodyPartMapping = {
    'favorites': [], // 북마크된 운동만 표시
    'chest': ['chest'],
    'back': ['back'],
    'legs': ['lower legs', 'upper legs'],
    'shoulders': ['shoulders'],
    'arms': ['lower arms', 'upper arms'],
    'abs': ['waist'],
    'cardio': ['cardio'],
    'stretching': ['neck'],
    'fullBody': ['cardio'], // 전신 운동 (기존 역도 포함)
  };
  
  // 장비 필터 키 (i18n용)
  final List<String> _equipmentFilterKeys = ['all', 'bodyweight', 'machine', 'barbell', 'dumbbell', 'cable', 'band'];
  String _selectedEquipmentKey = 'all';
  
  List<ExerciseDB> _allExercises = []; // API + 커스텀 운동 전체
  List<ExerciseDB> _exercises = []; // 탭 필터링된 운동
  List<ExerciseDB> _filteredExercises = []; // 탭 + 장비 필터링된 운동
  bool _isLoading = false;
  String? _error;
  
  // 북마크된 운동 ID
  final Set<String> _bookmarkedIds = {};

  bool _isInitArgHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitArgHandled) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        final targetKey = _mapBodyPartToTabKey(args);
        final index = _mainTabKeys.indexOf(targetKey);
        if (index != -1) {
          _tabController.animateTo(index);
        }
      }
      _isInitArgHandled = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mainTabKeys.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initRepo();
  }
  
  Future<void> _initRepo() async {
    await _customRepo.init();
    await _loadAllExercises(); // 전체 데이터 로드 (API + 커스텀)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadExercises();
    }
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentTabKey = _mainTabKeys[_tabController.index];
      
      // 즐겨찾기 탭인 경우
      if (currentTabKey == 'favorites') {
        setState(() {
          _exercises = _allExercises.where((ex) => _bookmarkedIds.contains(ex.id)).toList();
          _applyFilter();
          _isLoading = false;
        });
        return;
      }
      
      // 1단계 필터링: 탭에 따른 부위 필터링
      final bodyParts = _tabToBodyPartMapping[currentTabKey] ?? [];
      final tabFiltered = _allExercises.where((exercise) {
        return bodyParts.contains(exercise.bodyPart);
      }).toList();
      
      setState(() {
        _exercises = tabFiltered;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // 로컬 JSON 데이터와 커스텀 운동 병합
  Future<void> _loadAllExercises() async {
    try {
      // 1. 로컬 JSON에서 모든 운동 데이터 가져오기
      List<ExerciseDB> apiExercises = [];
      try {
        apiExercises = await _service.getAllExercises(limit: 1300);
        print('✅ 로컬 JSON에서 ${apiExercises.length}개의 운동 데이터를 로드했습니다.');
      } catch (e) {
        print('⚠️ 로컬 JSON 로드 실패, 커스텀 운동만 사용: $e');
      }
      
      // 2. 로컬 커스텀 운동 가져오기
      final customExercises = await _loadCustomExercises();
      
      // 3. 병합 (커스텀 운동을 앞에 배치)
      setState(() {
        _allExercises = [...customExercises, ...apiExercises];
      });
      
      // 4. 현재 탭에 맞는 운동 로드
      await _loadExercises();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  // 로컬 커스텀 운동 로드
  Future<List<ExerciseDB>> _loadCustomExercises() async {
    try {
      final library = await _customRepo.getLibrary();
      final List<ExerciseDB> customExercises = [];
      
      // 한글 부위 -> 영어 bodyPart 매핑
      final koToEn = {
        '가슴': 'chest',
        '등': 'back',
        '하체': 'lower legs',
        '어깨': 'shoulders',
        '팔': 'lower arms',
        '복근': 'waist',
        '유산소': 'cardio',
        '스트레칭': 'neck',
        '전신': 'cardio',
      };
      
      for (final entry in library.entries) {
        final bodyPartKo = entry.key;
        final bodyPartEn = koToEn[bodyPartKo] ?? 'cardio';
        
        for (final exerciseName in entry.value) {
          customExercises.add(ExerciseDB.custom(
            name: exerciseName,
            bodyPart: bodyPartEn,
          ));
        }
      }
      
      return customExercises;
    } catch (e) {
      print('커스텀 운동 로드 실패: $e');
      return [];
    }
  }
  
  // 커스텀 운동 추가
  Future<void> _addCustomExercise(String name, String bodyPart, String equipment) async {
    try {
      // 영어 bodyPart -> 한글 매핑
      final enToKo = {
        'chest': '가슴',
        'back': '등',
        'lower legs': '하체',
        'upper legs': '하체',
        'shoulders': '어깨',
        'lower arms': '팔',
        'upper arms': '팔',
        'waist': '복근',
        'cardio': '유산소',
        'neck': '스트레칭',
      };
      
      final bodyPartKo = enToKo[bodyPart] ?? '전신';
      await _customRepo.addExercise(bodyPartKo, name);
      
      // 리스트 새로고침
      await _loadAllExercises();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name 운동이 추가되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 추가 실패: $e')),
        );
      }
    }
  }

  // 2단계 필터링: 장비 필터 적용
  void _applyFilter() {
    if (_selectedEquipmentKey == 'all') {
      _filteredExercises = _exercises;
    } else {
      final equipmentEn = _getEquipmentEn(_selectedEquipmentKey);
      _filteredExercises = _exercises.where((ex) => ex.equipment == equipmentEn).toList();
    }
  }

  String _mapBodyPartToTabKey(String koPart) {
    const map = {
      '가슴': 'chest',
      '등': 'back',
      '하체': 'legs',
      '어깨': 'shoulders',
      '팔': 'arms',
      '복근': 'abs',
      '유산소': 'cardio',
      '스트레칭': 'stretching',
      '전신': 'fullBody',
    };
    return map[koPart] ?? 'chest';
  }

  String _getEquipmentEn(String key) {
    const map = {
      'bodyweight': 'body weight',
      'machine': 'machine',
      'barbell': 'barbell',
      'dumbbell': 'dumbbell',
      'cable': 'cable',
      'band': 'resistance band',
    };
    return map[key] ?? key;
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

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
  }
  
  // 커스텀 운동 추가 다이얼로그
  void _showAddCustomExerciseDialog(AppLocalizations l10n) {
    final nameController = TextEditingController();
    String selectedBodyPart = 'chest';
    String selectedEquipment = 'body weight';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addCustomExercise),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 운동 이름 입력
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.customExerciseName,
                    hintText: l10n.pleaseEnterExerciseName,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                
                // 부위 선택
                Text(
                  l10n.selectBodyPart,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedBodyPart,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: 'chest', child: Text(l10n.chest)),
                    DropdownMenuItem(value: 'back', child: Text(l10n.back)),
                    DropdownMenuItem(value: 'lower legs', child: Text(l10n.legs)),
                    DropdownMenuItem(value: 'shoulders', child: Text(l10n.shoulders)),
                    DropdownMenuItem(value: 'lower arms', child: Text(l10n.arms)),
                    DropdownMenuItem(value: 'waist', child: Text(l10n.abs)),
                    DropdownMenuItem(value: 'cardio', child: Text(l10n.cardio)),
                    DropdownMenuItem(value: 'neck', child: Text(l10n.stretching)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedBodyPart = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // 장비 선택
                Text(
                  l10n.selectEquipment,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedEquipment,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: 'body weight', child: Text(l10n.bodyweight)),
                    DropdownMenuItem(value: 'machine', child: Text(l10n.machine)),
                    DropdownMenuItem(value: 'barbell', child: Text(l10n.barbell)),
                    DropdownMenuItem(value: 'dumbbell', child: Text(l10n.dumbbell)),
                    DropdownMenuItem(value: 'cable', child: Text(l10n.cable)),
                    DropdownMenuItem(value: 'resistance band', child: Text(l10n.band)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedEquipment = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pleaseEnterExerciseName)),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                await _addCustomExercise(name, selectedBodyPart, selectedEquipment);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        // 헤더
        _buildHeader(l10n),
        // 검색바
        _buildSearchBar(l10n),
        // 부위 탭
        _buildBodyPartTabs(),
        // 장비 필터
        _buildEquipmentFilter(),
        // 운동 목록
        Expanded(
          child: _buildExerciseList(),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    // 독립적인 라우트로 호출된 경우 뒤로가기 버튼 표시
    final canPop = Navigator.of(context).canPop();
    
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (canPop)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                if (canPop) const SizedBox(width: 8),
                const Text(
                  '라이브러리',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                  onPressed: () => _showAddCustomExerciseDialog(l10n),
                  tooltip: l10n.addCustomExercise,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.searchExercise,
          hintStyle: const TextStyle(
            color: Color(0xFF8E8E93), // 더 밝은 회색
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF8E8E93), // 더 밝은 회색
            size: 22,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[800]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4A9EFF), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        onSubmitted: (query) async {
          // TODO: 검색 기능
        },
      ),
    );
  }

  Widget _buildBodyPartTabs() {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.only(top: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF007AFF),
        unselectedLabelColor: const Color(0xFF8E8E93),
        indicatorColor: const Color(0xFF007AFF),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        tabAlignment: TabAlignment.start,
        tabs: _mainTabKeys.map((key) => Tab(text: _getTabLabel(l10n, key))).toList(),
      ),
    );
  }

  Widget _buildEquipmentFilter() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _equipmentFilterKeys.length,
        itemBuilder: (context, index) {
          final equipmentKey = _equipmentFilterKeys[index];
          final isSelected = equipmentKey == _selectedEquipmentKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(
                _getEquipmentLabel(l10n, equipmentKey),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF8E8E93),
                  letterSpacing: 0.2,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedEquipmentKey = equipmentKey;
                  _applyFilter();
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: const Color(0xFF007AFF),
              checkmarkColor: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF007AFF) 
                      : const Color(0xFF8E8E93),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList() {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A9EFF),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred(_error!),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExercises,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9EFF),
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_filteredExercises.isEmpty) {
      return Center(
        child: Text(
          l10n.noExercises,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        final isBookmarked = _bookmarkedIds.contains(exercise.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                // 운동 상세 페이지로 이동
                final result = await Navigator.of(context).push<ExerciseDB>(
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(exercise: exercise),
                  ),
                );
                
                // 운동이 선택되어 돌아온 경우 처리
                if (result != null) {
                  // 운동 계획에 추가하는 로직은 나중에 구현
                  if (mounted) {
                    final locale = l10n.localeName;
                    final message = locale == 'ja' 
                        ? '${result.name} 運動が選択されました。'
                        : locale == 'en' 
                        ? '${result.name} exercise has been selected.'
                        : '${result.name} 운동이 선택되었습니다.';
                        
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: const Color(0xFF4A9EFF),
                      ),
                    );
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // 운동 이미지 또는 아이콘
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: exercise.isCustom || exercise.gifUrl.isEmpty
                          ? Container(
                              width: 90,
                              height: 68,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A9EFF).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Color(0xFF4A9EFF),
                                size: 36,
                              ),
                            )
                          : Image.network(
                              exercise.gifUrl,
                              width: 90,
                              height: 68,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 90,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(width: 16),
                    // 운동 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.getLocalizedName(l10n.localeName),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.3,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (exercise.isCustom)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A9EFF).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF4A9EFF).withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    '커스텀',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF4A9EFF),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${exercise.getTargetPart(l10n.localeName)} | ${exercise.getEquipmentType(l10n.localeName)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 북마크 버튼
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? const Color(0xFF4A9EFF) : Colors.grey[600],
                        size: 24,
                      ),
                      onPressed: () => _toggleBookmark(exercise.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

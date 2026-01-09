import 'package:flutter/material.dart';
import '../models/exercise_db.dart';
import '../l10n/app_localizations.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';

class ExerciseDetailPage extends StatefulWidget {
  final String exerciseName;
  final SessionRepo? sessionRepo;
  final ExerciseLibraryRepo? exerciseRepo;

  const ExerciseDetailPage({
    super.key,
    required this.exerciseName,
    this.sessionRepo,
    this.exerciseRepo,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  List<ExerciseHistoryRecord> _recentHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadRecentHistory();
  }

  Future<void> _loadRecentHistory() async {
    if (widget.sessionRepo == null) {
      setState(() => _isLoadingHistory = false);
      return;
    }

    try {
      final history = await widget.sessionRepo!.getRecentExerciseHistory(widget.exerciseName);
      if (mounted) {
        setState(() {
          _recentHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final localizedName = ExerciseDB.getExerciseNameLocalized(widget.exerciseName, locale);
    final bodyPart = 'chest'; // 임시로 고정값 사용
    final localizedBodyPart = ExerciseDB.getBodyPartLocalized(bodyPart, locale);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // 히어로 섹션 (Visual)
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: null, // 타이틀을 body에서 처리
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A1D29),
                      const Color(0xFF0A0A0A),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // 배경 이미지 (은은하게)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1D29).withValues(alpha: 0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 120,
                            color: Color(0xFF4A9EFF),
                          ),
                        ),
                      ),
                    ),
                    // 그라데이션 오버레이
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0A0A0A).withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 메인 콘텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 (중앙 정렬)
                  Center(
                    child: Column(
                      children: [
                        // 태그 (바벨, 가슴)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTag('바벨'),
                            const SizedBox(width: 8),
                            _buildTag(localizedBodyPart),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 운동 이름
                        Text(
                          localizedName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // 마이 레코드 (Card-in-Card 구조 개선)
                  _buildMyRecords(),
                  const SizedBox(height: 24),
                  
                  // 최근 기록
                  _buildRecentHistory(),
                  const SizedBox(height: 24),
                  
                  // 운동 설명 (아코디언)
                  _buildInstructionsAccordion(),
                  const SizedBox(height: 24),
                  
                  // 타겟 근육
                  _buildTargetMuscles(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A9EFF).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A9EFF).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A9EFF),
        ),
      ),
    );
  }

  Widget _buildMyRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '마이 레코드',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // 3개 박스를 바로 배치 (Card-in-Card 구조 제거)
        Row(
          children: [
            Expanded(
              child: _buildRecordCard('최고 중량', '100kg', const Color(0xFF4A9EFF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRecordCard('최고 볼륨', '4980kg', const Color(0xFFFF6B35)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRecordCard('총 세션', '24회', const Color(0xFF00C853)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 기록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingHistory)
          const Center(child: CircularProgressIndicator())
        else if (_recentHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D29),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '기록이 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ),
          )
        else
          Column(
            children: _recentHistory.map((record) => _buildHistoryCard(record)).toList(),
          ),
      ],
    );
  }

  Widget _buildHistoryCard(ExerciseHistoryRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 날짜 (배경색 제거, 텍스트만 강조)
          Text(
            record.formattedDate,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A9EFF),
            ),
          ),
          const SizedBox(width: 16),
          
          // 세트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.sets.length}세트',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: record.sets.map((set) => Text(
                    '${set.weight}kg × ${set.reps}회',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          
          // 총 볼륨
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.totalVolume.toStringAsFixed(0)}kg',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '총 볼륨',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          
          // 화살표 (중앙 정렬)
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsAccordion() {
    return ExpansionTile(
      title: const Text(
        '운동 방법',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      iconColor: const Color(0xFF4A9EFF),
      collapsedIconColor: Colors.grey[400],
      backgroundColor: const Color(0xFF1A1D29),
      collapsedBackgroundColor: const Color(0xFF1A1D29),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. 벤치에 등을 대고 누워 바벨을 어깨 너비로 잡습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '2. 바벨을 가슴 중앙으로 천천히 내립니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '3. 가슴 근육을 수축시키며 바벨을 위로 밀어 올립니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[300],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetMuscles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '타겟 근육',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D29),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    color: Color(0xFF4A9EFF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '주요 근육',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '가슴',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '보조 근육',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[300],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '어깨, 삼두',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../models/exercise_db.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/session_repo.dart';
import '../../../data/exercise_library_repo.dart';
import '../../../core/iron_theme.dart';

class ExerciseDetailModal extends StatefulWidget {
  final String exerciseName;
  final SessionRepo? sessionRepo;
  final ExerciseLibraryRepo? exerciseRepo;

  const ExerciseDetailModal({
    super.key,
    required this.exerciseName,
    this.sessionRepo,
    this.exerciseRepo,
  });

  @override
  State<ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends State<ExerciseDetailModal> {
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
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: IronTheme.textMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 태그들
                      Row(
                        children: [
                          _buildTag('바벨'),
                          const SizedBox(width: 8),
                          _buildTag(localizedBodyPart),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 운동 이름
                      Text(
                        localizedName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: IronTheme.textHigh,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: IronTheme.textHigh),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // 스크롤 가능한 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 마이 레코드
                  _buildMyRecords(),
                  const SizedBox(height: 24),
                  
                  // 최근 기록
                  _buildRecentHistory(),
                  const SizedBox(height: 24),
                  
                  // 운동 설명
                  _buildInstructionsAccordion(),
                  const SizedBox(height: 24),
                  
                  // 타겟 근육
                  _buildTargetMuscles(),
                  const SizedBox(height: 40),
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
        color: IronTheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: IronTheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: IronTheme.primary,
        ),
      ),
    );
  }

  Widget _buildMyRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '마이 레코드',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: IronTheme.textHigh,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildRecordCard('최고 중량', '100kg', IronTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRecordCard('최고 볼륨', '4980kg', IronTheme.secondary),
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
        color: IronTheme.background,
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
              color: IronTheme.textMedium,
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
        Text(
          '최근 기록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: IronTheme.textHigh,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingHistory)
          const Center(child: CircularProgressIndicator())
        else if (_recentHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: IronTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '기록이 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: IronTheme.textMedium,
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
        color: const Color(0xFF1E1E1E), // Obsidian dark background
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF3B82F6), // Blue accent strip (Obsidian style)
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Summary Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${record.sets.length}세트 · ${record.totalVolume.toStringAsFixed(0)}kg',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Body: The Memo (Hero Section)
          if (record.memo != null && record.memo!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: _parseMemoWithHashtags(record.memo!),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            const SizedBox(height: 8),
          ],
          
          // Footer: Set Details (Subtle)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              record.sets.map((set) => '${set.weight}kg × ${set.reps}회').join(', '),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Parse memo text and highlight hashtags
  List<TextSpan> _parseMemoWithHashtags(String text) {
    final words = text.split(' ');
    final spans = <TextSpan>[];
    
    for (var word in words) {
      if (word.startsWith('#')) {
        // Highlight hashtags in cyan/gold
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(
            color: Color(0xFF64FFDA), // Cyan accent (Obsidian style)
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        // Normal text
        spans.add(TextSpan(
          text: '$word ',
          style: TextStyle(
            color: Colors.grey[300],
          ),
        ));
      }
    }
    
    return spans;
  }

  Widget _buildInstructionsAccordion() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          '운동 방법',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: IronTheme.textHigh,
          ),
        ),
        iconColor: IronTheme.primary,
        collapsedIconColor: IronTheme.textMedium,
        backgroundColor: IronTheme.background,
        collapsedBackgroundColor: IronTheme.background,
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
                    color: IronTheme.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '2. 바벨을 가슴 중앙으로 천천히 내립니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: IronTheme.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '3. 가슴 근육을 수축시키며 바벨을 위로 밀어 올립니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: IronTheme.textMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetMuscles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '타겟 근육',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: IronTheme.textHigh,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: IronTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    color: IronTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '주요 근육',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: IronTheme.textHigh,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '가슴',
                    style: TextStyle(
                      fontSize: 14,
                      color: IronTheme.textMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    color: IronTheme.textMedium,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '보조 근육',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: IronTheme.textMedium,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '어깨, 삼두',
                    style: TextStyle(
                      fontSize: 14,
                      color: IronTheme.textMedium,
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

// 모달을 띄우는 헬퍼 함수
void showExerciseDetailModal(
  BuildContext context, {
  required String exerciseName,
  SessionRepo? sessionRepo,
  ExerciseLibraryRepo? exerciseRepo,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ExerciseDetailModal(
      exerciseName: exerciseName,
      sessionRepo: sessionRepo,
      exerciseRepo: exerciseRepo,
    ),
  );
}

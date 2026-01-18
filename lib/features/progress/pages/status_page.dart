import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/iron_theme.dart';
import '../../../models/user_profile.dart';
import '../../../models/session.dart';
import '../../../services/stats_calculator.dart';
import '../../../core/profile_session_loader.dart';

/// RPG 스타일 캐릭터 스테이터스 페이지
class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  
  UserProfile? _profile;
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await loadProfileSessionData();
    if (mounted) {
      setState(() {
        _profile = data.profile;
        _sessions = data.sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: IronTheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalVolume = StatsCalculator.calculateTotalVolume(_sessions);
    final level = StatsCalculator.calculateLevel(totalVolume);
    final levelProgress = StatsCalculator.levelProgress(totalVolume);
    final bigThree = StatsCalculator.calculateBigThree(_sessions);
    final bodyPartVolumes = StatsCalculator.calculateBodyPartVolumes(_sessions);
    final exerciseStats = StatsCalculator.calculateExerciseStats(_sessions);

    return Scaffold(
      backgroundColor: IronTheme.background,
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverAppBar(
            backgroundColor: IronTheme.background,
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'STATUS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 레벨 & 이름
                  _buildLevelHeader(level, levelProgress),
                  const SizedBox(height: 24),
                  
                  // 기본 스탯 (HP/MP/Armor)
                  _buildBaseStats(),
                  const SizedBox(height: 24),
                  
                  // 전투력 (3대 중량)
                  _buildCombatPower(bigThree),
                  const SizedBox(height: 24),
                  
                  // 육각형 레이더 차트
                  _buildRadarChart(bodyPartVolumes),
                  const SizedBox(height: 24),
                  
                  // 스킬 숙련도
                  _buildSkillList(exerciseStats),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelHeader(int level, double progress) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: IronTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.3 + _glowController.value * 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.1 + _glowController.value * 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // 레벨 뱃지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade700,
                      Colors.amber.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Lv. $level',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 이름
              Text(
                _profile?.gender == '남성' ? '전사' : '여전사',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // 경험치 바
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXP',
                        style: TextStyle(
                          color: IronTheme.textMedium,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: IronTheme.background,
                      valueColor: AlwaysStoppedAnimation(Colors.amber),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBaseStats() {
    final hp = _profile?.weight ?? 70;
    final mp = (_profile?.weight ?? 70) * 0.4; // 골격근량 추정 (체중의 40%)
    final armor = _calculateArmor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BASE STATS',
            style: TextStyle(
              color: IronTheme.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatBar('HP', hp, 150, Colors.red, '체중'),
          const SizedBox(height: 12),
          _buildStatBar('MP', mp, 60, Colors.blue, '골격근량'),
          const SizedBox(height: 12),
          _buildStatBar('ARMOR', armor.toDouble(), 100, Colors.grey, '방어력'),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double value, double max, Color color, String desc) {
    final progress = (value / max).clamp(0.0, 1.0);
    
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: IronTheme.background,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.8), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${value.toStringAsFixed(1)} $desc',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateArmor() {
    // 체지방률 기반 방어력 (15~20%가 최적)
    // 임시로 체중 기반 계산
    final weight = _profile?.weight ?? 70;
    if (weight < 60) return 40;
    if (weight < 70) return 60;
    if (weight < 80) return 80;
    if (weight < 90) return 70;
    return 50;
  }


  Widget _buildCombatPower(BigThreeStats bigThree) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900.withValues(alpha: 0.3),
            Colors.orange.shade900.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'COMBAT POWER',
            style: TextStyle(
              color: Colors.red.shade300,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bigThree.total.toStringAsFixed(0),
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPowerStat('STR', bigThree.deadlift, '데드리프트', Colors.purple),
              _buildPowerStat('PWR', bigThree.squat, '스쿼트', Colors.blue),
              _buildPowerStat('ATK', bigThree.benchPress, '벤치프레스', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerStat(String label, double value, String desc, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          desc,
          style: TextStyle(
            color: IronTheme.textLow,
            fontSize: 10,
          ),
        ),
      ],
    );
  }


  Widget _buildRadarChart(Map<String, double> volumes) {
    // 최대값 찾기 (정규화용)
    final maxVolume = volumes.values.isEmpty ? 1.0 : 
        volumes.values.reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxVolume > 0 ? maxVolume : 1.0;

    final categories = ['chest', 'back', 'legs', 'shoulder', 'arm', 'core'];
    final labels = ['가슴', '등', '하체', '어깨', '팔', '코어'];
    
    final dataEntries = categories.map((cat) {
      final value = volumes[cat] ?? 0;
      return RadarEntry(value: (value / normalizedMax * 5).clamp(0, 5));
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'BODY BALANCE',
            style: TextStyle(
              color: IronTheme.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                radarBorderData: BorderSide(color: IronTheme.textLow, width: 1),
                gridBorderData: BorderSide(color: IronTheme.surfaceHighlight, width: 1),
                tickBorderData: BorderSide(color: Colors.transparent),
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                titleTextStyle: TextStyle(
                  color: IronTheme.textMedium,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                getTitle: (index, angle) => RadarChartTitle(
                  text: labels[index],
                  angle: 0,
                ),
                dataSets: [
                  RadarDataSet(
                    dataEntries: dataEntries,
                    fillColor: Colors.amber.withValues(alpha: 0.3),
                    borderColor: Colors.amber,
                    borderWidth: 2,
                    entryRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSkillList(Map<String, ExerciseStats> stats) {
    final sortedStats = stats.values.toList()
      ..sort((a, b) => b.best1RM.compareTo(a.best1RM));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IronTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SKILL PROFICIENCY',
            style: TextStyle(
              color: IronTheme.textMedium,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          if (sortedStats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '운동 기록이 없습니다',
                  style: TextStyle(color: IronTheme.textLow),
                ),
              ),
            )
          else
            ...sortedStats.take(10).map((stat) => _buildSkillItem(stat)),
        ],
      ),
    );
  }

  Widget _buildSkillItem(ExerciseStats stat) {
    final rankColor = Color(stat.rankColor);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 스킬 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: rankColor, width: 1),
            ),
            child: Icon(
              Icons.fitness_center,
              color: rankColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // 스킬 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${stat.bestWeight.toStringAsFixed(1)}kg × ${stat.bestReps}회',
                  style: TextStyle(
                    color: IronTheme.textLow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // 1RM & 등급
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stat.best1RM.toStringAsFixed(0)}kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stat.rank,
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

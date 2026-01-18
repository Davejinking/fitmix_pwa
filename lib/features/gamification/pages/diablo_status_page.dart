import 'package:flutter/material.dart';
import '../../../core/service_locator.dart';
import '../../../data/session_repo.dart';
import '../../../data/user_repo.dart';
import '../../../models/user_profile.dart';
import '../../../models/session.dart';
import '../../../services/stats_calculator.dart';
import '../../../shared/widgets/common/rpg_equipment_icons.dart';
import 'inventory_page.dart';

/// 디아블로 2 스타일 다크 판타지 Status 페이지
class DiabloStatusPage extends StatefulWidget {
  const DiabloStatusPage({super.key});

  @override
  State<DiabloStatusPage> createState() => _DiabloStatusPageState();
}

class _DiabloStatusPageState extends State<DiabloStatusPage> {
  UserProfile? _profile;
  List<Session> _sessions = [];
  bool _isLoading = true;

  // Dark & Antique Color Palette
  static const Color _bgColor = Color(0xFF0A0A0A);
  static const Color _panelBg = Color(0xFF1C1C1C);
  static const Color _accentGold = Color(0xFFC7B377);
  static const Color _textRed = Color(0xFFD32F2F);
  static const Color _textBlue = Color(0xFF1976D2);
  static const Color _textGreen = Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userRepo = getIt<UserRepo>();
    final sessionRepo = getIt<SessionRepo>();
    
    final profile = await userRepo.getUserProfile();
    final sessions = await sessionRepo.getWorkoutSessions();
    
    if (mounted) {
      setState(() {
        _profile = profile;
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _accentGold),
      );
    }

    final totalVolume = StatsCalculator.calculateTotalVolume(_sessions);
    final level = StatsCalculator.calculateLevel(totalVolume);
    final levelProgress = StatsCalculator.levelProgress(totalVolume);
    final bigThree = StatsCalculator.calculateBigThree(_sessions);

    return Container(
      color: _bgColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. Character Info Header
                  _buildCharacterHeader(level, levelProgress),
                  const SizedBox(height: 20),
                  
                  // 2. Attributes Panel
                  _buildAttributesPanel(bigThree),
                  const SizedBox(height: 20),
                  
                  // 3. 🔥 장비는 EQUIPMENT 탭으로 이동
                  // _buildPaperDoll(), // 제거
                  
                  // 4. Bottom Info (Gold)
                  _buildBottomInfo(totalVolume),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterHeader(int level, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelBg,
        border: Border.all(color: _accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name & Class
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IRON LIFTER',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile?.gender == '남성' ? 'WARRIOR' : 'AMAZON',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _accentGold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              // Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: _accentGold, width: 2),
                ),
                child: Text(
                  'Lv.$level',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _accentGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Experience Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXPERIENCE',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      color: _accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: _accentGold, width: 1),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _accentGold.withValues(alpha: 0.6),
                              _accentGold,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAttributesPanel(BigThreeStats bigThree) {
    final smm = (_profile?.weight ?? 70) * 0.4; // 골격근량 추정
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelBg,
        border: Border.all(color: _accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ATTRIBUTES',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _accentGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          
          // STR (Deadlift)
          _StatRow(
            label: 'STRENGTH',
            value: bigThree.deadlift.toStringAsFixed(0),
            color: _textRed,
            icon: '💪',
          ),
          const SizedBox(height: 12),
          
          // DEX (Bench Press)
          _StatRow(
            label: 'DEXTERITY',
            value: bigThree.benchPress.toStringAsFixed(0),
            color: _textBlue,
            icon: '🎯',
          ),
          const SizedBox(height: 12),
          
          // VIT (Squat)
          _StatRow(
            label: 'VITALITY',
            value: bigThree.squat.toStringAsFixed(0),
            color: _textGreen,
            icon: '❤️',
          ),
          const SizedBox(height: 12),
          
          // ENE (SMM)
          _StatRow(
            label: 'ENERGY',
            value: smm.toStringAsFixed(1),
            color: _textBlue,
            icon: '⚡',
          ),
          
          const SizedBox(height: 16),
          Divider(color: _accentGold.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          
          // Damage (Total Combat Power)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAMAGE',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              Text(
                bigThree.total.toStringAsFixed(0),
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _accentGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaperDoll() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 돌 벽 텍스처 효과 - 레퍼런스 이미지 스타일
        color: const Color(0xFF2A2520),
        border: Border.all(color: const Color(0xFF4A3F35), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'EQUIPMENT',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4C5A0),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.9),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // HUD / Surround Layout using Stack + Align
          SizedBox(
            height: 550,
            child: Stack(
              children: [
                // 횃불 조명 효과 (좌측 상단)
                Align(
                  alignment: const Alignment(-0.95, -0.95),
                  child: Container(
                    width: 50,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.7),
                          Colors.orange.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange.shade800,
                      size: 36,
                    ),
                  ),
                ),
                
                // 횃불 조명 효과 (우측 상단)
                Align(
                  alignment: const Alignment(0.95, -0.95),
                  child: Container(
                    width: 50,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.7),
                          Colors.orange.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange.shade800,
                      size: 36,
                    ),
                  ),
                ),
                
                // 중앙 캐릭터 실루엣 (BODY)
                Align(
                  alignment: const Alignment(0, -0.05),
                  child: Container(
                    width: 120,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1612),
                      border: Border.all(
                        color: const Color(0xFF5A4F45),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.accessibility_new,
                      size: 100,
                      color: const Color(0xFF3A3530),
                    ),
                  ),
                ),
                
                // HEAD - 상단 중앙
                Align(
                  alignment: const Alignment(-0.15, -0.88),
                  child: _CompactEquipmentSlot(
                    label: 'HEAD',
                    icon: RPGEquipmentIcons.helmet(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // NECK - 상단 우측
                Align(
                  alignment: const Alignment(0.55, -0.88),
                  child: _CompactEquipmentSlot(
                    label: 'NECK',
                    icon: Icon(Icons.circle_outlined, color: const Color(0xFF6A5F55), size: 28),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // WEAPON - 좌측 상단
                Align(
                  alignment: const Alignment(-0.75, -0.5),
                  child: _CompactEquipmentSlot(
                    label: 'WEAPON',
                    icon: Icon(Icons.fitness_center, color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // SHIELD - 우측 상단
                Align(
                  alignment: const Alignment(0.75, -0.5),
                  child: _CompactEquipmentSlot(
                    label: 'SHIELD',
                    icon: RPGEquipmentIcons.shield(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // CHEST - 좌측 중간
                Align(
                  alignment: const Alignment(-0.75, -0.08),
                  child: _CompactEquipmentSlot(
                    label: 'CHEST',
                    icon: RPGEquipmentIcons.armor(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // WAIST/BELT - 우측 중간
                Align(
                  alignment: const Alignment(0.75, -0.08),
                  child: _CompactEquipmentSlot(
                    label: 'BELT',
                    icon: RPGEquipmentIcons.belt(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // GLOVES - 좌측 하단
                Align(
                  alignment: const Alignment(-0.75, 0.34),
                  child: _CompactEquipmentSlot(
                    label: 'GLOVES',
                    icon: RPGEquipmentIcons.gloves(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // RING - 우측 하단
                Align(
                  alignment: const Alignment(0.75, 0.34),
                  child: _CompactEquipmentSlot(
                    label: 'RING',
                    icon: Icon(Icons.circle, color: const Color(0xFF6A5F55), size: 24),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // LEGS - 하단 중앙 (BOOTS 위)
                Align(
                  alignment: const Alignment(0, 0.68),
                  child: _CompactEquipmentSlot(
                    label: 'LEGS',
                    icon: RPGEquipmentIcons.pants(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
                
                // FEET/BOOTS - 최하단
                Align(
                  alignment: const Alignment(0, 0.92),
                  child: _CompactEquipmentSlot(
                    label: 'BOOTS',
                    icon: RPGEquipmentIcons.boots(color: const Color(0xFF6A5F55), size: 32),
                    onTap: () => _openInventory(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 28),
          
          // INVENTORY 섹션 (하단 그리드)
          _buildInventoryGrid(),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INVENTORY',
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4C5A0),
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.9),
                blurRadius: 5,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 65,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1612),
                  border: Border.all(
                    color: const Color(0xFF5A4F45),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(double totalVolume) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelBg,
        border: Border.all(color: _accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: _accentGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'GOLD',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Text(
            _formatGold(totalVolume),
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _accentGold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatGold(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M kg';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K kg';
    }
    return '${volume.toStringAsFixed(0)} kg';
  }

  void _openInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InventoryPage()),
    );
  }
}

/// Stat Row Widget
class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Compact Equipment Slot for HUD Layout
class _CompactEquipmentSlot extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _CompactEquipmentSlot({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              // 돌 질감 배경
              color: const Color(0xFF1A1612),
              border: Border.all(
                color: const Color(0xFF5A4F45),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                // 내부 그림자 효과
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8A7F75),
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.9),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/service_locator.dart';
import '../data/session_repo.dart';
import '../data/big_three_repo.dart';
import '../widgets/common/iron_app_bar.dart';
import '../utils/strength_calculator.dart';

/// Big 3 Detail Screen - Strength Metrics Dashboard
/// Displays Squat, Bench Press, Deadlift max weights and progress
class BigThreeDetailPage extends StatefulWidget {
  const BigThreeDetailPage({super.key});

  @override
  State<BigThreeDetailPage> createState() => _BigThreeDetailPageState();
}

class _BigThreeDetailPageState extends State<BigThreeDetailPage> {
  late SessionRepo sessionRepo;
  late BigThreeRepository bigThreeRepo;
  
  Big3Data? big3Data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    sessionRepo = getIt<SessionRepo>();
    bigThreeRepo = BigThreeRepository(sessionRepo: sessionRepo);
    _loadBigThreeData();
  }

  Future<void> _loadBigThreeData() async {
    setState(() => isLoading = true);
    
    try {
      final data = await bigThreeRepo.getBig3Data();
      
      if (mounted) {
        setState(() {
          big3Data = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading Big 3 data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure Black
      appBar: IronAppBar(
        title: 'STRENGTH METRICS',
        titleStyle: GoogleFonts.oswald(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 4.0,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2962FF)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section - Total Weight
                    _buildHeroSection(),
                    const SizedBox(height: 40),
                    
                    // Chart Section - Progress Over Time
                    _buildChartSection(),
                    const SizedBox(height: 40),
                    
                    // Breakdown List - Individual Lifts
                    _buildBreakdownList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection() {
    if (big3Data == null) {
      return const SizedBox.shrink();
    }
    
    final total = big3Data!.total;
    final hasData = big3Data!.hasData;
    
    return Center(
      child: Column(
        children: [
          // Subtitle
          Text(
            'SBD TOTAL',
            style: GoogleFonts.oswald(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF616161),
              letterSpacing: 4.0,
            ),
          ),
          const SizedBox(height: 20),
          
          // Hero Total Weight with Unit (Optically Centered)
          Hero(
            tag: 'big3_total',
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Invisible spacer to balance the "KG" on the right
                  const SizedBox(width: 40),
                  
                  // Number (Optically Centered)
                  Text(
                    hasData ? '${total.toInt()}' : '--',
                    style: GoogleFonts.oswald(
                      fontSize: 84,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -2.0,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Unit (baseline aligned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'KG',
                      style: GoogleFonts.oswald(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF616161),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    if (big3Data == null || !big3Data!.hasData) {
      return _buildEmptySpecSheet();
    }
    
    // Hardcoded bodyweight for MVP (should come from user profile later)
    const bodyWeight = 75.0;
    
    // Calculate metrics using StrengthCalculator
    final wilksScore = StrengthCalculator.calculateWilks(big3Data!.total, bodyWeight);
    final strengthTier = StrengthCalculator.calculateTier(big3Data!.total, bodyWeight);
    final bwRatio = StrengthCalculator.calculateRatio(big3Data!.total, bodyWeight);
    
    return Column(
      children: [
        // Container A: TIER BANNER (The Hero)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: strengthTier.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: strengthTier.color.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Top Label
              Text(
                'CURRENT RANK',
                style: GoogleFonts.oswald(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF616161),
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 12),
              
              // Main Tier Text
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  strengthTier.name,
                  style: GoogleFonts.oswald(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: strengthTier.color,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Container B: STATS GRID (Details)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left: WILKS
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'WILKS',
                        style: GoogleFonts.oswald(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF616161),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          wilksScore.toStringAsFixed(1),
                          style: GoogleFonts.oswald(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                SizedBox(
                  height: 50,
                  child: VerticalDivider(
                    color: Colors.white.withOpacity(0.15),
                    thickness: 1,
                    width: 1,
                  ),
                ),
                
                // Right: BW RATIO
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'BW RATIO',
                        style: GoogleFonts.oswald(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF616161),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          bwRatio,
                          style: GoogleFonts.oswald(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
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
      ],
    );
  }
  
  Widget _buildEmptySpecSheet() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Color(0xFF616161),
            ),
            const SizedBox(height: 16),
            Text(
              'NO DATA YET',
              style: GoogleFonts.oswald(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616161),
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownList() {
    if (big3Data == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BREAKDOWN',
          style: GoogleFonts.oswald(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF616161),
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 16),
        
        // Squat
        _buildLiftCard(
          name: 'SQUAT',
          icon: Icons.fitness_center,
          record: big3Data!.squat,
        ),
        const SizedBox(height: 12),
        
        // Bench Press
        _buildLiftCard(
          name: 'BENCH PRESS',
          icon: Icons.airline_seat_flat,
          record: big3Data!.bench,
        ),
        const SizedBox(height: 12),
        
        // Deadlift
        _buildLiftCard(
          name: 'DEADLIFT',
          icon: Icons.arrow_upward,
          record: big3Data!.deadlift,
        ),
      ],
    );
  }

  Widget _buildLiftCard({
    required String name,
    required IconData icon,
    required Big3Record record,
  }) {
    final hasData = record.hasData;
    final hasImprovement = record.hasImprovement;
    
    // Format date
    String formattedDate = '';
    if (record.lastRecordDate != null) {
      final date = record.lastRecordDate!;
      formattedDate = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Left: Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2962FF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2962FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          
          // Left-Center: Exercise Name
          Text(
            name,
            style: GoogleFonts.oswald(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF616161),
              letterSpacing: 1.2,
            ),
          ),
          
          const Spacer(),
          
          // Right: Weight Number
          Text(
            hasData ? '${record.currentMax.toInt()}' : '--',
            style: GoogleFonts.oswald(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          
          // Right-End: Growth Badge or Date
          if (hasImprovement) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2962FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${record.improvement.toInt()}',
                style: GoogleFonts.oswald(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2962FF),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ] else if (hasData && formattedDate.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: GoogleFonts.oswald(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF616161),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

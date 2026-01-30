import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class RoutineDetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String heroTag;
  final double rating;
  final String duration;
  final String calories;
  final String level;
  final String instructor;
  final String price;
  final bool isFree;

  const RoutineDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.heroTag,
    this.rating = 4.9,
    this.duration = '45 min',
    this.calories = '350 kcal',
    this.level = 'Advanced',
    this.instructor = 'Sarah Johnson',
    this.price = '\$2.99',
    this.isFree = true,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  bool _isDescriptionExpanded = false;

  final String _description = 
      'High-Intensity Interval Training designed to push your limits and maximize calorie burn. '
      'This workout combines explosive movements with short rest periods to boost your metabolism '
      'and build lean muscle. Perfect for those looking to challenge themselves and see real results. '
      'No equipment needed - just bring your energy and determination!';

  final List<Map<String, String>> _exercises = [
    {'name': 'Jumping Jacks', 'duration': '30s'},
    {'name': 'Burpees', 'duration': '20s'},
    {'name': 'Mountain Climbers', 'duration': '30s'},
    {'name': 'High Knees', 'duration': '30s'},
    {'name': 'Push-ups', 'duration': '20s'},
    {'name': 'Plank Hold', 'duration': '45s'},
    {'name': 'Squat Jumps', 'duration': '20s'},
    {'name': 'Rest', 'duration': '60s'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F8),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                _buildAuthorRow(isDark),
                _buildStatsRow(isDark),
                _buildDescription(isDark),
                _buildExerciseList(isDark),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyFooter(isDark),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.heroTag,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Color(0xFF475569),
                    ),
                  );
                },
              ),
              // Gradient overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isFree 
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFF007AFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.isFree ? 'FREE' : widget.price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: widget.isFree 
                        ? const Color(0xFF10B981)
                        : const Color(0xFF007AFF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF007AFF),
            child: Text(
              widget.instructor[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.instructor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFBBF24),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(2.1k reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark 
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _buildStatItem(
            Icons.schedule,
            'Time',
            widget.duration,
            isDark,
          ),
          _buildStatItem(
            Icons.local_fire_department,
            'Burn',
            widget.calories,
            isDark,
          ),
          _buildStatItem(
            Icons.trending_up,
            'Level',
            widget.level,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF007AFF),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark 
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Workout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isDescriptionExpanded 
                ? _description 
                : _description.substring(0, 150) + '...',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark 
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? 'Read Less' : 'Read More',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF007AFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercises (${_exercises.length})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      exercise['duration']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // TODO: Navigate to workout start screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting workout...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.isFree ? 'Start Workout' : 'Unlock for ${widget.price}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

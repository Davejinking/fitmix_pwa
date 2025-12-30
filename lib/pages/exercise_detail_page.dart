import 'package:flutter/material.dart';
import '../models/exercise_db.dart';
import '../l10n/app_localizations.dart';

class ExerciseDetailPage extends StatelessWidget {
  final ExerciseDB exercise;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(
          exercise.getLocalizedName(locale),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 운동 이미지/GIF
            _buildExerciseImage(),
            const SizedBox(height: 24),
            
            // 기본 정보
            _buildBasicInfo(l10n, locale),
            const SizedBox(height: 24),
            
            // 운동 설명
            _buildInstructions(l10n, locale),
            const SizedBox(height: 24),
            
            // 타겟 근육
            _buildTargetMuscles(l10n, locale),
            const SizedBox(height: 24),
            
            // 보조 근육
            if (exercise.secondaryMuscles.isNotEmpty) ...[
              _buildSecondaryMuscles(l10n, locale),
              const SizedBox(height: 24),
            ],
            
            // 운동 추가 버튼
            _buildAddButton(l10n, context, locale),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: exercise.isCustom || exercise.gifUrl.isEmpty
            ? const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Color(0xFF4A9EFF),
                ),
              )
            : Image.network(
                exercise.gifUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A9EFF),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Color(0xFF4A9EFF),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBasicInfo(AppLocalizations l10n, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ja' ? '基本情報' : locale == 'en' ? 'Basic Information' : '기본 정보',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            locale == 'ja' ? '部位' : locale == 'en' ? 'Body Part' : '부위', 
            exercise.getTargetPart(locale)
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            locale == 'ja' ? '器具' : locale == 'en' ? 'Equipment' : '장비', 
            exercise.getEquipmentType(locale)
          ),
          if (exercise.isCustom) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              locale == 'ja' ? 'タイプ' : locale == 'en' ? 'Type' : '타입',
              locale == 'ja' ? 'カスタム運動' : locale == 'en' ? 'Custom Exercise' : '커스텀 운동'
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(AppLocalizations l10n, String locale) {
    final localizedInstructions = exercise.getLocalizedInstructions(locale);
    
    // 다국어 설명이 없으면 원본 instructions 사용
    final instructions = localizedInstructions.isNotEmpty ? localizedInstructions : exercise.instructions;
    
    if (instructions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ja' ? '運動方法' : locale == 'en' ? 'Instructions' : '운동 방법',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A9EFF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTargetMuscles(AppLocalizations l10n, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ja' ? '主要ターゲット筋肉' : locale == 'en' ? 'Primary Target Muscles' : '주요 타겟 근육',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9EFF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A9EFF).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              exercise.getLocalizedTarget(locale),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4A9EFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryMuscles(AppLocalizations l10n, String locale) {
    final localizedSecondaryMuscles = exercise.getLocalizedSecondaryMuscles(locale);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'ja' ? '補助筋肉' : locale == 'en' ? 'Secondary Muscles' : '보조 근육',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: localizedSecondaryMuscles.map((muscle) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E8E93).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8E8E93).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  muscle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations l10n, BuildContext context, String locale) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // 운동을 계획에 추가하고 이전 화면으로 돌아가기
          Navigator.of(context).pop(exercise);
        },
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          locale == 'ja' ? 'ワークアウト計画に追加' : locale == 'en' ? 'Add to Workout Plan' : '운동 계획에 추가'
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A9EFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
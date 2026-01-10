import 'package:flutter/material.dart';
import '../data/session_repo.dart';
import '../data/user_repo.dart';
import '../core/iron_theme.dart';
import '../l10n/app_localizations.dart';

class AnalysisPage extends StatefulWidget {
  final SessionRepo repo;
  final UserRepo userRepo;

  const AnalysisPage({super.key, required this.repo, required this.userRepo});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: IronTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: IronTheme.background,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.analysisTitle,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: IronTheme.textHigh,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            // 유료 기능 방어막
            Expanded(
              child: _buildComingSoonView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: IronTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: IronTheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 60,
                color: IronTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '준비 중인 기능입니다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: IronTheme.textHigh,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '상세한 운동 분석과 통계 기능을\n곧 만나보실 수 있습니다.',
              style: TextStyle(
                fontSize: 16,
                color: IronTheme.textMedium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: IronTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: IronTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: IronTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: IronTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
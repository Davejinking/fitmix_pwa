import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/burn_fit_style.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/error_handler.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  bool _isLoading = false;

  Future<void> _handlePurchase() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    // 햅틱 피드백
    HapticFeedback.lightImpact();
    
    try {
      // 임시 로딩 시뮬레이션 (실제 인앱 결제 연동 전까지)
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // 준비 중 메시지 표시
        _showComingSoonDialog();
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, '결제 처리 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showComingSoonDialog() {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들 바
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 아이콘
                Icon(
                  Icons.construction_rounded,
                  size: 48,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                
                // 제목
                Text(
                  l10n.comingSoon,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 설명
                Text(
                  '인앱 결제 기능을 준비 중입니다.\n곧 프리미엄 기능을 만나보실 수 있어요! 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BurnFitStyle.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.upgrade),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.unlockAllFeatures,
              textAlign: TextAlign.center,
              style: BurnFitStyle.title1,
            ),
            const SizedBox(height: 32),
            _buildFeatureItem(
              Icons.analytics_outlined,
              l10n.advancedAnalytics,
              l10n.advancedAnalyticsDesc,
            ),
            _buildFeatureItem(
              Icons.do_not_disturb_on_outlined,
              l10n.removeAds,
              l10n.removeAdsDesc,
            ),
            _buildFeatureItem(
              Icons.cloud_sync_outlined,
              l10n.cloudBackup,
              l10n.cloudBackupDesc,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey[700] : BurnFitStyle.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.startMonthly,
                      style: BurnFitStyle.body.copyWith(
                        color: BurnFitStyle.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cancelAnytime,
              textAlign: TextAlign.center,
              style: BurnFitStyle.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: BurnFitStyle.primaryBlue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BurnFitStyle.body.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: BurnFitStyle.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

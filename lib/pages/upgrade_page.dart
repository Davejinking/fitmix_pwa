import 'package:flutter/material.dart';
import '../core/burn_fit_style.dart';
import '../l10n/app_localizations.dart';

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

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
              onPressed: () {
                // TODO: 실제 인앱 결제 로직 연동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BurnFitStyle.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n.startMonthly,
                style: BurnFitStyle.body.copyWith(color: BurnFitStyle.white, fontWeight: FontWeight.bold),
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
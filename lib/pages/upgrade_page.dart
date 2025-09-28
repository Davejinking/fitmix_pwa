import 'package:flutter/material.dart';
import '../core/burn_fit_style.dart';

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프리미엄으로 업그레이드'),
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
            const Text(
              '모든 기능을 잠금 해제하세요',
              textAlign: TextAlign.center,
              style: BurnFitStyle.title1,
            ),
            const SizedBox(height: 32),
            _buildFeatureItem(
              Icons.analytics_outlined,
              '고급 분석',
              '주간, 월간, 연간 운동 데이터를 심층 분석하세요.',
            ),
            _buildFeatureItem(
              Icons.do_not_disturb_on_outlined,
              '광고 제거',
              '방해 없이 운동에만 집중하세요.',
            ),
            _buildFeatureItem(
              Icons.cloud_sync_outlined,
              '클라우드 백업',
              '여러 기기에서 데이터를 안전하게 동기화하세요.',
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
                '월 9,900원으로 시작하기',
                style: BurnFitStyle.body.copyWith(color: BurnFitStyle.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '언제든지 구독을 취소할 수 있습니다.',
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
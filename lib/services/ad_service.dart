import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// AdMob 전면광고 관리 서비스
class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  /// 플랫폼별 테스트 전면광고 ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 전면광고 로드 (운동 시작 시 미리 로드)
  Future<void> loadInterstitialAd() async {
    if (_isAdLoaded) {
      if (kDebugMode) {
        print('🎯 광고가 이미 로드되어 있습니다.');
      }
      return;
    }

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          if (kDebugMode) {
            print('✅ 전면광고 로드 완료');
          }

          // 광고 이벤트 리스너 설정
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('📺 전면광고 표시됨');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('❌ 전면광고 닫힘');
              }
              ad.dispose();
              _isAdLoaded = false;
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('⚠️ 전면광고 표시 실패: $error');
              }
              ad.dispose();
              _isAdLoaded = false;
              _interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ 전면광고 로드 실패: $error');
          }
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// 전면광고 표시 (운동 완료 후)
  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (_interstitialAd != null && _isAdLoaded) {
      // 광고 닫힘 콜백 설정
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('❌ 전면광고 닫힘 - 홈으로 이동');
          }
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          
          // 광고 닫힌 후 콜백 실행 (홈으로 이동)
          if (onAdClosed != null) {
            onAdClosed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            print('⚠️ 전면광고 표시 실패: $error');
          }
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          
          // 광고 실패해도 홈으로 이동
          if (onAdClosed != null) {
            onAdClosed();
          }
        },
      );

      await _interstitialAd!.show();
    } else {
      if (kDebugMode) {
        print('⚠️ 표시할 광고가 없습니다. 바로 홈으로 이동');
      }
      // 광고가 없어도 홈으로 이동
      if (onAdClosed != null) {
        onAdClosed();
      }
    }
  }

  /// 광고 리소스 정리
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}

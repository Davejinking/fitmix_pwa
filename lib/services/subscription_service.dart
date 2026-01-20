import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'pro_service.dart';

/// RevenueCat 구독 서비스
/// 인앱 결제 및 구독 관리
class SubscriptionService {
  // .env 파일에서 키 로드 (없을 경우 기존 플레이스홀더 사용)
  static String get _googleApiKey => dotenv.env['REVENUECAT_GOOGLE_API_KEY'] ?? 'goog_placeholder_api_key';
  static String get _appleApiKey => dotenv.env['REVENUECAT_APPLE_API_KEY'] ?? 'appl_placeholder_api_key';

  // Entitlement ID (RevenueCat 대시보드에서 설정한 값)
  static const String _entitlementId = 'pro';

  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> init() async {
    if (_isInitialized) return;

    // 디버그 로그 설정
    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.debug : LogLevel.error
    );

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      _isInitialized = true;

      // 앱 시작 시 구독 상태 확인
      await checkSubscriptionStatus();
    }
  }

  /// 구독 상태 확인 및 ProService 업데이트
  Future<void> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      await proService.setProStatus(isPro);

      if (kDebugMode) {
        print('💎 Subscription Status: $isPro');
      }
    } on PlatformException catch (e) {
      // 에러 발생 시 로그만 남기고, 기존 Pro 상태 유지
      if (kDebugMode) {
        print('❌ Failed to check subscription status: $e');
      }
    }
  }

  /// 상품 구매
  Future<bool> purchase(String productIdentifier) async {
    try {
      final customerInfo = await Purchases.purchaseProduct(productIdentifier);
      final isPro = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      if (isPro) {
        await proService.setProStatus(true);
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        if (kDebugMode) {
          print('❌ Purchase failed: $e');
        }
        rethrow; // 취소가 아닌 에러는 상위로 전파
      }
      return false; // 사용자가 취소함
    }
  }

  /// 구매 복원
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;

      // 복원 성공 여부와 상관없이 현재 상태 업데이트
      await proService.setProStatus(isPro);

      return isPro;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('❌ Restore failed: $e');
      }
      rethrow;
    }
  }
}

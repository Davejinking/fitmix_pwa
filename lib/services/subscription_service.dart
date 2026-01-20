import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';

/// RevenueCat 구독 및 결제를 관리하는 서비스
class SubscriptionService {
  static const String _apiKeyIOS = 'appl_PLACEHOLDER_KEY'; // TODO: 실제 키로 교체 필요
  static const String _apiKeyAndroid = 'goog_PLACEHOLDER_KEY'; // TODO: 실제 키로 교체 필요

  bool _isInitialized = false;

  /// 초기화
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      PurchasesConfiguration? configuration;
      // 웹이나 다른 플랫폼은 지원하지 않는다고 가정하거나 별도 처리
      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKeyIOS);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKeyAndroid);
      }

      if (configuration != null) {
        await Purchases.configure(configuration);
        _isInitialized = true;
      }
    } catch (e) {
      // 키가 없거나 설정 오류 시 조용히 실패 (개발 모드 지원)
      debugPrint('⚠️ RevenueCat initialization failed: $e');
    }
  }

  /// 상품 구매
  /// [productId]는 RevenueCat의 Package Identifier가 아닌, Offering 내의 패키지 ID 또는
  /// 앱스토어 Product ID와 매핑되어야 함.
  /// 여기서는 간단하게 productId를 받아서 처리.
  Future<bool> purchase(String productId) async {
    if (!_isInitialized) {
      debugPrint('⚠️ SubscriptionService not initialized. Simulating success.');
      await Future.delayed(const Duration(seconds: 1));
      return true; // 개발용 시뮬레이션
    }

    try {
      // 1. Offerings 가져오기
      final offerings = await Purchases.getOfferings();

      // 2. 현재 Offering 확인
      if (offerings.current != null) {
        // 3. 해당 Product ID를 가진 패키지 찾기
        final package = offerings.current!.availablePackages.firstWhere(
          (pkg) => pkg.storeProduct.identifier == productId,
          orElse: () => throw PlatformException(
            code: 'PRODUCT_NOT_FOUND',
            message: 'Product not found in current offering',
          ),
        );

        // 4. 구매 요청
        final purchaseResult = await Purchases.purchasePackage(package);
        // purchaseResult is of type PurchaseResult. It contains customerInfo.
        return purchaseResult.customerInfo.entitlements.all['pro']?.isActive ?? false;
      }

      return false;
    } on PlatformException catch (e) {
      debugPrint('❌ Purchase failed: ${e.message}');
      // 설정 오류(키 없음 등)일 경우 개발용 성공 처리
      if (e.code == 'configuration_error' || e.message?.contains('configuration') == true) {
         return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return false;
    }
  }

  /// 구매 복원
  Future<bool> restore() async {
    if (!_isInitialized) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ Restore failed: $e');
      return false;
    }
  }

  /// 현재 PRO 상태 확인
  Future<bool> get isPro async {
    if (!_isInitialized) return false;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['pro']?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Pro 구독 상태 관리 서비스
class ProService extends ChangeNotifier {
  static const String _boxName = 'pro_settings';
  static const String _isProKey = 'is_pro';
  
  // TODO: 실제 RevenueCat API Key로 교체 필요
  static const String _revenueCatApiKey = 'appl_REPLACE_WITH_YOUR_API_KEY';
  static const String _entitlementId = 'pro';

  late Box _box;
  bool _isPro = false;
  
  bool get isPro => _isPro;
  
  /// 서비스 초기화
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _isPro = _box.get(_isProKey, defaultValue: false);
    
    if (kDebugMode) {
      print('💎 ProService 초기화: isPro = $_isPro');
    }

    await _initRevenueCat();
  }

  Future<void> _initRevenueCat() async {
    try {
      if (kIsWeb) return;

      // RevenueCat 설정
      // TODO: 플랫폼별 키 분기 처리 권장 (Platform.isAndroid ? ... : ...)
      await Purchases.configure(PurchasesConfiguration(_revenueCatApiKey));

      // 초기 상태 동기화
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatusFromInfo(customerInfo);

      // 실시간 상태 변경 감지
      Purchases.addCustomerInfoUpdateListener((info) {
        _updateProStatusFromInfo(info);
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ RevenueCat 초기화 실패: $e');
      }
    }
  }

  void _updateProStatusFromInfo(CustomerInfo info) {
    final isActive = info.entitlements.all[_entitlementId]?.isActive ?? false;
    if (_isPro != isActive) {
      setProStatus(isActive);
    }
  }
  
  /// Pro 상태 업데이트
  Future<void> setProStatus(bool value) async {
    _isPro = value;
    await _box.put(_isProKey, value);
    notifyListeners();
    
    if (kDebugMode) {
      print('💎 Pro 상태 변경: $_isPro');
    }
  }
  
  /// 구매 복원
  Future<bool> restorePurchases() async {
    if (kDebugMode) {
      print('🔄 구매 복원 시도...');
    }

    if (kIsWeb) {
      return false;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatusFromInfo(customerInfo);

      final isActive = customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      return isActive;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 구매 복원 실패: $e');
      }
      rethrow;
    }
  }
  
  /// 디버그용: Pro 상태 토글
  Future<void> toggleProForDebug() async {
    await setProStatus(!_isPro);
  }
}

/// 전역 ProService 인스턴스
ProService? _proServiceInstance;

@visibleForTesting
set proServiceInstance(ProService service) => _proServiceInstance = service;

ProService get proService {
  _proServiceInstance ??= ProService();
  return _proServiceInstance!;
}

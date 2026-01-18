import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Pro 구독 상태 관리 서비스
/// RevenueCat 연동 전까지 Mock으로 사용
class ProService extends ChangeNotifier {
  static const String _boxName = 'pro_settings';
  static const String _isProKey = 'is_pro';
  
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
  }
  
  /// Pro 상태 업데이트 (RevenueCat 연동 시 사용)
  Future<void> setProStatus(bool value) async {
    _isPro = value;
    await _box.put(_isProKey, value);
    notifyListeners();
    
    if (kDebugMode) {
      print('💎 Pro 상태 변경: $_isPro');
    }
  }
  
  /// 구매 복원 (RevenueCat 연동 시 구현)
  Future<bool> restorePurchases() async {
    if (kDebugMode) {
      print('🔄 구매 복원 시도...');
    }
    // TODO: RevenueCat 연동 시 구현
    return false;
  }
  
  /// 디버그용: Pro 상태 토글
  Future<void> toggleProForDebug() async {
    await setProStatus(!_isPro);
  }
}

/// 전역 ProService 인스턴스
ProService? _proServiceInstance;

ProService get proService {
  _proServiceInstance ??= ProService();
  return _proServiceInstance!;
}

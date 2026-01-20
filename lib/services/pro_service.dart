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

    // RevenueCat 연동 전 Mock 구현
    // 실제 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    // Mock 복원 성공 처리 (테스트를 위해 성공으로 간주)
    // 안전장치: 디버그 모드에서만 Mock 복원 허용
    if (kDebugMode) {
      await setProStatus(true);
      print('✅ 구매 복원 성공 (Mock)');
      return true;
    }

    // 릴리즈 모드에서는 복원 실패 처리
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

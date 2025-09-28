import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

/// 사용자 프로필 데이터 저장소 인터페이스
abstract class UserRepo {
  Future<void> init();
  Future<UserProfile?> getUserProfile();
  Future<void> saveUserProfile(UserProfile profile);
  Future<void> clearAllData();
}

class HiveUserRepo implements UserRepo {
  static const String boxName = 'user_profile';
  static const String profileKey = 'main_profile';
  late Box<UserProfile> _box;

  @override
  Future<void> init() async {
    // 어댑터 중복 등록 방지
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(UserProfileAdapter());

    // 앱에선 initFlutter, 테스트에서 이미 Hive.init(...)된 경우 예외 무시
    try {
      await Hive.initFlutter();
    } catch (_) {
      // 이미 초기화된 환경(예: 테스트)에서는 무시
    }

    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<UserProfile>(boxName);
    } else {
      _box = await Hive.openBox<UserProfile>(boxName);
    }
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    return _box.get(profileKey);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _box.put(profileKey, profile);
  }

  @override
  Future<void> clearAllData() async => _box.clear();
}
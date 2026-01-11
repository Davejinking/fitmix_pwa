# Hive TypeId 변경 및 마이그레이션 가이드

## 🔧 문제 상황

### 에러 메시지
```
HiveError: Cannot read, unknown typeId: 36. 
Did you forget to register an adapter?
```

### 원인
- 기존 Hive 데이터베이스에 저장된 데이터의 typeId가 변경됨
- UserProfile의 typeId가 4 → 5로 변경되었지만, 기존 데이터는 typeId 4로 저장되어 있음
- Hive는 기존 데이터를 읽을 수 없어서 에러 발생

## ✅ 해결 방법

### 자동 복구 시스템 구현

**lib/data/user_repo.dart**
```dart
@override
Future<void> init() async {
  // 어댑터 등록
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(UserProfileAdapter());
  }

  try {
    // 정상적으로 박스 열기 시도
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<UserProfile>(boxName);
    } else {
      _box = await Hive.openBox<UserProfile>(boxName);
    }
  } catch (e) {
    // ❌ 에러 발생 시 자동 복구
    print('⚠️ UserProfile 박스 오류 감지: $e');
    print('🔄 박스 재생성 중...');
    
    // 기존 박스 삭제
    await Hive.deleteBoxFromDisk(boxName);
    
    // 새 박스 생성
    _box = await Hive.openBox<UserProfile>(boxName);
    
    print('✅ UserProfile 박스 재생성 완료');
  }
}
```

### 동작 방식

1. **정상 케이스**: 박스가 정상적으로 열림
2. **에러 케이스**: 
   - TypeId 불일치 감지
   - 기존 박스 자동 삭제
   - 새 박스 생성
   - 사용자 데이터는 초기화됨 (재입력 필요)

## 📊 TypeId 맵 (최종)

```dart
typeId: 1  → Exercise
typeId: 2  → Session
typeId: 3  → ExerciseSet
typeId: 4  → Routine
typeId: 5  → UserProfile (변경됨: 4 → 5)
typeId: 10 → ExerciseLibraryItem
```

## 🚨 주의사항

### 데이터 손실
- UserProfile 박스가 재생성되면 **기존 사용자 프로필 데이터가 삭제됨**
- 사용자는 다시 프로필을 입력해야 함
- 운동 기록(Session)은 영향 없음 (다른 박스)

### 프로덕션 환경
프로덕션에서는 더 정교한 마이그레이션이 필요:

1. **데이터 백업**
```dart
// 기존 데이터 읽기 (old typeId)
final oldBox = await Hive.openBox('user_profile_backup');
final oldData = oldBox.get('main_profile');

// 새 형식으로 변환
final newData = UserProfile(
  weight: oldData['weight'],
  height: oldData['height'],
  // ...
  isPro: false, // 새 필드 기본값
);

// 새 박스에 저장
await newBox.put('main_profile', newData);
```

2. **버전 관리**
```dart
class UserProfile {
  static const int schemaVersion = 2;
  
  @HiveField(8)
  int version;
}
```

## 🛠️ 수동 마이그레이션 (필요시)

### 방법 1: 앱 데이터 삭제
```bash
# iOS 시뮬레이터
xcrun simctl uninstall booted com.your.app

# Android 에뮬레이터
adb uninstall com.your.app

# 재설치
flutter run
```

### 방법 2: Hive 디렉토리 삭제
```dart
import 'package:fitmix_pwa/core/hive_migration.dart';

// 앱 시작 시 (개발 중에만)
if (kDebugMode) {
  await HiveMigration.clearAllBoxes();
}
```

### 방법 3: 특정 박스만 삭제
```dart
await HiveMigration.deleteBox('user_profile');
```

## ✅ 테스트 체크리스트

### 신규 설치
- [ ] 앱 설치
- [ ] 프로필 입력
- [ ] 루틴 저장 (3개)
- [ ] 앱 재시작
- [ ] 데이터 유지 확인

### 업그레이드 (기존 사용자)
- [ ] 기존 앱 실행
- [ ] 업데이트 설치
- [ ] 앱 실행
- [ ] 자동 복구 로그 확인
- [ ] 프로필 재입력
- [ ] 운동 기록 유지 확인

## 📝 로그 메시지

### 정상 케이스
```
✅ UserProfile 박스 열기 완료
✅ Routine 박스 열기 완료
```

### 복구 케이스
```
⚠️ UserProfile 박스 오류 감지: HiveError: Cannot read, unknown typeId: 36
🔄 박스 재생성 중...
✅ UserProfile 박스 재생성 완료
```

### 실패 케이스
```
❌ 박스 재생성 실패: [에러 메시지]
```

## 🔮 향후 개선 사항

### Phase 1: 현재 (완료)
- ✅ 자동 복구 시스템
- ✅ 에러 로깅

### Phase 2: 데이터 보존
- [ ] 마이그레이션 스크립트
- [ ] 백업/복원 기능
- [ ] 버전 관리

### Phase 3: 클라우드 동기화
- [ ] Firebase/Supabase 연동
- [ ] 자동 백업
- [ ] 기기 간 동기화

## 💡 베스트 프랙티스

### TypeId 관리
```dart
// lib/core/hive_type_ids.dart
class HiveTypeIds {
  static const int exercise = 1;
  static const int session = 2;
  static const int exerciseSet = 3;
  static const int routine = 4;
  static const int userProfile = 5;
  static const int exerciseLibraryItem = 10;
  
  // 새 타입 추가 시 여기에 문서화
  // static const int newType = 6;
}
```

### 스키마 변경 시
1. TypeId는 절대 변경하지 않기
2. 새 필드 추가 시 기본값 제공
3. 마이그레이션 스크립트 작성
4. 테스트 환경에서 먼저 검증

## 🎯 결론

현재 구현된 자동 복구 시스템으로:
- ✅ TypeId 변경 에러 자동 해결
- ✅ 앱 크래시 방지
- ✅ 사용자 경험 개선

단점:
- ⚠️ UserProfile 데이터 손실 (재입력 필요)
- ⚠️ 운동 기록은 유지됨

프로덕션 배포 전에 더 정교한 마이그레이션 구현 권장!

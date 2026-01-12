# Iron Log - Master Documentation

> **최종 업데이트**: 2026년 1월 12일 (23:05)  
> **버전**: 1.0.0  
> **상태**: 🚀 MVP 개발 중

---

## 📑 목차 (Table of Contents)

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택 & 코딩 규칙](#2-기술-스택--코딩-규칙)
3. [데이터베이스 스키마](#3-데이터베이스-스키마)
4. [현재 기능 & 상태](#4-현재-기능--상태)
5. [프로젝트 파일 구조](#5-프로젝트-파일-구조)
6. [최근 업데이트](#6-최근-업데이트)

---

## 1. 프로젝트 개요

### 🎯 컨셉
**Iron Log**는 Noir & Dark 감성의 웨이트 트레이닝 기록 앱입니다.

- **Iron (쇠)**: 무게, 강철 같은 의지
- **Log (기록)**: 운동 일지, 데이터 로그
- **타겟 시장**: 글로벌 (북미, 일본)
- **타겟 유저**: 진지한 웨이트 트레이닝 애호가

### 🎨 핵심 가치
1. **직관성**: 복잡한 설정 없이 바로 기록
2. **무게감**: Noir 미학, Courier 폰트, 대문자 타이포그래피
3. **심플함**: 불필요한 기능 제거, 본질에 집중

### 🌍 다국어 전략: "Hybrid Noir"
- **Design Elements (영어 고정)**: 타이틀, 라벨, 상태 메시지
  - 예: `WEEKLY STATUS`, `MONTHLY GOAL` (하드코딩)
  - 이유: 브랜드 아이덴티티, Noir 미학 유지
- **Usability Elements (다국어)**: 버튼, 입력 힌트, 에러 메시지, **탭 버튼**
  - 예: `운동 시작` / `Start Workout` / `ワークアウト開始`
  - 예: `루틴` / `Routines` / `ルーティン`
  - 예: `엑서사이즈` / `Exercises` / `エクササイズ`
  - 이유: 사용자 경험, 접근성

### 💰 수익화 모델
- **Free**: 기본 운동 기록, 휴식 타이머, 템포 모드
- **Iron Pro ($3.99/월)**: 고급 분석, 클라우드 백업, 테마, 광고 제거
- **Coach Pro ($20~/월)**: 회원 관리, 프로그램 배포 (Phase 3)

---

## 2. 기술 스택 & 코딩 규칙

### 📚 Tech Stack

#### Frontend
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **UI Components**: Material Design 3

#### State Management & Data
- **Local Database**: Hive (NoSQL, TypeAdapter)
- **Dependency Injection**: GetIt
- **State Management**: StatefulWidget (필요시 Riverpod 도입 예정)

#### Localization
- **Package**: `flutter_localizations`, `intl`
- **Base Language**: English (en)
- **Supported Languages**: English, Korean (ko), Japanese (ja)
- **Strategy**: Hybrid Noir (Design Elements in English, Usability in local language)

#### Charts & Visualization
- **Charts**: `fl_chart` (Line, Bar, Heatmap)
- **Animations**: `confetti`, `shimmer`

#### Audio & Haptics
- **TTS**: `flutter_tts` (템포 모드 음성 안내)
- **Audio**: `audioplayers` (비프음)
- **Haptics**: Flutter built-in

#### Other
- **Calendar**: `table_calendar`
- **Image Picker**: `image_picker`
- **Authentication**: `google_sign_in`

### 📐 코딩 규칙 (Coding Conventions)

#### 1. 파일 & 폴더 구조
```
lib/
├── core/           # 공통 설정 (테마, 상수, DI)
├── data/           # Repository 레이어 (Hive 접근)
├── models/         # Hive 모델 (TypeAdapter)
├── pages/          # 화면 (Screen/Page)
├── widgets/        # 재사용 위젯
├── services/       # 비즈니스 로직 (Gamification, Tempo)
├── l10n/           # 다국어 ARB 파일
└── utils/          # 유틸리티 함수
```

#### 2. 네이밍 규칙
- **파일명**: `snake_case.dart` (예: `home_page.dart`)
- **클래스명**: `PascalCase` (예: `HomePage`)
- **변수/함수명**: `camelCase` (예: `getUserProfile()`)
- **상수**: `UPPER_SNAKE_CASE` (예: `MAX_ROUTINE_LIMIT`)
- **Private**: `_leadingUnderscore` (예: `_buildWidget()`)

#### 3. 위젯 구조
```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. 변수 선언
  late SessionRepo sessionRepo;
  
  // 2. initState / dispose
  @override
  void initState() {
    super.initState();
    sessionRepo = getIt<SessionRepo>();
  }
  
  // 3. build 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
  
  // 4. Private 헬퍼 메서드
  Widget _buildSection() { ... }
  Future<void> _loadData() async { ... }
}
```

#### 4. Hive 모델 규칙
```dart
@HiveType(typeId: X)
class ModelName extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  // Constructor
  ModelName({required this.id, required this.name});
  
  // copyWith 메서드 필수
  ModelName copyWith({String? id, String? name}) { ... }
  
  // toString 오버라이드 권장
  @override
  String toString() => 'ModelName(id: $id, name: $name)';
}
```

#### 5. 다국어 사용 규칙
```dart
// ✅ GOOD: Design Element (영어 하드코딩)
const Text(
  'WEEKLY STATUS',
  style: TextStyle(
    fontFamily: 'Courier',
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  ),
)

// ✅ GOOD: Usability Element (l10n 사용)
ElevatedButton(
  onPressed: () {},
  child: Text(context.l10n.startSession),
)

// ❌ BAD: Design Element를 번역
Text(context.l10n.weeklyStatus)

// ❌ BAD: Usability Element를 하드코딩
ElevatedButton(
  child: const Text('Start Session'),
)
```

#### 6. 테마 사용
```dart
// Iron Theme 사용
import '../core/iron_theme.dart';

Container(
  color: IronTheme.background,  // #000000
  child: Text(
    'TEXT',
    style: TextStyle(
      color: IronTheme.textHigh,  // White
      fontFamily: 'Courier',
    ),
  ),
)
```

#### 7. Repository 패턴
```dart
// data/session_repo.dart
class SessionRepo {
  final Box<Session> _box;
  
  SessionRepo(this._box);
  
  // CRUD 메서드
  Future<void> put(Session session) async { ... }
  Future<Session?> get(String ymd) async { ... }
  Future<List<Session>> getAll() async { ... }
  Future<void> delete(String ymd) async { ... }
}

// 사용
final sessionRepo = getIt<SessionRepo>();
await sessionRepo.put(session);
```

---

## 3. 데이터베이스 스키마

### 📦 Hive Models

#### 3.1 Session (TypeId: 2)
운동 세션 (날짜별 운동 기록)

```dart
@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0) String ymd;                    // yyyy-MM-dd
  @HiveField(1) List<Exercise> exercises;      // 운동 목록
  @HiveField(2) bool isRest;                   // 휴식일 여부
  @HiveField(3) int durationInSeconds;         // 운동 시간 (초)
  @HiveField(4) bool isCompleted;              // 완료 여부
  @HiveField(5) String? routineName;           // 루틴 이름 (옵션)
}
```

**주요 메서드**:
- `get totalVolume`: 총 볼륨 계산 (무게 × 횟수 × 세트)
- `get hasExercises`: 운동이 있는지 확인
- `get isWorkoutDay`: 운동일인지 확인

#### 3.2 Exercise (TypeId: 1)
개별 운동

```dart
@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0) String name;                   // 운동 이름
  @HiveField(1) String bodyPart;               // 부위 (chest/back/legs...)
  @HiveField(2) List<ExerciseSet> sets;        // 세트 목록
  @HiveField(3) int eccentricSeconds;          // 내리는 시간 (템포)
  @HiveField(4) int concentricSeconds;         // 올리는 시간 (템포)
  @HiveField(5) bool isTempoEnabled;           // 템포 모드 활성화
  @HiveField(6) int targetSets;                // 목표 세트 수
  @HiveField(7) String targetReps;             // 목표 횟수 (예: "8-12")
  @HiveField(8) String? memo;                  // 메모 (옵션)
}
```

#### 3.3 ExerciseSet (TypeId: 3)
개별 세트

```dart
@HiveType(typeId: 3)
class ExerciseSet extends HiveObject {
  @HiveField(0) double weight;                 // 무게 (kg)
  @HiveField(1) int reps;                      // 횟수
  @HiveField(2) bool isCompleted;              // 완료 여부
}
```

#### 3.4 Routine (TypeId: 4)
저장된 루틴

```dart
@HiveType(typeId: 4)
class Routine extends HiveObject {
  @HiveField(0) String id;                     // UUID
  @HiveField(1) String name;                   // 루틴 이름
  @HiveField(2) List<Exercise> exercises;      // 운동 목록
  @HiveField(3) DateTime createdAt;            // 생성일
  @HiveField(4) DateTime? lastUsedAt;          // 마지막 사용일
  @HiveField(5) List<String> tags;             // 태그 (예: ["PUSH", "CHEST"])
}
```

**제한사항**:
- Free 사용자: 최대 3개 루틴
- Pro 사용자: 무제한

#### 3.5 UserProfile (TypeId: 5)
사용자 프로필

```dart
@HiveType(typeId: 5)
class UserProfile extends HiveObject {
  @HiveField(0) double weight;                 // 체중 (kg)
  @HiveField(1) int height;                    // 키 (cm)
  @HiveField(2) DateTime birthDate;            // 생년월일
  @HiveField(3) String gender;                 // 성별
  @HiveField(4) int monthlyWorkoutGoal;        // 월간 운동 목표 (일)
  @HiveField(5) Uint8List? profileImage;       // 프로필 이미지
  @HiveField(6) double monthlyVolumeGoal;      // 월간 볼륨 목표 (kg)
  @HiveField(7) bool isPro;                    // Pro 사용자 여부
}
```

#### 3.6 ExerciseLibraryItem (TypeId: 10)
운동 라이브러리 (다국어 지원)

```dart
@HiveType(typeId: 10)
class ExerciseLibraryItem extends HiveObject {
  @HiveField(0) String id;                     // UUID
  @HiveField(1) String targetPart;             // 부위
  @HiveField(2) String equipmentType;          // 장비 (barbell/dumbbell...)
  @HiveField(3) String nameKr;                 // 한국어 이름
  @HiveField(4) String nameEn;                 // 영어 이름
  @HiveField(5) String nameJp;                 // 일본어 이름
  @HiveField(6) DateTime? createdAt;           // 생성일
  @HiveField(7) DateTime? updatedAt;           // 수정일
}
```

**주요 메서드**:
- `getLocalizedName(BuildContext)`: 현재 로케일에 맞는 이름 반환

### 🗄️ Hive Box 구조

```dart
// Box 이름 및 TypeId 매핑
sessions        -> Box<Session>              (TypeId: 2)
exercises       -> Box<Exercise>             (TypeId: 1)
routines        -> Box<Routine>              (TypeId: 4)
userProfile     -> Box<UserProfile>          (TypeId: 5)
exerciseLibrary -> Box<ExerciseLibraryItem>  (TypeId: 10)
settings        -> Box<dynamic>              (일반 설정)
```

### 🔄 데이터 흐름

```
User Action
    ↓
Page/Widget
    ↓
Repository (data/)
    ↓
Hive Box
    ↓
Local Storage
```

---

## 4. 현재 기능 & 상태

### ✅ 완료된 기능 (Completed)

#### 4.1 Core Features
- [x] **운동 기록 시스템**
  - 날짜별 세션 생성/수정/삭제
  - 운동 추가/제거/순서 변경
  - 세트별 무게/횟수 입력
  - 완료 체크 기능
  
- [x] **루틴 관리**
  - 루틴 생성/수정/삭제
  - 루틴 불러오기 (세션에 적용)
  - 동적 태그 시스템 (PUSH/PULL/LEGS/커스텀)
  - Free 사용자 제한 (최대 3개)

- [x] **운동 라이브러리**
  - 40개 기본 운동 (다국어 지원)
  - 부위별/장비별 필터링
  - 즐겨찾기 기능
  - 커스텀 운동 추가

- [x] **캘린더 & 히트맵**
  - 월간 캘린더 뷰
  - 운동 기록 히트맵
  - 휴식일 설정
  - 날짜별 운동 계획

#### 4.2 UI/UX
- [x] **Noir 테마**
  - 순수 블랙 배경 (#000000)
  - Courier 폰트
  - 대문자 타이포그래피
  - 미니멀 디자인

- [x] **다국어 (Hybrid Noir)**
  - 영어 (기본)
  - 한국어
  - 일본어
  - Design Elements 영어 고정
  - Usability Elements 다국어

- [x] **애니메이션**
  - 페이지 전환 애니메이션
  - Shimmer 로딩
  - Confetti 효과 (업적 달성)

#### 4.3 Advanced Features
- [x] **템포 모드**
  - TTS 음성 안내
  - 비프음 모드
  - 무음 + 햅틱 모드
  - Eccentric/Concentric 타이밍

- [x] **휴식 타이머**
  - 커스텀 시간 설정
  - 화면 표시 옵션
  - 타이머 조절

- [x] **게이미피케이션** (삭제됨 - 2026-01-12)
  - ~~XP/레벨 시스템~~
  - ~~스트릭 (연속 운동일)~~
  - ~~업적 시스템~~
  - ~~리그 시스템~~
  - **사유**: 본질에 집중, 심플함 유지

#### 4.4 Analytics
- [x] **기본 통계**
  - 주간 운동 현황
  - 월간 목표 진행률
  - 부위별 볼륨
  - 운동 시간 추적

- [x] **히트맵**
  - 6개월 운동 기록 시각화
  - 강도별 색상 구분

### 🚧 진행 중 (In Progress)

- [ ] **Iron Pro 구독**
  - 결제 시스템 연동
  - Pro 기능 잠금/해제
  - 구독 관리 페이지

- [ ] **고급 분석**
  - 주간/월간 리포트
  - 부위별 밸런스 분석
  - 볼륨 트렌드 차트

- [ ] **클라우드 백업**
  - Firebase 연동
  - 자동 백업/복원
  - 기기 간 동기화

### 📋 예정 (Backlog)

#### Phase 1: Athlete 모드 완성
- [ ] **데이터 내보내기**
  - CSV 내보내기
  - 운동 기록 공유 이미지 생성
  
- [ ] **설정 개선**
  - 테마 변경 (Pro)
  - 단위 설정 (kg/lb)
  - 언어 수동 변경

- [ ] **온보딩**
  - 첫 실행 튜토리얼
  - 샘플 데이터 제공

#### Phase 2: Squad 모드 (커뮤니티)
- [ ] 친구 추가/팔로우
- [ ] 운동 기록 공유
- [ ] 리더보드
- [ ] 챌린지

#### Phase 3: Coach 모드 (SaaS)
- [ ] 회원 관리 대시보드
- [ ] 프로그램 배포
- [ ] 실시간 피드백
- [ ] 결제 연동

### 🐛 알려진 이슈 (Known Issues)

1. **캘린더 날짜 변경**
   - 운동 중 날짜 변경 시 데이터 손실 가능
   - 해결: 운동 중 날짜 변경 차단

2. **템포 모드 TTS**
   - iOS 시뮬레이터에서 TTS 작동 안 함
   - 실제 기기에서는 정상 작동

3. **이미지 피커**
   - 프로필 사진 선택 후 앱 재시작 필요
   - 해결 예정

### 📊 개발 진행률

```
Phase 1 (Athlete 모드): ████████░░ 80%
├─ Core Features:       ██████████ 100%
├─ UI/UX:               ██████████ 100%
├─ Advanced Features:   ████████░░ 80%
└─ Monetization:        ████░░░░░░ 40%

Phase 2 (Squad 모드):   ░░░░░░░░░░ 0%
Phase 3 (Coach 모드):   ░░░░░░░░░░ 0%
```

---

## 5. 프로젝트 파일 구조

### 📁 전체 구조

```
fitmix_pwa/
├── lib/
│   ├── core/                    # 공통 설정 및 유틸리티
│   │   ├── iron_theme.dart      # Noir 테마 정의
│   │   ├── l10n_extensions.dart # context.l10n 확장
│   │   ├── service_locator.dart # GetIt DI 설정
│   │   ├── error_handler.dart   # 에러 처리
│   │   ├── constants.dart       # 상수 정의
│   │   └── subscription_limits.dart # Pro 제한 설정
│   │
│   ├── data/                    # Repository 레이어
│   │   ├── session_repo.dart    # 세션 CRUD
│   │   ├── routine_repo.dart    # 루틴 CRUD
│   │   ├── user_repo.dart       # 사용자 프로필
│   │   ├── exercise_library_repo.dart # 운동 라이브러리
│   │   ├── settings_repo.dart   # 설정
│   │   └── auth_repo.dart       # 인증
│   │
│   ├── models/                  # Hive 모델
│   │   ├── session.dart         # 운동 세션
│   │   ├── exercise.dart        # 개별 운동
│   │   ├── exercise_set.dart    # 세트
│   │   ├── routine.dart         # 루틴
│   │   ├── user_profile.dart    # 사용자 프로필
│   │   ├── exercise_library.dart # 운동 라이브러리
│   │   ├── achievement.dart     # 업적 (미사용)
│   │   └── gamification.dart    # 게이미피케이션 (미사용)
│   │
│   ├── pages/                   # 화면
│   │   ├── shell_page.dart      # 메인 네비게이션
│   │   ├── home_page.dart       # 홈 (대시보드)
│   │   ├── calendar_page.dart   # 캘린더
│   │   ├── library_page_v2.dart # 라이브러리 (루틴/운동)
│   │   ├── analysis_page.dart   # 분석
│   │   ├── active_workout_page.dart # 운동 중 화면
│   │   ├── exercise_selection_page_v2.dart # 운동 선택
│   │   ├── profile_page.dart    # 프로필
│   │   ├── settings_page.dart   # 설정
│   │   ├── upgrade_page.dart    # Pro 업그레이드
│   │   ├── login_page.dart      # 로그인
│   │   ├── onboarding_page.dart # 온보딩
│   │   └── splash_page.dart     # 스플래시
│   │
│   ├── widgets/                 # 재사용 위젯
│   │   ├── calendar/
│   │   │   ├── calendar_modal_sheet.dart # 캘린더 모달
│   │   │   └── week_strip.dart  # 주간 스트립
│   │   ├── common/
│   │   │   └── iron_app_bar.dart # 공통 앱바
│   │   ├── modals/
│   │   │   └── exercise_detail_modal.dart # 운동 상세
│   │   ├── workout/
│   │   │   └── exercise_card.dart # 운동 카드
│   │   ├── tactical_exercise_list.dart # 운동 목록
│   │   ├── rest_timer_bar.dart  # 휴식 타이머
│   │   ├── tempo_countdown_modal.dart # 템포 카운트다운
│   │   ├── workout_heatmap.dart # 히트맵
│   │   └── set_input_card.dart  # 세트 입력
│   │
│   ├── services/                # 비즈니스 로직
│   │   ├── tempo_controller.dart # 템포 모드 컨트롤러
│   │   ├── rhythm_engine.dart   # 리듬 엔진
│   │   ├── tempo_metronome_service.dart # 메트로놈
│   │   ├── exercise_seeding_service.dart # 운동 시딩
│   │   ├── gamification_service.dart # 게이미피케이션 (미사용)
│   │   └── achievement_service.dart # 업적 (미사용)
│   │
│   ├── l10n/                    # 다국어
│   │   ├── app_en.arb           # 영어
│   │   ├── app_ko.arb           # 한국어
│   │   ├── app_ja.arb           # 일본어
│   │   └── app_localizations.dart # 생성된 파일
│   │
│   ├── utils/                   # 유틸리티
│   │   ├── dummy_data_generator.dart # 더미 데이터
│   │   └── sound_generator.dart # 사운드 생성
│   │
│   └── main.dart                # 앱 진입점
│
├── assets/
│   ├── fonts/                   # Pretendard, Courier
│   ├── sounds/                  # 비프음
│   ├── icons/                   # 아이콘
│   ├── images/                  # 이미지
│   └── data/
│       └── exercise_library.json # 운동 라이브러리 JSON
│
├── doc/                         # 문서
│   ├── IRON_LOG_MASTER.md       # 🔥 이 문서
│   ├── ROADMAP.md               # 로드맵
│   ├── AGENTS.md                # AI 에이전트 규칙
│   ├── 260112_Hybrid_Noir_Localization.md # 다국어 전략
│   └── tempo_engine_implementation_summary.md # 템포 엔진
│
├── test/                        # 테스트
│   └── widget_test.dart
│
├── pubspec.yaml                 # 패키지 설정
├── l10n.yaml                    # 다국어 설정
├── analysis_options.yaml        # Lint 설정
└── README.md                    # 프로젝트 소개
```

### 📦 주요 패키지 (pubspec.yaml)

```yaml
dependencies:
  flutter_localizations:         # 다국어
  table_calendar: ^3.1.2         # 캘린더
  hive: ^2.2.3                   # NoSQL DB
  hive_flutter: ^1.1.0           # Hive Flutter 지원
  intl: ^0.20.2                  # 날짜/숫자 포맷
  fl_chart: ^0.66.0              # 차트
  confetti: ^0.7.0               # 애니메이션
  shimmer: ^3.0.0                # 로딩 효과
  flutter_tts: ^4.2.0            # TTS
  audioplayers: ^6.1.0           # 오디오
  get_it: ^8.0.2                 # DI
  image_picker: ^1.1.2           # 이미지 선택
  google_sign_in: ^6.2.1         # Google 로그인

dev_dependencies:
  build_runner: ^2.4.7           # 코드 생성
  hive_generator: ^2.0.1         # Hive TypeAdapter 생성
  mockito: ^5.4.4                # 테스트 Mock
  flutter_lints: ^5.0.0          # Lint
```

### 🔧 빌드 & 실행

```bash
# 패키지 설치
flutter pub get

# Hive TypeAdapter 생성
flutter packages pub run build_runner build --delete-conflicting-outputs

# 다국어 파일 생성
flutter gen-l10n

# iOS 시뮬레이터 실행
flutter run -d iphone

# 빌드
flutter build ios --simulator
flutter build apk --release
```

### 🎯 핵심 파일 설명

#### `lib/main.dart`
- 앱 진입점
- Hive 초기화
- GetIt DI 설정
- MaterialApp 설정

#### `lib/core/service_locator.dart`
- GetIt을 사용한 의존성 주입
- Repository 싱글톤 등록

#### `lib/pages/shell_page.dart`
- 하단 네비게이션 바
- 페이지 전환 관리
- 5개 탭: Home, Calendar, Library, Analysis, Profile

#### `lib/data/session_repo.dart`
- 세션 CRUD 로직
- 날짜 포맷 변환 (`ymd()`)
- 볼륨 계산

#### `lib/models/session.dart`
- Hive 모델 정의
- TypeAdapter 생성 (`session.g.dart`)
- Extension으로 `totalVolume` 계산

---

## 6. 최근 업데이트

### 📅 2026-01-12 (일요일)

#### 6.1 문서 통합 및 정리
- **작업 내용**:
  - 43개의 중복/구버전 문서를 `doc/archive/`로 이동
  - `IRON_LOG_MASTER.md` 생성 (500줄, 5개 섹션)
  - `README.md` 업데이트 (프로젝트 개요 및 빠른 시작 가이드)
  - `DOCUMENTATION_CLEANUP_SUMMARY.md` 작성 (정리 과정 문서화)
- **결과**: 
  - `doc/` 폴더에 6개의 핵심 문서만 유지
  - 프로젝트 정보가 단일 마스터 문서로 통합

#### 6.2 Hybrid Noir 다국어 전략 구현
- **전략 정의**:
  - **Design Elements** (영어 고정): 타이틀, 라벨, 상태 메시지
    - 예: `WEEKLY STATUS`, `MONTHLY GOAL`
    - 이유: 브랜드 아이덴티티, Noir 미학 유지
  - **Usability Elements** (다국어): 버튼, 힌트, 에러 메시지, 탭 버튼
    - 예: `운동 시작` / `Start Workout` / `ワークアウト開始`
    - 이유: 사용자 경험, 접근성

- **구현 파일**:
  - `lib/pages/home_page.dart`: Design Element 타이틀 하드코딩
  - `lib/pages/library_page_v2.dart`: 초기에는 "EXERCISES" 하드코딩 (후에 수정)
  - ARB 파일 정리: Design Element 키 제거

#### 6.3 일본어 로케일 테스트 및 수정
- **테스트 환경**: iPhone 시뮬레이터 일본어 (ja_JP) 설정
- **로케일 감지 확인**: 
  ```
  flutter: 🌐 Detected Device Locale: ja
  flutter: ✅ Matched locale: ja
  ```

#### 6.4 번역 일관성 개선
**문제**: "새로운 운동 추가" vs "카스텀 운동 추가" 불일치

**수정**:
- `lib/l10n/app_ja.arb`:
  ```json
  "addCustomExercise": "新しい運動を追加"  // 변경 전: "カスタム運動追加"
  ```
- `lib/l10n/app_ko.arb`:
  ```json
  "addCustomExercise": "새로운 운동 추가"  // 이미 올바름
  ```

#### 6.5 탭 버튼 다국어 처리
**문제**: "EXERCISES" 탭이 영어로 하드코딩되어 있음 (Design Element로 잘못 분류)

**수정**:
1. **탭 버튼을 Usability Element로 재분류**
   - 이유: 탭은 네비게이션 요소로 사용자 경험에 직접 영향
   
2. **코드 수정** (`lib/pages/library_page_v2.dart`):
   ```dart
   // 변경 전
   child: const Text('EXERCISES'),
   
   // 변경 후
   child: Text(l10n.exercise.toUpperCase()),
   ```

3. **번역 추가/수정**:
   - `app_ja.arb`:
     ```json
     "exercise": "エクササイズ"  // 변경 전: "運動"
     ```
   - `app_ko.arb`:
     ```json
     "exercise": "엑서사이즈"  // 변경 전: "운동"
     ```
   - 이유: "루틴" (ルーティン/루틴)과 일관성 유지 (외래어는 카타카나/한글 표기)

4. **결과**:
   - 일본어: [ルーティン] [エクササイズ]
   - 한국어: [루틴] [엑서사이즈]
   - 영어: [ROUTINES] [EXERCISES]

#### 6.6 온보딩 페이지 다국어 처리
**문제**: 온보딩 페이지가 한국어로 하드코딩되어 있음

**수정**:
1. **ARB 파일에 키 추가** (모든 언어):
   ```json
   "skip": "Skip",
   "onboardingTitle1": "Welcome to Iron Log",
   "onboardingSubtitle1": "Track your workouts with precision",
   "onboardingTitle2": "Build Routines",
   "onboardingSubtitle2": "Create and save your workout routines",
   "onboardingTitle3": "Track Progress",
   "onboardingSubtitle3": "Monitor your strength gains over time",
   "onboardingTitle4": "Achieve Goals",
   "onboardingSubtitle4": "Set and reach your fitness milestones",
   "next": "Next"
   ```

2. **코드 리팩토링** (`lib/pages/onboarding_page.dart`):
   ```dart
   // 변경 전
   const Text('건너뛰기'),
   
   // 변경 후
   Text(l10n.skip),
   ```
   - 모든 하드코딩된 한국어 텍스트를 `AppLocalizations` 사용으로 변경

#### 6.7 운동 선택 버튼 다국어 처리
**문제**: 운동 선택 버튼이 한국어로 하드코딩되어 일본어 모드에서도 한국어 표시

**수정**:
1. **ARB 파일에 키 추가**:
   ```json
   "addExercises": "Add {count} exercises"
   ```
   - 일본어: "{count}個追加 (ADD {count})"
   - 한국어: "{count}개 추가하기 (ADD {count})"

2. **코드 수정** (`lib/widgets/tactical_exercise_list.dart`):
   ```dart
   // 변경 전
   child: Text('${_selectedExercises.length}개 추가하기 (ADD ${_selectedExercises.length})'),
   
   // 변경 후
   child: Text(l10n.addExercises(_selectedExercises.length)),
   ```

#### 6.8 커밋 및 푸시
- 모든 변경사항 커밋
- 원격 저장소에 푸시 완료

### 📊 오늘의 성과

- ✅ 문서 통합 완료 (43개 파일 아카이브)
- ✅ Hybrid Noir 전략 구현 및 문서화
- ✅ 일본어 로케일 테스트 환경 구축
- ✅ 4개 주요 UI 컴포넌트 다국어 처리:
  1. 탭 버튼 (라이브러리 페이지)
  2. 온보딩 페이지 (전체)
  3. 운동 선택 버튼
  4. 번역 일관성 개선
- ✅ 모든 변경사항 커밋 및 푸시

### 🎯 남은 작업

1. **다국어 완성도 향상**
   - 나머지 하드코딩된 텍스트 찾아서 수정
   - 모든 페이지 일본어 테스트

2. **Iron Pro 구독 시스템**
   - 결제 연동
   - Pro 기능 잠금/해제

3. **앱 스토어 출시 준비**
   - 아이콘 디자인
   - 스크린샷 제작
   - 앱 설명 작성 (EN, JA)

---

## 📚 추가 문서

- **다국어 전략**: `doc/archive/260112_Hybrid_Noir_Localization.md`
- **템포 엔진**: `doc/archive/tempo_engine_implementation_summary.md`
- **로드맵**: `doc/ROADMAP.md`
- **AI 에이전트 규칙**: `doc/AGENTS.md`
- **문서 정리 요약**: `doc/DOCUMENTATION_CLEANUP_SUMMARY.md`

---

## 🚀 다음 단계

1. **Iron Pro 구독 시스템 구현**
   - RevenueCat 또는 Stripe 연동
   - Pro 기능 잠금/해제 로직

2. **고급 분석 기능**
   - 주간/월간 리포트
   - 부위별 밸런스 분석

3. **클라우드 백업**
   - Firebase 연동
   - 자동 백업/복원

4. **앱 스토어 출시 준비**
   - 아이콘 디자인
   - 스크린샷 제작
   - 앱 설명 작성 (EN, JA)

---

**문서 작성**: Kiro AI Assistant  
**최종 업데이트**: 2026년 1월 12일  
**버전**: 1.0.0

# Iron Log - Master Documentation

> **최종 업데이트**: 2026년 1월 14일 (15:00)  
> **버전**: 1.0.2  
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

### 📅 2026-01-14 (화요일)

#### 6.10 휴식 타이머 UI 완전 재설계 - Retro-Terminal/Raw Data Style

**목표**: 일반적인 주방 타이머 느낌에서 Iron Log의 Noir 아이덴티티에 맞는 터미널 스타일로 전환

##### 6.10.1 디자인 철학 변경
**Before**: Industrial/Tactical (Electric Cyan, 얇은 링, 각진 버튼)
**After**: Retro-Terminal/Raw Data (순수 데이터 표시, 영수증 스타일)

**핵심 변경사항**:
- 원형 프로그레스 링 완전 제거
- 거대한 모노스페이스 타이머 (80pt Courier)
- 점선 구분선 (영수증 느낌)
- 사각형 아웃라인 버튼

##### 6.10.2 전체 화면 타이머 (Full Screen Timer)

**레이아웃**:
```
┌─────────────────────────────┐
│ [X]                         │
│                             │
│      REST PERIOD            │  ← 11pt, grey, uppercase
│                             │
│        01:30                │  ← 80pt, Courier, white
│                             │
│  - - - - - - - - - - - -    │  ← 점선 구분선
│                             │
│  [-1M] [-10] [+10] [+1M]    │  ← 사각형 버튼
│                             │
│  ┌─────────────────────┐    │
│  │   SKIP REST         │    │  ← 아웃라인 버튼
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**스타일 상세**:
- **배경**: Pure Black (#000000)
- **헤더**: "REST PERIOD" (11pt, grey[600], Courier, 2.0 letter-spacing)
- **타이머**: 80pt, Courier, w900, -2.0 letter-spacing, height: 1.0
- **점선**: white15 opacity, 2px letter-spacing
- **조절 버튼**: 72x48, white24 border, 4px radius, white03 background
- **스킵 버튼**: white15 border, 8px radius, white03 background

##### 6.10.3 미니 타이머 (Bottom Bar Timer)

**레이아웃**:
```
┌─────────────────────────────┐
│ REST PERIOD            [X]  │  ← 10pt header
│                             │
│        01:30                │  ← 48pt timer
│                             │
│  - - - - - - - - - - - -    │  ← 점선
│                             │
│  [-1M] [-10] [+10] [+1M]    │  ← 36px 버튼
│                             │
│  ┌─────────────────────┐    │
│  │   SKIP REST         │    │  ← 48px 버튼
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**스타일 상세**:
- **위치**: 하단 고정 (bottom: 0)
- **배경**: Black, 상단 white10 border
- **타이머**: 48pt (전체 화면보다 작음)
- **조절 버튼**: 36px height (더 컴팩트)
- **스킵 버튼**: 48px height

##### 6.10.4 하단 컨트롤 바 (Bottom Control Bar) - 최종 디자인

**진화 과정**:

1. **Iteration 1**: Solid Professional Style
   - Timer: Gunmetal grey (#1C1C1E) 배경
   - End: Dark red 배경 (#2C1C1C)
   - 문제: 너무 무거움

2. **Iteration 2**: Terminal/Rectangular Style
   - Timer: white05 배경, white12 border
   - End: Transparent, red border
   - 문제: 너무 "tacky"

3. **Iteration 3**: Twin Blocks
   - 둘 다 gunmetal 배경
   - End만 red text
   - 문제: 구분이 약함

4. **Iteration 4**: Calendar Ghost Style
   - 둘 다 transparent, white24 border
   - 8px radius
   - 문제: 버튼 비율 불균형

5. **Iteration 5**: 비율 조정
   - Timer: flex 3 → 4
   - End: flex 2 → 3
   - 문제: 여전히 End 버튼 텍스트 잘림

6. **최종 (Iteration 6)**: Icon-Only End Button
   - Timer: Expanded (전체 너비 차지)
   - End: 80px 고정 너비, 아이콘만 표시
   - 결과: 깔끔하고 균형잡힌 레이아웃

**최종 스펙**:
```dart
Row(
  children: [
    // Timer Button (주요 기능)
    Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, size: 20),
            Text('01:30', style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
    ),
    SizedBox(width: 12),
    // End Button (보조 액션, 아이콘만)
    Container(
      width: 80,  // 정사각형보다 약간 넓음 (탭하기 편함)
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(
        Icons.stop_circle_outlined,
        color: Color(0xFFFF453A),  // Crimson Red
        size: 28,
      ),
    ),
  ],
)
```

##### 6.10.5 휴식 시간 설정 모달 - Machine Control Panel Style

**디자인 컨셉**: 기계 제어판 느낌

**레이아웃**:
```
┌─────────────────────────────┐
│   SET REST DURATION         │  ← 11pt, grey, uppercase
│                             │
│   [-]    150    [+]         │  ← 64pt 카운터
│        SECONDS              │  ← 10pt label
│                             │
│  [60] [90] [120] [180]      │  ← 프리셋 버튼
│                             │
│  ┌─────────────────────┐    │
│  │ SHOW ON SCREEN  [O] │    │  ← 토글
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │     CONFIRM         │    │  ← 흰색 배경
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**스타일 상세**:
- **헤더**: "SET REST DURATION" (11pt, grey[600], Courier, 2.0 spacing)
- **카운터**: 64pt, Courier, w900, white
- **+/- 버튼**: 50x50, white24 border, 4px radius
- **프리셋 버튼**: 70x40, 4px radius
  - 선택 안됨: transparent, white24 border, white text
  - 선택됨: white 배경, white border, black text
- **토글 섹션**: white12 border, 4px radius
- **확인 버튼**: white 배경, black text, 56px height

##### 6.10.6 제거된 요소

**완전 제거**:
- `_TimerRingPainter` 클래스 (원형 프로그레스)
- 모든 `CustomPaint` 위젯
- 원형 버튼 스타일
- Electric Cyan 색상 (Industrial 스타일)
- Glow 효과

**이유**: Calendar Screen의 Terminal 스타일과 일관성 유지

##### 6.10.7 타이머 동작

**자동 팝업 제약**:
- ✅ 세트 완료 시 타이머 자동 시작
- ✅ UI는 자동으로 표시되지 않음 (사용자가 탭해야 함)
- ✅ 하단 바에 타이머 값 표시
- ✅ X 버튼으로 UI 숨기기 (타이머는 계속 실행)

**UI 표시 옵션**:
- **전체 화면 모드**: `_showRestTimerOverlay = true`
- **미니 타이머 모드**: `_showRestTimerOverlay = false` (기본값)

##### 6.10.8 기술적 구현

**주요 변경사항**:
1. `_buildFullScreenTimerOverlay()`: 완전 재작성
2. `_buildMiniFloatingTimer()`: Terminal 스타일 적용
3. `_buildTerminalTimeButton()`: 새로운 사각형 버튼 (기존 `_buildCircleTimeButton` 대체)
4. `_buildMiniTerminalButton()`: 미니 타이머용 버튼
5. `_buildBottomBar()`: 최종 Ghost 스타일 + Icon-only End button
6. `_showRestTimeSettings()`: Machine Control Panel 스타일

**삭제된 메서드**:
- `_buildCircleTimeButton()`
- `_buildTacticalTimeButton()`

##### 6.10.9 파일 변경 사항

**수정된 파일**:
- `lib/pages/active_workout_page.dart`
  - 전체 화면 타이머: ~150줄 재작성
  - 미니 타이머: ~100줄 재작성
  - 하단 바: ~80줄 재작성
  - 설정 모달: ~120줄 재작성
  - 총 변경: ~450줄

##### 6.10.10 디자인 일관성

**Calendar Screen과 동일한 요소**:
- ✅ Courier 모노스페이스 폰트
- ✅ Pure Black 배경
- ✅ 점선 구분선 (영수증 스타일)
- ✅ 사각형 아웃라인 버튼
- ✅ UPPERCASE 라벨
- ✅ Ghost 스타일 (transparent + white24 border)
- ✅ 4px/8px border radius

**결과**: 앱 전체가 통일된 Terminal/Raw Data 느낌

##### 6.10.11 사용자 경험 개선

**개선 사항**:
1. **시각적 일관성**: Calendar와 Active Workout 화면이 동일한 느낌
2. **정보 집중**: 원형 링 제거로 타이머 숫자에 집중
3. **터치 편의성**: 
   - End 버튼 80px (정사각형보다 넓어 탭하기 편함)
   - 조절 버튼 크기 충분 (72x48 / 36px)
4. **안전한 UX**: End 버튼이 아이콘만 표시되어 실수 방지
5. **유연성**: 전체 화면 / 미니 타이머 선택 가능

##### 6.10.12 성능 영향
- **렌더링**: 개선 (CustomPaint 제거)
- **메모리**: 감소 (복잡한 그래픽 제거)
- **배터리**: 개선 (애니메이션 감소)

---

### 📅 2026-01-13 (월요일)

**목표**: 운동 중 화면(Active Workout Screen)에 Calendar Page와 동일한 Hardcore Noir Table Grid 스타일 적용

##### 6.10.1 디자인 동기화
**문제**: Planning Screen(Calendar)은 Noir Log 스타일로 완성되었으나, Active Workout Screen은 구형 Card Style 사용
**해결**: 두 화면의 디자인 일관성 확보

##### 6.10.2 Container & Background 변경
- **배경**: Pure Black (투명)
- **카드 제거**: 둥근 모서리 및 박스 테두리 제거
- **구분선**: 하단 Divider만 유지 (Colors.white12, 1px)
- **헤더**: 좌측 정렬 `#01 CRUNCH` 형식

##### 6.10.3 Table Grid 구조 추가
**헤더 행**: `SET | KG | REPS | DONE`
- Planning Screen과 동일한 컬럼 구조
- DONE 컬럼 추가 (체크박스)

**행 높이**: 28px (극도 압축)
**입력 스타일**: 
- `filled: true` 제거
- `OutlineInputBorder` 제거
- Raw text 스타일 (Bold, White, 15-17pt)

##### 6.10.4 Utility Row 적용
- 부위 태그: `[ BRACKET ]` 스타일 (Chip 제거)
- Info/Memo 아이콘 배치

##### 6.10.5 Column Alignment 수정

**문제**: Header와 Input Row의 정렬 축 불일치 (산만한 느낌)

**해결 과정**:

1. **Fixed Width Strategy (초기)**:
   - SET: 40px
   - KG: 80px
   - REPS: 80px
   - DONE: 50px
   - `MainAxisAlignment.center`로 중앙 정렬

2. **Full-Width Flex Layout (최종)**:
   - Golden Grid Ratio 적용:
     - SET: `Expanded(flex: 2)`
     - KG: `Expanded(flex: 4)`
     - REPS: `Expanded(flex: 4)`
     - DONE: `Expanded(flex: 2)`
   - 16px 수평 패딩
   - 화면 전체 너비 활용
   - 헤더와 입력 행 완벽 정렬

**결과**: 
- 좁은 중앙 컬럼 → 전체 너비 활용
- 빈 공간 제거
- 프로페셔널한 스프레드시트 느낌

##### 6.10.6 Top Header - Hardcore Industrial Style

**변경 사항**:
- **배경**: Pure Black (#000000)
- **폰트**: Courier 모노스페이스
- **타이머**: 52pt → 42pt (20% 감소)
- **세트 진행**: 32pt → 42pt (타이머와 동일)
- **Divider**: 하단 구분선 추가 (white12, 1px)

**결과**: 타이머 지배력 감소, 시각적 균형 확보

##### 6.10.7 Bottom Bar - Safer UX Design

**디자인 진화**:

1. **First Iteration**:
   - Rest Timer (Flex 7, 큰 버튼)
   - End Workout (Flex 3, 작은 outlined button with stop icon)

2. **Second Iteration**:
   - Rest Timer (Flex 3)
   - End Workout (Flex 1, TextButton, Crimson Red text)

3. **Third Iteration**:
   - Rest Timer (Flex 3)
   - End Workout (Flex 1, OutlinedButton, Crimson Red border 0.5px)
   - Padding: `fromLTRB(16, 10, 16, 30)` → `fromLTRB(16, 12, 16, 40)`
   - Border radius: 12px → 8px

4. **Final Spec (최종)**:
   - **Rest Timer**: 
     - Flex 3 (75% width)
     - Surface color: #2C2C2E
     - Height: 56px
     - Border radius: 8px
     - Dynamic value display
     - Active state: Blue border + tint
   - **End Button**:
     - Flex 1 (25% width)
     - OutlinedButton
     - Crimson Red (#FF453A) border 1.2px
     - Height: 56px
     - Localized text: `l10n.endWorkout`
   - **Spacing**: 12px between buttons
   - **Border**: Top border 0.5px (subtle separator)

**UX 개선**:
- Rest Timer가 주요 액션 (더 큼)
- End Workout은 파괴적 액션 (작고 빨간색)
- 실수로 종료하기 어려운 구조

##### 6.10.8 Completed Sets - Visual Feedback

**기능**: 완료된 세트 시각적 구분
**구현**:
- 체크 시 모든 텍스트 (index, weight, reps) → `Colors.grey[800]`
- `isDimmed` 파라미터 추가
- `_buildGridInput`에 dimmed 상태 전달

##### 6.10.9 Expanded Touch Area

**문제**: 체크박스가 너무 작아 터치하기 어려움
**해결**:
- DONE 컬럼 전체를 `GestureDetector`로 감싸기
- `HitTestBehavior.opaque` 설정
- 체크박스는 시각적 요소만, 탭은 부모가 처리

**코드**:
```dart
Expanded(
  flex: 2,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () { /* 체크 로직 */ },
    child: Center(
      child: Checkbox(
        value: set.isCompleted,
        onChanged: null, // GestureDetector가 처리
      ),
    ),
  ),
)
```

##### 6.10.10 파일 변경 사항

**수정된 파일**:
1. `lib/pages/active_workout_page.dart`:
   - `_buildHeader()`: Industrial style 적용
   - `_buildBottomBar()`: Final spec 구현
   - Timer/Sets 폰트 크기 균형 조정

2. `lib/widgets/workout/exercise_card.dart`:
   - Container decoration 제거 (투명)
   - Table grid header 추가
   - Utility row 추가
   - Flex layout 적용 (2:4:4:2)
   - Completed sets dimming
   - Expanded touch area
   - Smart number formatting

**변경 라인 수**: ~300줄

##### 6.10.11 시각적 일관성 확보

**Before (Active Screen)**:
```
┌─────────────────────────────┐
│ [Card Background]           │
│ 1. 크런치 [복근]            │
│                             │
│ SET 1: 100kg x 10  [Delete] │
│ SET 2: 100kg x 10  [Delete] │
│                             │
└─────────────────────────────┘
```

**After (Active Screen)**:
```
┌─────────────────────────────┐
│ #01 CRUNCH           0/5    │
│ [ 복근 ]              [i][m]│
│ SET   KG    REPS    DONE    │
│ #1   100     10      [✓]    │  ← 28px
│ #2   100     10      [ ]    │
│ #3   100     10      [ ]    │
│ #4   100     10      [ ]    │
│ #5   100     10      [ ]    │
└─────────────────────────────┘
```

**Planning Screen과 동일**:
- 동일한 헤더 구조
- 동일한 행 높이 (28px)
- 동일한 Flex ratio (2:4:4:2)
- 동일한 폰트 (Courier, 15pt)
- 동일한 색상 (Pure Black, White, Electric Blue)

##### 6.10.12 기술적 도전과 해결

**도전 1**: 두 화면의 코드 중복
- **문제**: Calendar와 Active에서 동일한 ExerciseCard 사용
- **해결**: `isWorkoutStarted` prop으로 조건부 렌더링
  - Planning: Delete button
  - Active: Checkbox

**도전 2**: Flex layout 정렬
- **문제**: Fixed width에서 Flex로 전환 시 정렬 깨짐
- **해결**: Header와 Row 모두 동일한 flex 값 적용

**도전 3**: Bottom bar 레이아웃
- **문제**: Rest Timer와 End Button의 비율 결정
- **해결**: 여러 iteration을 거쳐 3:1 비율 확정

##### 6.10.13 사용자 경험 개선

**개선 사항**:
1. **시각적 일관성**: Planning과 Active 화면이 동일한 느낌
2. **정보 밀도**: 한 화면에 더 많은 세트 표시
3. **터치 편의성**: DONE 컬럼 전체가 터치 가능
4. **시각적 피드백**: 완료된 세트 즉시 구분
5. **안전한 UX**: End 버튼이 작고 빨간색으로 실수 방지

##### 6.10.14 성능 영향
- **렌더링**: 변화 없음 (위젯 구조 유사)
- **메모리**: 약간 감소 (불필요한 decoration 제거)
- **사용자 경험**: 크게 개선 (일관성, 밀도, 터치 편의성)

---

### 📅 2026-01-13 (월요일)

#### 6.9 캘린더 페이지 UI 리팩토링 - Hardcore Noir Table Grid

**목표**: 운동 계획 입력 화면을 극도로 압축된 테이블 그리드 스타일로 전환하여 한 화면에 10개 이상의 세트 표시

##### 6.9.1 Noir 테마 적용
- **배경**: Pure Black (#000000)
- **카드 스타일 제거**: 
  - 배경색 제거 (투명)
  - Border radius 제거
  - 하단 보더만 유지 (white12, 1px)
- **폰트**: Courier 모노스페이스
- **타이포그래피**: UPPERCASE, Bold (w900)

##### 6.9.2 아코디언 헤더 단순화
**변경 전**: 인덱스 + 부위 태그 + 운동 이름 + 진행 상태
**변경 후**: 인덱스 + 운동 이름 + 진행 상태

- **제거**: 부위 태그 (복근, 가슴 등)를 헤더에서 제거
- **이유**: 시선 분산 방지, 운동 이름에 집중
- **부위 태그 이동**: 유틸리티 바(확장 시)로 이동

**코드**:
```dart
// 헤더 구조
Row(
  children: [
    Text('#01'),  // 인덱스
    Expanded(child: Text('CRUNCH')),  // 운동 이름
    Text('0 / 5'),  // 진행 상태
  ],
)
```

##### 6.9.3 유틸리티 바 추가
**위치**: 아코디언 확장 시 최상단
**구성**: 부위 태그 + Info 아이콘 + Memo 아이콘

**스타일 변화**:
1. **초기**: Container 칩 스타일 (배경색 + 둥근 모서리)
2. **최종**: 브래킷 텍스트 스타일 `[ 복근 ]`
   - 브래킷: Dark Grey (#707070)
   - 텍스트: Electric Blue (#3B82F6)
   - 폰트: Courier, 9pt, Bold

**코드**:
```dart
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: '[ ', style: TextStyle(color: Colors.grey[700])),
      TextSpan(text: '복근', style: TextStyle(color: Color(0xFF3B82F6))),
      TextSpan(text: ' ]', style: TextStyle(color: Colors.grey[700])),
    ],
  ),
)
```

##### 6.9.4 테이블 그리드 헤더 추가
**구조**: SET | KG | REPS
**스타일**:
- 폰트: Courier, 9pt, Bold
- 색상: Grey (#888888)
- 정렬: Center
- 컬럼 비율: 
  - SET: 30px (고정)
  - KG: Expanded(flex: 3)
  - REPS: Expanded(flex: 3)
  - Action: 40px (고정)

##### 6.9.5 입력 행 리팩토링
**변경 과정**:

1. **Terminal Style (중간 단계)**:
   - 모든 decoration 제거 (border: InputBorder.none)
   - 포맷: `#01 | [reps] x [weight]kg`
   - Focus 시 Electric Blue (#2196F3)

2. **Center-Aligned Magnetic (중간 단계)**:
   - 컬럼 순서: Index → Weight → x → Reps → Action
   - Spacer로 중앙 정렬
   - Weight 우측 정렬, Reps 좌측 정렬 (x에 자석처럼 붙음)

3. **Left-Aligned Table Grid (최종)**:
   - 왼쪽 정렬 (MainAxisAlignment.start)
   - "kg x" 텍스트 제거 (헤더가 설명)
   - Expanded 위젯으로 헤더와 정렬
   - Center 정렬로 깔끔한 스프레드시트 느낌

**최종 코드**:
```dart
Row(
  children: [
    SizedBox(width: 30, child: Text('#1')),  // SET
    SizedBox(width: 6),
    Expanded(flex: 3, child: TextField()),   // KG
    Expanded(flex: 3, child: TextField()),   // REPS
    SizedBox(width: 40, child: IconButton()),// Action
  ],
)
```

##### 6.9.6 고밀도 모드 (High Density Mode)
**목표**: 한 화면에 10개 이상 세트 표시

**최적화 단계**:

| 버전 | 행 높이 | 폰트 크기 | 간격 | 세트/화면 |
|------|---------|-----------|------|-----------|
| 초기 | 48px | 18pt | 8px | 4개 |
| v1 | 38px | 17pt | 4px | 6개 |
| v2 | 32px | 16pt | 2px | 8개 |
| v3 (최종) | 28px | 15pt | 1px | 10-12개 |

**최종 수치**:
- **행 높이**: 28px (SizedBox 강제)
- **입력 폰트**: 15pt, w900, height: 1.0
- **인덱스 폰트**: 11pt
- **아이콘 크기**: 13px
- **contentPadding**: EdgeInsets.zero
- **컬럼 간격**: 6px
- **유틸리티 바 padding**: vertical 1px
- **헤더 bottom padding**: 0px
- **모든 SizedBox**: 1px

**결과**:
- 세트 1개당 28px (원래 48px에서 42% 감소)
- 10개 세트 = 280px
- iPhone 화면(~700px)에서 12개 이상 세트 표시 가능

##### 6.9.7 스마트 숫자 포맷팅
**문제**: 세트 복제 시 `150` → `150.0` 표시

**해결**:
```dart
String _formatNumber(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString(); // 150.0 → 150
  }
  return value.toString(); // 2.5 → 2.5
}
```

**적용**: Weight 입력 필드 초기화 시 사용

##### 6.9.8 메모 섹션 압축
**최적화**:
- margin: 4 → 2px
- padding: 8 → 6px
- 아이콘: 12 → 10px
- 폰트: 12 → 11pt
- line height: 1.3 → 1.2
- border radius: 6 → 4px

##### 6.9.9 파일 변경 사항
**수정된 파일**:
- `lib/pages/calendar_page.dart` (주요 변경)
  - `_ExerciseCard` 위젯: 헤더 단순화
  - `_SetRowGrid` 위젯: 테이블 그리드 구조
  - `_buildGridInput` 메서드: 고밀도 입력 필드
  - 유틸리티 바 추가 및 스타일링

**변경 라인 수**: ~200줄

##### 6.9.10 시각적 결과
**Before**:
```
┌─────────────────────────────┐
│ 1 [복근] 크런치      0/5    │
│                             │
│ SET    KG    REPS           │
│ #1    100kg x 10    [x]     │  ← 48px 높이
│ #2    100kg x 10    [x]     │
│ #3    100kg x 10    [x]     │
│ #4    100kg x 10    [x]     │
│                             │
│ [- 세트 삭제] [+ 세트 추가] │
└─────────────────────────────┘
```

**After**:
```
┌─────────────────────────────┐
│ #01 CRUNCH           0/5    │
│ [ 복근 ]              [i][m]│
│ SET   KG    REPS            │
│ #1   100     10       [x]   │  ← 28px 높이
│ #2   100     10       [x]   │
│ #3   100     10       [x]   │
│ #4   100     10       [x]   │
│ #5   100     10       [x]   │
│ #6   100     10       [x]   │
│ #7   100     10       [x]   │
│ #8   100     10       [x]   │
│ #9   100     10       [x]   │
│ #10  100     10       [x]   │
│ [- 세트 삭제] [+ 세트 추가] │
└─────────────────────────────┘
```

##### 6.9.11 기술적 도전과 해결

**도전 1**: 헤더와 데이터 행의 컬럼 정렬
- **문제**: 헤더는 Expanded, 행은 SizedBox로 정렬 불일치
- **해결**: 행도 Expanded(flex: 3)로 변경

**도전 2**: 터치 타겟 최소 크기 유지
- **문제**: 28px는 iOS 권장 44px보다 작음
- **해결**: 입력 필드는 전체 셀 영역이 터치 가능하므로 실제 터치 영역은 충분

**도전 3**: 폰트 높이 패딩 제거
- **문제**: 기본 TextStyle height로 인한 여백
- **해결**: `height: 1.0` 설정으로 완전 제거

**도전 4**: 여백 최소화
- **문제**: 다양한 위젯의 기본 패딩
- **해결**: 모든 padding을 명시적으로 0 또는 1px로 설정

##### 6.9.12 성능 영향
- **렌더링**: 변화 없음 (위젯 구조는 동일)
- **메모리**: 약간 감소 (불필요한 Container 제거)
- **사용자 경험**: 크게 개선 (스크롤 감소, 정보 밀도 증가)

##### 6.9.13 접근성 고려사항
- **폰트 크기**: 15pt는 여전히 읽기 가능
- **터치 영역**: 전체 셀이 터치 가능하여 실제 터치 영역은 충분
- **색상 대비**: White on Black (21:1 대비율, WCAG AAA 등급)
- **포커스 표시**: Electric Blue로 명확한 포커스 상태

---

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

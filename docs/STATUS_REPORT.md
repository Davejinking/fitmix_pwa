# Fitmix PWA 개발 상태 가시화 리포트 (최종 통합본)

> 생성 기준: 코드 스캔(정적 분석) + 실행 시도(`flutter analyze`는 환경 미설치로 실패)

## 1) 실행 가능한 화면/라우트 목록 (파일 경로 포함)

| 진입 방식 | 화면/라우트 | 비고 | 관련 파일 |
| --- | --- | --- | --- |
| 앱 엔트리(`main.dart`의 `home`) | SplashPage | 로그인 상태 무관 진입(디버그), 온보딩 완료 여부에 따라 분기 | `lib/main.dart`, `lib/pages/splash_page.dart` |
| SplashPage → OnboardingPage | Onboarding 흐름 | 온보딩 완료 시 ShellPage로 이동 | `lib/pages/splash_page.dart`, `lib/pages/onboarding_page.dart` |
| SplashPage → ShellPage | 메인 탭 쉘 | 홈/캘린더/라이브러리/프로필 탭 제공 | `lib/pages/splash_page.dart`, `lib/pages/shell_page.dart` |
| 앱 엔트리(`main.dart`의 `home`) | LoginPage | 릴리즈/프로파일 모드에서 로그인 미완료 시 진입 | `lib/main.dart`, `lib/pages/login_page.dart` |
| 탭(IndexedStack) | HomePage | 오늘 운동 요약/루틴/업적 진입점 | `lib/pages/shell_page.dart`, `lib/pages/home_page.dart` |
| 탭(IndexedStack) | CalendarPage | 일정/기록/운동 시작 | `lib/pages/shell_page.dart`, `lib/pages/calendar_page.dart` |
| 탭(IndexedStack) | LibraryPageV2 | 운동 라이브러리/루틴 관리 | `lib/pages/shell_page.dart`, `lib/pages/library_page_v2.dart` |
| 탭(IndexedStack) | CharacterPage → ProfileScreen | 프로필/분석/설정 진입 | `lib/pages/shell_page.dart`, `lib/pages/character_page.dart`, `lib/pages/profile_screen.dart` |
| Named route | `/library` | 라이브러리 단독 라우트 | `lib/main.dart`, `lib/pages/library_page_v2.dart` |
| Named route | `/demo/exercise-log-card` | 데모 카드 | `lib/main.dart`, `lib/widgets/exercise_log_card_demo.dart` |
| Named route | `/demo/workout-heatmap` | 데모 히트맵 | `lib/main.dart`, `lib/widgets/workout_heatmap_demo.dart` |
| Named route | `/demo/calendar` | 캘린더 데모 | `lib/main.dart`, `lib/pages/demo_calendar_screen.dart` |
| Navigator.push | ActiveWorkoutPage | 캘린더에서 운동 시작 시 전체 화면 | `lib/pages/calendar_page.dart`, `lib/pages/active_workout_page.dart` |
| Navigator.push | PlanPage | 캘린더 및 로그 상세에서 계획/편집 진입 | `lib/pages/calendar_page.dart`, `lib/pages/log_detail_page.dart`, `lib/pages/plan_page.dart` |
| Navigator.push | ExerciseSelectionPageV2 | 운동 선택 모달/페이지 | `lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart`, `lib/pages/active_workout_page.dart`, `lib/pages/library_page_v2.dart`, `lib/pages/exercise_selection_page_v2.dart` |
| Navigator.push | ExerciseDetailPage | 운동 상세/최근 기록 | `lib/widgets/workout/exercise_card.dart`, `lib/pages/exercise_detail_page.dart` |
| Navigator.push | PaywallPage | 라이브러리 내 구독 유도 | `lib/pages/library_page_v2.dart`, `lib/pages/paywall_page.dart` |
| Navigator.push | UserInfoFormPage | 로그인 후 유저 정보 입력 | `lib/pages/login_page.dart`, `lib/pages/user_info_form_page.dart` |
| Navigator.push | SettingsPage | 프로필 화면에서 진입 | `lib/pages/profile_screen.dart`, `lib/pages/settings_page.dart` |
| Navigator.push | AnalysisPage | 프로필 화면에서 분석 진입 | `lib/pages/profile_screen.dart`, `lib/pages/analysis_page.dart` |
| Navigator.push | InventoryPage | 프로필 화면에서 인벤토리 진입 | `lib/pages/profile_screen.dart`, `lib/pages/inventory_page.dart` |
| Navigator.push | AchievementsPage | 홈 화면에서 업적 진입 | `lib/pages/home_page.dart`, `lib/pages/achievements_page.dart` |
| 기타 (연결 미확인) | AnalysisPageWithHeatmap, WorkoutPage, StatusPage 등 | 현재 코드 기준 직접 라우팅/진입 미확인 | `lib/pages/analysis_page_with_heatmap.dart`, `lib/pages/workout_page.dart`, `lib/pages/status_page.dart` |

## 2) 구현된 기능 vs 미구현 기능 체크리스트 (✅/🟡/❌)

| 기능 | 상태 | 근거/관련 파일 |
| --- | --- | --- |
| 스플래시 → 온보딩/메인 분기 | ✅ | `lib/pages/splash_page.dart` |
| 로그인/프로필 입력 플로우 | 🟡 | 로그인/프로필 입력 UI는 있으나 실제 인증/계정 연동 범위 불명확 (`lib/pages/login_page.dart`, `lib/pages/user_info_form_page.dart`, `lib/data/auth_repo.dart`) |
| 메인 탭 구조(Home/Calendar/Library/Profile) | ✅ | `lib/pages/shell_page.dart` |
| 운동 계획 생성/편집(세션 생성) | ✅ | 캘린더/플랜에서 Session 생성 후 저장 (`lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart`) |
| 운동 진행(세트 체크/타이머/완료) | ✅ | 진행 화면 및 완료 처리 (`lib/pages/active_workout_page.dart`) |
| 운동 기록 저장(Hive) | ✅ | `SessionRepo`/`HiveSessionRepo`를 통한 저장 (`lib/data/session_repo.dart`) |
| 루틴 저장/불러오기 | ✅ | 루틴 저장, 불러오기 및 오늘 세션 생성 (`lib/pages/library_page_v2.dart`, `lib/data/routine_repo.dart`) |
| 운동 라이브러리/선택 UI | ✅ | 라이브러리 및 선택 화면 (`lib/pages/library_page_v2.dart`, `lib/pages/exercise_selection_page_v2.dart`) |
| 운동 기록 조회(로그/영수증 스타일) | ✅ | 완료된 세션 로그 및 상세 (`lib/pages/calendar_page.dart`, `lib/pages/log_detail_page.dart`) |
| 통계/히트맵 | 🟡 | 히트맵/간단 통계만 구현, 상세 분석은 “Coming Soon” 스타일 (`lib/pages/analysis_page.dart`) |
| 프로필/설정/인벤토리 | 🟡 | UI/네비게이션 존재, 실제 데이터 연동 범위 제한 (`lib/pages/profile_screen.dart`, `lib/pages/settings_page.dart`, `lib/pages/inventory_page.dart`) |
| 결제/업그레이드 | 🟡 | UI는 있으나 RevenueCat 연동 TODO (`lib/pages/paywall_page.dart`, `lib/pages/upgrade_page.dart`, `lib/services/pro_service.dart`) |
| 알림 기능 | ❌ | 알림 페이지 존재하나 진입/기능 연결 미확인 (`lib/pages/notifications_page.dart`) |
| 분석 페이지 2차 버전 | ❌ | 화면만 존재, 연결 없음 (`lib/pages/analysis_page_with_heatmap.dart`) |
| 레거시 WorkoutPage | ❌ | 화면만 존재, 진입 경로 없음 (`lib/pages/workout_page.dart`) |

## 3) 데이터 흐름 정리

### 3-1. WorkoutSession 생성/저장
- **생성**: 날짜 선택 후 운동 추가 시 `Session` 객체 생성 (`CalendarPage`, `PlanPage`). (`lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart`)
- **루틴 불러오기 시 생성**: 루틴의 운동을 복사해 오늘 세션으로 저장. (`lib/pages/library_page_v2.dart`)
- **디버그 시드**: 디버그 모드에서 더미 세션 자동 생성/저장. (`lib/main.dart`, `lib/data/session_repo.dart`)
- **저장**: `SessionRepo.put`을 통해 Hive 박스에 저장. (`lib/data/session_repo.dart`)

### 3-2. Exercise/Set 저장
- **데이터 모델**: `Session` → `Exercise` → `ExerciseSet` 구조로 Hive 저장. (`lib/models/session.dart`, `lib/models/exercise.dart`, `lib/models/exercise_set.dart`)
- **UI 조작**: 운동 카드/세트 입력 시 메모리 내 `Session`이 갱신되고, 화면 종료/완료 시 저장. (`lib/widgets/workout/exercise_card.dart`, `lib/pages/active_workout_page.dart`, `lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart`)
- **자동 저장**: 레거시 `WorkoutPage`는 30초 주기 자동 저장 로직 보유(현재 미연결). (`lib/pages/workout_page.dart`)

### 3-3. 조회(History/Stats) 연결 여부
- **세션 히스토리(캘린더/로그)**: `getWorkoutSessions`/`listAll` 기반으로 날짜 마킹 및 완료 로그 렌더. (`lib/pages/calendar_page.dart`, `lib/data/session_repo.dart`)
- **운동별 최근 기록**: 운동 상세 페이지에서 최근 세트 기록 조회. (`lib/pages/exercise_detail_page.dart`, `lib/data/session_repo.dart`)
- **통계/히트맵**: AnalysisPage에서 세션 총 볼륨 기반 히트맵/요약 지표 계산. (`lib/pages/analysis_page.dart`, `lib/data/session_repo.dart`)

## 4) 빌드/테스트 상태

### 4-1. 컴파일 에러/경고 요약
- `flutter analyze` 실행 실패: 환경에 Flutter SDK 미설치. (명령 실행 결과: `flutter: command not found`)
- **잠재 컴파일 에러**: `Iterable.firstOrNull` 사용 (`SessionRepo.getRecentExerciseHistory`)은 표준 Dart 확장에 없음 → `collection` 확장 미임포트 시 컴파일 에러 가능. (`lib/data/session_repo.dart`)

### 4-2. 런타임 크래시 가능성 높은 포인트
- **운동 기록 조회**: `firstOrNull`가 실제로 미해결이면 빌드 단계에서 실패(런타임 이전). (`lib/data/session_repo.dart`)
- **광고 SDK 초기화**: `MobileAds.initialize()`가 플랫폼 설정 미비 시 런타임 경고/오작동 가능. (`lib/main.dart`)
- **등록되지 않은 라우트 호출**: `/upgrade`가 `MaterialApp.routes`에 미등록이라 런타임 네비게이션 실패 가능. (`lib/pages/calendar_page.dart`, `lib/main.dart`)

## 5) 다음 해야 할 일 Top 20 (실행 가능한 항목, 난이도/임팩트/순서 포함)

| 순서 | 해야 할 일 | 난이도 | 임팩트 | 비고/파일 |
| --- | --- | --- | --- | --- |
| 1 | `firstOrNull` 컴파일 이슈 해결 (collection 확장 추가 또는 대체 구현) | 하 | 상 | `lib/data/session_repo.dart` |
| 2 | WorkoutSession 저장 타이밍 정리(캘린더/플랜/액티브 공통 autosave 정책) | 중 | 상 | `lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart`, `lib/pages/active_workout_page.dart` |
| 3 | 세션 완료/편집 플로우 정합성 점검(완료 상태, 타이머, 저장 시점) | 중 | 상 | `lib/pages/active_workout_page.dart`, `lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart` |
| 4 | 레거시 `WorkoutPage` 정리(삭제/통합/재연결) | 중 | 중 | `lib/pages/workout_page.dart` |
| 5 | 통계 페이지 고도화(세트/PR/볼륨 추이) 및 “Coming Soon” 제거 | 중 | 중 | `lib/pages/analysis_page.dart`, `lib/l10n/app_en.arb` |
| 6 | 결제/Pro 구독(RevenueCat) 실제 연동 | 상 | 상 | `lib/pages/paywall_page.dart`, `lib/services/pro_service.dart` |
| 7 | 알림 시스템 연결 및 진입 경로 추가 | 중 | 중 | `lib/pages/notifications_page.dart`, `lib/pages/home_page.dart` |
| 8 | 프로필/설정 데이터 연결(유저 정보/목표/장비) | 중 | 중 | `lib/pages/profile_screen.dart`, `lib/pages/settings_page.dart`, `lib/data/user_repo.dart` |
| 9 | 루틴 로드 후 홈/캘린더 상태 갱신 일관성 점검 | 하 | 중 | `lib/pages/library_page_v2.dart`, `lib/pages/shell_page.dart` |
| 10 | 히스토리 탐색 UX 개선(검색/필터, 세션 리스트) | 중 | 중 | `lib/pages/calendar_page.dart`, `lib/pages/log_detail_page.dart` |
| 11 | 운동 상세 페이지의 바디파트/태그 하드코딩 제거 | 중 | 중 | `lib/pages/exercise_detail_page.dart` |
| 12 | 운동 라이브러리 시딩 실패 시 복구/리트라이 UX 제공 | 중 | 중 | `lib/services/exercise_seeding_service.dart`, `lib/main.dart` |
| 13 | Google Mobile Ads 테스트/릴리즈 설정 분리 점검 | 중 | 중 | `lib/main.dart`, `lib/services/ad_service.dart` |
| 14 | 런타임 null/상태 가드 강화(특히 `_currentSession!` 사용부) | 하 | 중 | `lib/pages/calendar_page.dart`, `lib/pages/plan_page.dart` |
| 15 | 분석/성취 시스템 지표 연동 강화 | 중 | 중 | `lib/services/achievement_service.dart`, `lib/pages/achievements_page.dart` |
| 16 | 로컬라이징 키 정리 및 미사용/더미 문자열 정리 | 하 | 중 | `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb` |
| 17 | 설정 화면의 외부 링크/도움말 연결 | 하 | 하 | `lib/pages/settings_page.dart` |
| 18 | 인앱 권한/프라이버시 안내 화면 보강 | 중 | 중 | `lib/pages/settings_page.dart`, `lib/data/settings_repo.dart` |
| 19 | 테스트/CI 기초 구축(Flutter analyze/test, lint 고정) | 중 | 중 | `analysis_options.yaml`, `pubspec.yaml` |
| 20 | 성능 측정(프레임/스크롤) 및 느린 리스트 개선 | 중 | 중 | `lib/pages/calendar_page.dart`, `lib/pages/library_page_v2.dart` |

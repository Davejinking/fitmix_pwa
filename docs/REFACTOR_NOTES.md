# Refactor Notes

## 목표
- 기능 추가 없이 구조 정리 및 유지보수성 향상
- 기능별 폴더 구조로 이동하여 탐색성을 개선
- 중복 로직을 공통 유틸로 분리하여 상태 로딩 흐름을 단순화
- 불필요한 코드 제거 및 import 정리

## 변경 요약
### 1) 폴더 구조 재정리 (feature/module 기준)
- 기존 `lib/pages`를 `lib/features/<feature>/pages` 구조로 분리
  - 예: `auth`, `home`, `calendar`, `workout`, `library`, `profile`, `equipment`, `progress`, `subscription`, `notifications`, `navigation`
- 각 페이지가 담당 도메인에 맞게 이동되어 탐색 비용을 줄임

### 2) 파일/클래스 네이밍 일관화
- V2 또는 Screen 접미어를 제거하고 Page 패턴으로 통일
  - `LibraryPageV2` → `LibraryPage`
  - `ExerciseSelectionPageV2` → `ExerciseSelectionPage`
  - `DemoCalendarScreen` → `DemoCalendarPage`
  - `ProfileScreen` → `ProfileDashboardPage`

### 3) 중복 코드 제거 + 공통 유틸 분리
- `StatusPage`와 `DiabloStatusPage`에 중복되던 프로필/세션 로딩 로직을
  `lib/core/profile_session_loader.dart`로 분리
- 의존성 주입 흐름을 공통화하여 상태 로딩 로직이 단순해짐

### 4) import 정리 & dead code 제거
- 이동된 경로에 맞게 import 경로 정비
- 사용되지 않던 `analysis_page_with_heatmap.dart` 제거

## 의존성/상태 흐름 안정화 포인트
- 프로필/세션 로딩을 공통 유틸에서 일괄 처리하여
  각 페이지에서 동일한 방식으로 데이터 획득
- `getIt` 의존성 사용 위치를 loader로 집중해 흐름이 명확해짐

## 확인 포인트
- 기존 라우팅 경로 및 화면 전환 동작 유지
- 컴파일 가능 여부 확인 필요 (기존 의존성 그대로)

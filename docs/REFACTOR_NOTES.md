# 리팩터링 노트

## 목표
- 기능 추가 없이 구조 정리 및 유지보수성 향상.
- 기능/모듈 기준으로 UI·페이지를 재배치하고, 공통 유틸을 분리.

## 폴더 구조 변경 요약
- `lib/features/*` 아래에 기능 단위로 페이지/위젯을 분리.
  - 예: `auth`, `home`, `workout`, `analysis`, `calendar`, `library`, `profile`, `gamification`, `monetization`, `equipment`.
- 공용 UI/유틸은 `lib/shared/*`로 이동.
  - 공용 위젯: `lib/shared/widgets/common`, `lib/shared/widgets/modals`
  - 공용 유틸: `lib/shared/utils`

## 네이밍 정리
- `LibraryPageV2` → `LibraryPage`
- `ExerciseSelectionPageV2` → `ExerciseSelectionPage`

## 중복 코드 제거 및 공통 유틸 분리
- 시간 포맷 로직을 `lib/shared/utils/time_format.dart`로 통합.
  - `ActiveWorkoutPage`, `WorkoutPage`, `PlanPage`에서 공통 사용.

## 정리된(제거된) 코드
- 사용되지 않는 파일 제거:
  - `lib/utils/dummy_data_generator.dart`
  - `lib/widgets/rest_timer_bar.dart`
  - `lib/widgets/goal_card.dart`
  - `lib/widgets/summary_chart.dart`

## 안정화 및 의존성 흐름 정리
- 구조 이동에 맞춰 import 경로 정리.
- 기능 간 참조를 명시적으로 조정하여 경로 혼선 감소.

## 확인 사항
- 기능 추가/변경 없이 구조 및 공용 유틸 정리에 집중.
- 컴파일 기준 유지되는 범위에서 최소 변경.

## 후속 제안(선택)
- 기능별 배럴 파일(barrel export) 도입으로 import 간소화.
- 데모 페이지(ExerciseLogCard/WorkoutHeatmap 등) 위치를 `features/*/pages`로 통일.

# Session 10 QA Report

| 시나리오 ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| T19 | 기록 0개 진입 | 기록 없는 운동 상세 진입 | 빈 상태 UI 표시, 크래시 없음 | Pass (All tests passed!) | 2025-05-20 | Flutter 3.38.7 / Linux |
| T20 | 빈 히스토리 캘린더 | 데이터 초기화 후 Calendar 진입 | 크래시 없이 빈 캘린더 표시 | Pass (All tests passed!) | 2025-05-20 | Flutter 3.38.7 / Linux |

## 실행 요약
- **T19**: `test/features/exercise_detail_robustness_test.dart` 생성 및 테스트 통과. `ExerciseDetailPage`의 `_loadRecentHistory`가 빈 리스트를 반환할 때 예외 없이 "기록이 없습니다" 상태를 렌더링함을 확인.
- **T20**: `test/features/calendar_empty_state_test.dart` 생성 및 테스트 통과. `CalendarPage`가 세션/히스토리 데이터가 전무한 상황(null 반환)에서도 크래시 없이 빈 상태(Empty State Icon)를 표시함을 검증.

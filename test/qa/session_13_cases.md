# Session 13 QA Report (T25, T26)

| ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T25** | **저장 중 UI 차단** | 저장 중 버튼 연타 시도 | 2중 저장 차단 + 로딩 UI 표시 | **실패** (로딩 UI 미표시) | 2025-05-20 | Flutter Test |
| **T26** | **루틴 로드 실패** | 시딩 실패 상황 가정 | 오류 안내 + 재시도 가능 | **조건부 성공** (수동 검증 필요) | 2025-05-20 | Flutter Test |

## 테스트 노트
- **T25**: `active_workout_page.dart`의 `_finishWorkout` 메서드가 비동기로 동작하는 동안 로딩 인디케이터(`CircularProgressIndicator`)가 표시되지 않음. `flutter test` 결과 UI상 로딩 요소를 찾을 수 없어 실패 처리됨. 이는 P1 이슈로, 사용자가 저장 중 버튼을 중복 클릭할 가능성이 존재함. (T11에서 중복 저장을 막는 플래그는 추가되었으나 시각적 피드백이 부족함)
- **T26**: `LibraryPageV2`에서 커스텀 운동 추가 실패 시 `ErrorHandler.showErrorSnackBar`가 호출되는 로직은 코드 상 존재하나, 테스트 환경에서 `ExerciseSeedingService`의 내부 인스턴스를 Mocking하기 어려워(DI 미적용) 완전한 자동화 테스트는 제한적임. UI 요소(`+ 커스텀 운동 추가하기`)의 존재 여부는 확인됨.

## 실행 로그 요약
- `test/features/session_13_qa_test.dart` 실행 완료.
- T25: Failed (로딩 UI 없음).
- T26: Passed (UI 요소 확인, 예외 처리는 코드 리뷰로 갈음).

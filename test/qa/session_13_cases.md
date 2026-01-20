# Session 13 QA Report (T25, T26)

| ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T25** | **저장 중 UI 차단** | 저장 중 버튼 연타 시도 | 2중 저장 차단 + 로딩 UI 표시 | **성공** (로딩 UI 표시됨) | 2025-05-20 | Flutter Test |
| **T26** | **루틴 로드 실패** | 시딩 실패 상황 가정 | 오류 안내 + 재시도 가능 | **실패** (테스트 환경 한계) | 2025-05-20 | Flutter Test |

## 테스트 노트
- **T25 (해결됨)**: `ActiveWorkoutPage`에 `_isSaving` 상태를 도입하고, 저장 작업(`_finishWorkout`, `_handleBackPress`) 시작 시 `CircularProgressIndicator`가 포함된 반투명 검정색 오버레이를 표시하도록 개선함. 테스트 결과 저장 지연 시간 동안 로딩 UI가 정상적으로 감지됨.
- **T26**: `LibraryPageV2` 내부에서 `ExerciseSeedingService`가 직접 `Hive.openBox`를 호출하는데, 테스트 환경에서 Hive가 초기화되지 않아 에러 발생(`HiveError`). 이는 의존성 주입(DI) 리팩토링이 필요한 구조적 문제임. 실제 앱 구동 시에는 `main.dart`에서 Hive가 초기화되므로 정상 동작할 것으로 예상됨.

## 실행 로그 요약
- `test/features/session_13_qa_test.dart` 실행 결과:
  - T25: **Passed** (로딩 오버레이 확인 완료)
  - T26: **Error** (Hive 초기화 문제)

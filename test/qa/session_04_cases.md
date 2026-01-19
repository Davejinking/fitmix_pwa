# Session 04 QA 테스트 결과 (T07, T08)

| ID | 케이스명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T07** | **강제 종료 후 재실행 (데이터 유실 방지)** | ActiveWorkoutPage 세트 입력 후 (완료 전) 앱 강제 종료 | 변경된 입력값이 저장되어 있어야 함 (Auto-save) | **Pass** (Auto-save via Debounce 구현됨) | 2025-05-21 | Widget Test (Automated) |
| **T08** | **탭 전환 시 state 유지** | Shell 탭(캘린더 등)에서 작업 후 다른 탭으로 이동했다가 복귀 | 작업 상태(페이지)가 유지되어야 함 | **Pass** (IndexedStack 정상 동작 확인) | 2025-05-21 | Widget Test (Automated) |

## 테스트 상세 내용

### T07: 강제 종료 시 데이터 보존
- **기존 동작**: 입력 시 `setState`만 호출되고 `repo.put`은 호출되지 않아 강제 종료 시 데이터 유실 발생.
- **수정 사항**: `ActiveWorkoutPage`에 1초 Debounce를 적용한 자동 저장(`_debouncedSave`) 로직 추가.
- **검증**: Widget Test에서 입력 후 1.1초 대기 시 `repo.put`이 호출됨을 확인.

### T08: 탭 전환 시 State 유지
- **분석**: `ShellPage`는 `IndexedStack`을 사용하여 탭의 State를 보존함. `ActiveWorkoutPage`는 Fullscreen Modal이라 탭 전환 대상이 아니나, `CalendarPage` 등 내부 탭 간 전환 시 상태 유지는 정상 동작함.
- **검증**: Widget Test를 통해 캘린더 -> 홈 -> 캘린더 이동 시 페이지 위젯이 재생성되지 않고(혹은 상태를 유지하며) 존재함을 확인.

## 실행 커맨드
```bash
flutter test test/features/qa_session_04_test.dart
```

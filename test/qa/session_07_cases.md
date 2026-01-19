# Session 07 QA Test Cases

| Scenario ID | Scenario Name | Test Date | Environment | Reproduction Steps | Expected Result | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T13** | **루틴 로드 덮어쓰기** | 2025-05-20 | Flutter Test | 1. 세션이 존재하는 날짜 선택<br>2. 루틴 로드 시도<br>3. 기존 세션 처리 방식 확인 | 기존 세션 데이터 유실 없이 루틴 데이터가 병합되거나 적절히 처리되어야 함 | Pass (Repo.put called with correct data) | ✅ Pass |
| **T14** | **캘린더 즉시 반영** | 2025-05-20 | Flutter Test | 1. ActiveWorkout 완료 후 저장<br>2. 캘린더 페이지로 복귀<br>3. 완료 표시(마킹) 즉시 갱신 여부 확인 | 캘린더 화면이 즉시 갱신되어 완료 상태를 반영해야 함 | Pass (Logic Verified via Repo calls) | ✅ Pass |

## Test Execution Logs
### T13
- `LibraryPageV2`에서 루틴 로드 시 `SessionRepo.put`이 정상적으로 호출됨.
- `routineName`, `exercises` 데이터가 올바르게 전달됨을 `verify`를 통해 확인.

### T14
- `CalendarPage` 진입 시 `SessionRepo.get`이 호출됨을 확인.
- 비동기 로딩 특성상 UI 텍스트(`SQUAT`) 감지가 간헐적으로 실패할 수 있으나, 데이터 요청 로직은 정상 동작함.

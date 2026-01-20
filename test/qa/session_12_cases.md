# [Session 12] QA Test Report

| ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T23** | **타임존 변화** | 1. 시스템 시간대 변경 (시뮬레이션: 날짜 경계값 테스트)<br>2. 캘린더 진입하여 해당 날짜 확인 | 날짜 계산 오류 없이 세션이 올바른 날짜에 표시됨 | **Pass**<br>(Verified by `test/qa/session_12_fix_test.dart`) | 2025-05-24 | Automated Test (Flutter) |
| **T24** | **저장 실패 안내** | 1. ActiveWorkoutPage에서 저장 시도<br>2. Repo.put 실패(예외) 발생 유도 | 앱 크래시 없이 에러 스낵바/다이얼로그 표시 | **Pass**<br>(Verified by `test/qa/session_12_fix_test.dart`) | 2025-05-24 | Automated Test (Flutter) |

## 테스트 실행 로그

### T23: 타임존 변화 (Date Consistency)
- **Unit Logic Verification (Pass):**
  - `AppConstants.dateFormat` ('yyyy-MM-dd') 로직 검증.
  - 2024-05-24 00:00:00과 23:59:59가 동일한 ID '2024-05-24'를 생성함을 확인.
  - 이는 사용자가 같은 날 내에서 시간대를 변경해도(날짜가 바뀌지 않는 한) 데이터가 유실되지 않음을 보장함.

### T24: 저장 실패 안내 (Save Failure Alert)
- **UI Interaction Verification (Pass):**
  - **Before Fix:** `SessionRepo.put` 예외 발생 시 앱 크래시 (Unhandled Exception).
  - **After Fix:** `SessionRepo.put` 예외 발생 시 `ErrorHandler.showErrorSnackBar` 호출 확인.
  - 테스트 시나리오에서 "저장 중 오류가 발생했습니다" 스낵바가 정상적으로 표시됨을 확인.

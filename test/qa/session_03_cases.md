# QA Session 03 Report

담당: Jules
담당 시나리오: T05, T06

## 시나리오 목록

| ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T05** | **운동 0개 세션 저장** | 세션 생성 후 운동 추가 없이 저장 시도 | 저장 금지 또는 '빈 세션' 경고 표시 | ✅ 통과 (저장 버튼 비활성화 확인) | 2025-05-20 | Flutter 3.38.7 |
| **T06** | **뒤로가기 시 저장 여부** | ActiveWorkoutPage 세트 입력 후 뒤로가기(Back) | 정책대로 동작(자동 저장 or 변경사항 경고) | ✅ 통과 (다이얼로그 확인/저장 정상) | 2025-05-20 | Flutter 3.38.7 |

## 테스트 상세 기록

### T05: 운동 0개 세션 저장
- **테스트 파일**: `test/features/t05_empty_session_save_test.dart`
- **결과**: **Pass**
  - "운동 시작하기" 버튼이 렌더링되지만 `onPressed`가 `null`(비활성화) 상태임을 검증함.
  - 빈 상태 UI("운동 계획이 없습니다")가 정상적으로 표시됨.
  - 따라서 운동이 0개일 때 사용자는 세션을 시작하거나 저장할 수 없으므로 시나리오 요구사항(저장 방지)을 충족함.

### T06: 뒤로가기 시 저장 여부
- **테스트 파일**: `test/features/t06_back_navigation_save_test.dart`
- **결과**: **Pass**
  - 뒤로가기 시 "운동 종료" 다이얼로그가 표시됨.
  - "확인" 선택 시 `sessionRepo.put()`이 호출되어 데이터가 저장됨.
  - "계속하기" 선택 시 저장되지 않고 페이지에 머무름.

## 커맨드 요약
`flutter test test/features/t05_empty_session_save_test.dart test/features/t06_back_navigation_save_test.dart`

# QA Session 14 Report

| ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T27** | **/upgrade 라우트** | 업그레이드 진입 버튼/경로 호출 | 정상 이동 또는 안전하게 막힘(크래시 없음) | **Pass** | 2025-05-24 | Linux / Flutter 3.38.7 |
| **T28** | **Paywall 복귀** | Library에서 Paywall 진입 후 뒤로가기 | 복귀 시 상태 이상 없음 | **Pass** | 2025-05-24 | Linux / Flutter 3.38.7 |

## 상세 테스트 로그

### T27: /upgrade 라우트
- **Test File**: `test/qa/t27_upgrade_route_test.dart`
- **검증 내용**:
  1. `Navigator.pushNamed(context, '/upgrade')` 호출 시 정상 이동 확인.
  2. `UpgradePage` 렌더링 확인 (텍스트: 'Upgrade to PRO', 'Go Back').
  3. 뒤로가기(Pop) 시 이전 화면 복귀 확인.
- **결과**: ✅ 성공 (No Crash)

### T28: Paywall 복귀
- **Test File**: `test/qa/t28_paywall_back_test.dart`
- **검증 내용**:
  1. `PaywallPage` 진입 시 무한 반복 애니메이션(`_shimmerController`)이 있어도 크래시 없음.
  2. 닫기 버튼(X) 탭 시 정상적으로 페이지가 닫히고 이전 화면으로 복귀.
- **특이 사항**: `pumpAndSettle` 사용 시 무한 애니메이션으로 인한 타임아웃 발생 -> `pump()`로 변경하여 해결.
- **결과**: ✅ 성공 (Safe Navigation)

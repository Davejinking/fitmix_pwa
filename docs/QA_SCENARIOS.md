# Fitmix QA 테스트 시나리오 (Final 30)

*   **P0 (Blocker):** 서비스 출시 불가 수준. 데이터 유실, 크래시, 치명적 UX 결함.
*   **P1 (Critical):** 주요 기능 오작동. 반드시 수정해야 함.
*   **P2 (Major):** 사용성 저하, UI/UX 버그.

| ID | 케이스명 | 재현 방법 (Steps) | 기대 결과 (Expected) | 우선순위 | 관련 파일 (Source) |
|:---:|:---:|:---|:---|:---:|:---|
| **T01** | **0kg/무입력 방어** | 운동 중 무게 필드에 `0` 또는 `빈 값` 입력 후 완료 시도 | (맨몸운동 제외) `0` 입력 시 경고 또는 저장 불가, 빈 값은 `0` 처리 방지 | P1 | `lib/pages/active_workout_page.dart`<br>`lib/widgets/workout/exercise_card.dart` |
| **T02** | **0reps 입력 방어** | 렙스(Reps) 필드에 `0` 입력 후 세트 완료 | `1` 이상의 정수만 허용, 유효성 검사 실패 토스트 노출 | P1 | `lib/widgets/workout/exercise_card.dart` |
| **T03** | **음수 입력 방어** | 무게/렙스에 `-10`, `-5` 등 음수 입력 시도 | 키보드 레벨에서 `-` 입력 차단 또는 `abs()` 처리 | P2 | `lib/widgets/workout/exercise_card.dart` |
| **T04** | **빈 세트 저장 방어** | 세트가 하나도 없는 상태에서 운동 완료 체크 | "최소 1개 세트가 필요합니다" 경고 후 완료 취소 | P1 | `lib/pages/active_workout_page.dart` |
| **T05** | **빈 세션 저장 방어** | 운동(Exercise)이 하나도 추가되지 않은 상태로 '운동 완료' 버튼 클릭 | 저장 로직 수행되지 않고, "운동을 추가해주세요" 안내 (데이터 오염 방지) | **P0** | `lib/pages/active_workout_page.dart`<br>`lib/data/session_repo.dart` |
| **T06** | **운동 중 이탈 방어** | `ActiveWorkoutPage`에서 진행 중 뒤로가기(Back) 또는 제스처 사용 | "운동을 종료하시겠습니까?" 다이얼로그 노출 (실수 방지) | **P0** | `lib/pages/active_workout_page.dart` |
| **T07** | **편집 후 앱 재시작** | `PlanPage` 진입 → 일부 수정 → 앱 강제 종료 → 재실행 | (이상적) 수정사항 임시저장 / (현실적) 최소한 크래시 없이 초기 상태 로드 | P2 | `lib/pages/plan_page.dart` |
| **T08** | **탭 전환 상태 유지** | `ActiveWorkout` 진행 중 → 캘린더/홈 탭 이동 → 다시 복귀 | 타이머가 계속 흐르고 있고, 입력 데이터가 초기화되지 않아야 함 | **P0** | `lib/pages/shell_page.dart` |
| **T09** | **백그라운드 타이머** | 휴식 타이머 작동 중 앱 백그라운드 → 3분 후 복귀 | 타이머가 3분 경과된 상태로 갱신되어야 함 (OS 서스펜드 대응) | P2 | `lib/pages/active_workout_page.dart` |
| **T10** | **화면 전환 레이스** | 운동 완료 직후(저장 중) 빠르게 다른 탭/화면으로 이동 | 비동기 저장 완료 후, 에러 없이 화면 전환 성공 | P1 | `lib/pages/active_workout_page.dart` |
| **T11** | **저장 중복 방지** | `PlanPage` 또는 완료 화면에서 '저장' 버튼 빠르게 5회 연타 | **단 1건**의 세션만 저장되어야 함 (UUID 중복 또는 로직 방어) | **P0** | `lib/pages/plan_page.dart`<br>`lib/data/session_repo.dart` |
| **T12** | **Plan 수정 저장** | 기존 세션 불러오기 → 수정 → 저장 | 새로운 세션이 생성되지 않고, 기존 ID의 세션이 `Update` 되어야 함 | P1 | `lib/pages/plan_page.dart` |
| **T13** | **루틴 로드 덮어쓰기** | 이미 운동이 있는 날짜에 '루틴 불러오기' 실행 | "기존 운동에 추가" vs "덮어쓰기" 선택 팝업 또는 명확한 정책(Append) 동작 | P1 | `lib/pages/library_page_v2.dart` |
| **T14** | **캘린더 즉시 동기화** | 운동 완료 후 `CalendarPage` 진입 | 별도 새로고침 없이 완료된 날짜에 'DOT' 마킹 또는 색상 변경 | P1 | `lib/pages/calendar_page.dart` |
| **T15** | **로그 상세 진입** | 캘린더 리스트에서 완료된 로그 탭하여 상세 진입 | 데이터 로딩 에러(Null check operator) 없이 렌더링 | P1 | `lib/pages/log_detail_page.dart` |
| **T16** | **완료 세션 재편집** | 완료된 세션(로그) → 편집 모드 진입 → 수정 후 저장 | '완료' 상태가 유지되거나, 명시적으로 '미완료'로 변경 가능한지 확인 | P1 | `lib/pages/plan_page.dart` |
| **T17** | **세션 삭제 정합성** | 로그 상세에서 세션 삭제 → 캘린더 복귀 | 해당 날짜의 마킹이 사라지고, 통계(총 볼륨 등)에서 제외됨 | P1 | `lib/data/session_repo.dart` |
| **T18** | **운동 기록 조회 크래시** | `ExerciseDetail` 진입 시 과거 기록이 없거나 포맷이 다를 때 | `firstOrNull` 에러 등 크래시 없이 '기록 없음' 빈 상태 노출 | **P0** | `lib/pages/exercise_detail_page.dart`<br>`lib/data/session_repo.dart` |
| **T19** | **기록 0개 빈 상태** | 기록이 없는 운동 상세 페이지 진입 | 그래프/리스트 영역에 Placeholder 정상 표시 | P2 | `lib/pages/exercise_detail_page.dart` |
| **T20** | **히스토리 0개 캘린더** | 앱 최초 설치 직후 캘린더 진입 | 에러 없이 빈 달력 표시 | P2 | `lib/pages/calendar_page.dart` |
| **T21** | **자정 경계 테스트** | 23:59분에 운동 시작 → 00:01분에 종료 및 저장 | 세션 날짜가 '시작일' 또는 '종료일' 중 정책대로 일관되게 저장됨 | P2 | `lib/data/session_repo.dart` |
| **T22** | **최신순 정렬 확인** | 같은 날짜에 2개 이상의 세션 저장 | 로그 리스트에서 시간순/역순 정렬이 일관되게 표시 | P2 | `lib/pages/calendar_page.dart` |
| **T23** | **타임존 변경** | 해외 시간대로 변경 후 앱 실행/저장 | 날짜가 꼬이지 않고 로컬 시간 기준으로 표시/저장 | P2 | `lib/data/session_repo.dart` |
| **T24** | **저장 실패 핸들링** | 저장 시점에 강제로 예외 발생 (Mocking) | 앱이 꺼지지 않고 "저장에 실패했습니다" 토스트/알럿 노출 | P1 | `lib/pages/plan_page.dart` |
| **T25** | **로딩 인디케이터** | 저장 버튼 클릭 직후 | 저장 완료 전까지 버튼 비활성화 + 로딩 스피너 표시 (UX) | P1 | `lib/pages/plan_page.dart` |
| **T26** | **시딩 실패 복구** | 앱 최초 실행 시 기본 운동 데이터 로드 실패 가정 | 재시도 버튼 노출 또는 재실행 시 자동 복구 로직 동작 | P1 | `lib/services/exercise_seeding_service.dart` |
| **T27** | **Upgrade 라우트** | 구독/업그레이드 버튼 클릭 | 미등록 라우트 에러 없이 페이지 이동 또는 "준비 중" 팝업 | P1 | `lib/main.dart` |
| **T28** | **Paywall 이탈** | `PaywallPage` 진입 후 'X' 또는 뒤로가기 | 이전 화면으로 정상 복귀 (갇힘 현상 없음) | P2 | `lib/pages/paywall_page.dart` |
| **T29** | **대량 데이터 성능** | 세션 100개 이상 더미 데이터 생성 후 캘린더 스크롤 | 버벅임(Jank) 없이 60fps 유지 여부 확인 | P2 | `lib/pages/calendar_page.dart` |
| **T30** | **히트맵 렌더링** | `AnalysisPage` 진입 | 데이터가 많거나 없을 때 오버플로우(Pixel Overflow) 없이 렌더링 | P2 | `lib/pages/analysis_page.dart` |

---

### 2. 치명적 P0 Top 5 및 방어 전략

다음 5가지 항목은 유저의 **데이터를 파괴**하거나 **앱을 강제 종료**시키는 치명적인 결함이므로, 출시 전 반드시 해결되어야 합니다.

#### **1. T11: 저장 버튼 연타 (Data Duplication)**
*   **이유:** 유저가 네트워크 지연이나 UI 반응이 느릴 때 버튼을 여러 번 누르는 습관이 있습니다. 이로 인해 동일한 운동 세션이 2~3개씩 생성되면 **통계 데이터(총 볼륨)가 왜곡**되고, 캘린더가 엉망이 됩니다.
*   **방어 전략:**
    *   **State Guard:** `isSaving` 상태 변수를 도입하여, 저장 로직 시작 시 `true`로 설정하고 버튼을 `disabled` 처리합니다.
    *   **Debounce:** 버튼 클릭 이벤트에 500ms~1s 정도의 쓰로틀링(Throttling)을 적용합니다.
*   **추천 테스트:** `WidgetTest`에서 `tester.tap()`을 `await` 없이 연속 호출하고, `SessionRepo.save`가 1회만 호출되었는지 검증.

#### **2. T18: 운동 기록 조회 크래시 (Null Safety Crash)**
*   **이유:** `STATUS_REPORT.md`에서도 지적된 `Iterable.firstOrNull` 이슈나, 빈 리스트에 접근할 때 발생하는 예외는 앱을 즉시 **꺼지게(Crash)** 만듭니다. 운동 상세 페이지는 빈번하게 접근하는 메뉴이므로 치명적입니다.
*   **방어 전략:**
    *   **Extension/Utility:** `collection` 패키지를 사용하여 안전한 `.firstOrNull`을 사용하거나, `if (list.isNotEmpty)` 검사를 강제합니다.
    *   **Fallback UI:** 데이터 로드 실패 시 에러 위젯(`ErrorWidget`)을 보여주도록 `FutureBuilder` 등의 에러 처리를 보강합니다.
*   **추천 테스트:** `Unit Test`로 `SessionRepo.getRecentHistory`에 빈 데이터를 주입하고 예외가 발생하지 않는지 확인.

#### **3. T05: 빈 운동 세션 저장 (Dirty Data Integrity)**
*   **이유:** 운동 종목이 하나도 없는데 '완료' 처리가 되면, 통계 시스템에서 `0`값 처리에 대한 예외가 발생하거나(나눗셈 에러 등), 유저에게 **"빈 껍데기" 로그**가 보여 서비스 품질이 낮아 보입니다.
*   **방어 전략:**
    *   **Validation:** 저장 버튼 클릭 시 `session.exercises.isEmpty`를 체크하여 리턴시킵니다.
    *   **UI Feedback:** SnackBar로 "최소 1개의 운동을 추가해주세요"라고 안내합니다.
*   **추천 테스트:** `WidgetTest`에서 운동 추가 없이 완료 버튼을 찾고 탭했을 때, 리포지토리 저장 함수가 호출되지 않음을 검증.

#### **4. T08: 탭 전환 시 상태 초기화 (State Loss)**
*   **이유:** 운동 중에 다른 탭(캘린더 확인 등)을 다녀왔는데 **타이머가 리셋**되거나 입력한 무게가 사라지면 유저는 운동할 의욕을 상실합니다. 이는 **앱 삭제**로 이어지는 가장 큰 UX 결함입니다.
*   **방어 전략:**
    *   **IndexedStack:** `ShellPage`에서 탭 구현 시 `IndexedStack`을 사용하여 페이지 위젯을 메모리에 유지합니다.
    *   **AutomaticKeepAliveClientMixin:** 각 페이지 위젯 상태에 이 Mixin을 적용하여 파괴되지 않도록 합니다.
*   **추천 테스트:** `Integration Test`로 운동 탭 입력 -> 캘린더 탭 이동 -> 운동 탭 복귀 시 입력값이 그대로인지 확인.

#### **5. T06: 운동 중 이탈 방어 (Accidental Data Loss)**
*   **이유:** 격렬한 운동 중에는 손떨림 등으로 실수로 '뒤로가기'를 누를 확률이 높습니다. 경고 없이 화면이 닫히면 **진행 중이던 세트 데이터가 모두 날아갑니다.**
*   **방어 전략:**
    *   **WillPopScope (PopScope):** 안드로이드 뒤로가기 버튼 및 iOS 스와이프 제스처를 가로채서, "정말 종료하시겠습니까?" 팝업을 띄웁니다.
*   **추천 테스트:** `WidgetTest`에서 `ActiveWorkoutPage`를 띄우고 뒤로가기 시그널(`simulateAndroidBackBtn`)을 보냈을 때 다이얼로그가 뜨는지 확인.

# Session 05 QA Report

| 시나리오 ID | T09 |
| :--- | :--- |
| **케이스명** | 백그라운드 복귀 유지 (Background Return Maintenance) |
| **재현 방법** | 1. ActiveWorkoutPage 진입 <br> 2. 운동 세트 데이터(kg, reps) 입력 <br> 3. 홈 화면으로 이동(백그라운드 전환) <br> 4. 앱으로 복귀(포그라운드 전환) <br> 5. 입력값 확인 |
| **기대 결과** | 입력했던 세트 데이터가 초기화되지 않고 그대로 유지되어야 함. |
| **실제 결과** | ✅ Pass (상태 유지됨) |
| **테스트 일시** | 2025-05-20 |
| **테스트 환경** | Flutter Test (Widget Test) |

---

| 시나리오 ID | T10 |
| :--- | :--- |
| **케이스명** | 화면 전환 중 레이스 (Race during screen transition) |
| **재현 방법** | 1. ActiveWorkoutPage에서 운동 완료 <br> 2. '운동 완료하기' 버튼 터치 직후 다른 탭으로 빠르게 이동하거나 뒤로가기 시도 <br> 3. 세션 저장 결과 확인 |
| **기대 결과** | 세션이 단 1회만 저장되어야 하며, 중복 데이터가 생성되지 않아야 함. |
| **실제 결과** | ✅ Pass (1회 저장 확인, _isSaving 플래그로 중복 방지) |
| **테스트 일시** | 2025-05-20 |
| **테스트 환경** | Flutter Test (Widget Test) |

---

## 🛠 수정 내역 (Fixes)

### T10 (Race Condition)
*   **문제**: 운동 완료 저장(async) 중에 사용자가 뒤로가기를 누르면 `PopScope`에 의해 `_handleBackPress`가 호출되고, 이로 인해 저장이 중복으로 트리거될 가능성이 확인됨.
*   **해결**: `ActiveWorkoutPage` 내부에 `_isSaving` 상태 플래그를 도입.
    *   `_finishWorkout` 및 `_handleBackPress` 진입 시 `_isSaving`이 `true`이면 즉시 리턴.
    *   저장 시작 전 `_isSaving = true`, 저장 완료(finally) 후 `_isSaving = false` 처리.
    *   이로써 저장 중 화면 전환이나 추가 조작에 의한 중복 저장(Race Condition)을 원천 차단함.

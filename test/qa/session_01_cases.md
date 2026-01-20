# Session 01 QA Report

## 담당 시나리오: T01, T02
- **테스트 일시:** 2025-05-20 (Current)
- **테스트 환경:** Linux (Flutter 3.x), Automated Test (Flutter Test)

## 테스트 결과 요약

| ID | 시나리오 명 | 재현 방법 | 기대 결과 | 실제 결과 | 상태 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | **0kg 입력 방어** | 무게에 0 입력 후 완료 체크 시도 | 체크 불가 & "무게와 횟수를 입력해주세요" 스낵바 표시 | 체크 불가, 스낵바 정상 표시됨 | ✅ Pass |
| **T02** | **0reps 입력 방어** | 횟수에 0 입력 후 완료 체크 시도 | 체크 불가 & "무게와 횟수를 입력해주세요" 스낵바 표시 | 체크 불가, 스낵바 정상 표시됨 | ✅ Pass |

## 상세 실행 내역

### 1. T01: 0kg 입력 방어
- **Environment:** Widget Test
- **Action:** `ExerciseCard`에서 weight=0, reps=10 설정 후 Checkbox 탭.
- **Verification:**
  - `ExerciseSet.isCompleted` remains `false`.
  - SnackBar with text "무게와 횟수를 입력해주세요" found.

### 2. T02: 0reps 입력 방어
- **Environment:** Widget Test
- **Action:** `ExerciseCard`에서 weight=100, reps=0 설정 후 Checkbox 탭.
- **Verification:**
  - `ExerciseSet.isCompleted` remains `false`.
  - SnackBar with text "무게와 횟수를 입력해주세요" found.

### 3. 정상 케이스 (Reference)
- **Environment:** Widget Test
- **Action:** weight=60, reps=12 설정 후 Checkbox 탭.
- **Verification:**
  - `ExerciseSet.isCompleted` becomes `true`.
  - No SnackBar shown.

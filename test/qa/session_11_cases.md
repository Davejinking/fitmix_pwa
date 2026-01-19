# QA Session 11 테스트 결과

담당자: Jules (CPO)
일시: 2025-05-24
환경: Flutter 3.38.7 / Dart 3.10.7 / Linux Sandbox

## 테스트 요약
| ID | 시나리오 명 | 결과 | 비고 |
| :--- | :--- | :--- | :--- |
| **T21** | **날짜 경계(00:00)** | ✅ **Pass** | Hive Key 기반 날짜 분리 검증 완료 |
| **T22** | **최신순 정렬** | ✅ **Pass** | 기록 조회 시 내림차순(Newest first) 정렬 검증 완료 |

## 상세 리포트

| 시나리오 ID | 재현 방법 (Test Steps) | 기대 결과 (Expected) | 실제 결과 (Actual) | 테스트 일시 | 테스트 환경 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T21** | 1. 23:59(`2025-01-01`) 세션 생성 및 저장<br>2. 00:01(`2025-01-02`) 세션 생성 및 저장<br>3. `SessionRepo.get()`으로 각 날짜 조회 | 두 세션이 날짜별로 명확히 분리되어 저장되고 조회되어야 함. 키 충돌 없음. | **Pass**<br>Key '2025-01-01'과 '2025-01-02'로 정확히 분리 저장됨 확인. | 2025-05-24 | Local Unit Test (Hive Memory) |
| **T22** | 1. 1일, 3일, 2일 순서로 세션 랜덤 저장<br>2. `getRecentExerciseHistory` 호출<br>3. 반환된 리스트의 날짜 순서 확인 | 최신 날짜(`2025-01-03`)가 리스트 최상단(Index 0)에 위치해야 함 (내림차순). | **Pass**<br>반환 순서: 3일 -> 2일 -> 1일 확인됨.<br>(참고: 내부 `listAll`은 오름차순이나 UI용 메서드는 내림차순 정상 반환) | 2025-05-24 | Local Unit Test (Hive Memory) |

## 실행 커맨드
```bash
flutter test test/features/qa_session_11_test.dart
```

## 코드 분석 노트
- **T21**: `SessionRepo`는 `yyyy-MM-dd` 포맷 문자열을 Key로 사용하므로, 날짜가 바뀌면 Key가 변경되어 데이터가 물리적으로 분리됨을 보장함.
- **T22**: `SessionRepo.listAll()`은 날짜 오름차순(과거->미래)으로 정렬하여 캘린더/그래프 로직을 지원하고, `getRecentExerciseHistory()`는 `.reversed`를 사용하여 UI 요구사항인 최신순(미래->과거) 정렬을 충족함.

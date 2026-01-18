# 리팩터링 노트 (정리 PR)

## 개요
이번 정리 PR은 **기능 변경 없이 구조/의존성 정리와 중복 제거**에 초점을 맞췄습니다.

## 폴더 구조 정리 (Feature/Module 기준)
- `lib/pages`, `lib/widgets`를 해체하고 `lib/features/*` 기준으로 기능별 분리.
- 공통 위젯은 `lib/shared/widgets`로 이동.
- 결과적으로 UI 계층의 파일 탐색 경로가 기능 단위로 명확해짐.

### 주요 매핑 예시
- 인증: `lib/features/auth/pages/*`
- 홈/쉘/스플래시: `lib/features/home/pages/*`
- 캘린더: `lib/features/calendar/pages|widgets/*`
- 분석/통계: `lib/features/analysis/pages|widgets/*`
- 운동: `lib/features/workout/pages|widgets/*`
- 프로필: `lib/features/profile/pages|widgets/*`
- 공통 UI: `lib/shared/widgets/*`

## 중복 코드 제거 및 공통 유틸 분리
- 로케일 기반 월/날짜 포맷 로직이 분산되어 있던 부분을
  `lib/utils/date_format_utils.dart`로 통합.
- `WorkoutHeatmap`, `WeekStrip`에서 공통 유틸 사용.

## Import 정리
- 이동된 파일들의 상대 경로를 정리하고, 기능 간 참조는
  `lib/features/<feature>/...` 내 상대 경로로 통일.

## 의존성 흐름 안정화 (최소 수정)
- 기능 모듈 간 참조는 **features 내 상대 경로**를 사용해 흐름을 명시화.
- 공통 UI 위젯은 `shared/widgets`로 분리해 의존성 역전을 완화.

## 영향 범위
- 기능 변경 없음.
- 컴파일 경로/모듈 구조만 정리.

## 후속 정리 제안 (선택)
- `features/*` 내에서 `pages`, `widgets`, `models` 등 세부 규칙을 팀 룰로 명문화.
- 불필요한 데모 화면은 `demo` 플래그 또는 별도 샘플 앱으로 분리 검토.

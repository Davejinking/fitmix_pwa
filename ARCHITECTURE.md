# FitMix PWA - 프로젝트 아키텍처

## 프로젝트 개요
FitMix PWA는 피트니스 추적 및 운동 관리를 위한 Flutter 기반 프로그레시브 웹 애플리케이션입니다. 이 프로젝트는 깔끔한 아키텍처 패턴을 따르며 관심사의 명확한 분리를 유지합니다.

## 디렉토리 구조

```
fitmix_pwa/
├── .dart_tool/                    # Dart 빌드 산출물 및 캐시
├── .github/
│   └── workflows/
│       └── pages.yml              # GitHub Pages 배포 워크플로우
├── .vscode/                       # VS Code 설정
├── assets/                        # 정적 자산
│   ├── audio/                     # 오디오 파일
│   ├── data/
│   │   └── exercises.json         # 운동 데이터베이스
│   ├── fonts/
│   │   ├── Pretendard-Bold.otf
│   │   └── Pretendard-Regular.otf
│   ├── icons/                     # SVG 아이콘
│   │   ├── ic_analysis.svg
│   │   ├── ic_arrow_right.svg
│   │   ├── ic_calendar.svg
│   │   ├── ic_close.svg
│   │   ├── ic_home.svg
│   │   ├── ic_info.svg
│   │   ├── ic_library.svg
│   │   ├── ic_logout.svg
│   │   ├── ic_person.svg
│   │   ├── ic_settings.svg
│   │   ├── ic_theme.svg
│   │   ├── ic_tv.svg
│   │   └── ic_warning.svg
│   ├── sounds/                    # 효과음
│   └── presets.json               # 프리셋 설정
├── build/                         # 빌드 출력 (자동 생성)
├── doc/                           # 문서
│   ├── final_summary.md
│   ├── i18n_guideline.md
│   ├── i18n_migration_report.md
│   ├── project_status.md
│   ├── todo.md
│   ├── youtube_style_bottom_nav.md
│   ├── youtube_style_refactoring_summary.md
│   └── youtube_style_settings.md
├── lib/                           # 메인 애플리케이션 코드
│   ├── core/                      # 핵심 유틸리티 및 설정
│   │   ├── burn_fit_style.dart    # 앱 스타일 상수
│   │   ├── calendar_config.dart   # 캘린더 설정
│   │   ├── constants.dart         # 전역 상수
│   │   ├── error_handler.dart     # 에러 처리 유틸리티
│   │   ├── feature_flags.dart     # 기능 플래그 관리
│   │   ├── l10n_extensions.dart   # 다국어 확장
│   │   └── theme_notifier.dart    # 테마 상태 관리
│   ├── data/                      # 데이터 계층 - 저장소
│   │   ├── auth_repo.dart         # 인증 저장소
│   │   ├── exercise_library_repo.dart  # 운동 라이브러리 저장소
│   │   ├── session_repo.dart      # 운동 세션 저장소
│   │   ├── settings_repo.dart     # 사용자 설정 저장소
│   │   └── user_repo.dart         # 사용자 프로필 저장소
│   ├── l10n/                      # 다국어 지원 (i18n)
│   │   ├── app_en.arb             # 영어 번역
│   │   ├── app_ja.arb             # 일본어 번역
│   │   ├── app_ko.arb             # 한국어 번역
│   │   ├── app_localizations.dart # 생성된 다국어 클래스
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_ja.dart
│   │   └── app_localizations_ko.dart
│   ├── models/                    # 데이터 모델
│   │   ├── exercise.dart          # 운동 모델
│   │   ├── exercise.g.dart        # Exercise 생성 코드
│   │   ├── exercise_db.dart       # 운동 데이터베이스 모델
│   │   ├── exercise_set.dart      # 운동 세트 모델
│   │   ├── exercise_set.g.dart    # ExerciseSet 생성 코드
│   │   ├── session.dart           # 운동 세션 모델
│   │   ├── session.g.dart         # Session 생성 코드
│   │   ├── user_profile.dart      # 사용자 프로필 모델
│   │   └── user_profile.g.dart    # UserProfile 생성 코드
│   ├── pages/                     # UI 페이지/화면
│   │   ├── analysis_page.dart     # 운동 분석 페이지
│   │   ├── calendar_page.dart     # 캘린더 보기 페이지
│   │   ├── home_page.dart         # 홈 페이지
│   │   ├── library_page.dart      # 운동 라이브러리 (v1)
│   │   ├── library_page_v2.dart   # 운동 라이브러리 (v2)
│   │   ├── login_page.dart        # 로그인 페이지
│   │   ├── plan_page.dart         # 운동 계획 페이지
│   │   ├── profile_page.dart      # 사용자 프로필 페이지
│   │   ├── settings_page.dart     # 설정 페이지
│   │   ├── shell_page.dart        # 메인 네비게이션 페이지
│   │   ├── splash_page.dart       # 스플래시 화면
│   │   ├── upgrade_page.dart      # 업그레이드/프리미엄 페이지
│   │   ├── user_info_form_page.dart  # 사용자 정보 입력 폼
│   │   ├── voice_recorder_page.dart  # 음성 녹음 페이지
│   │   └── workout_page.dart      # 운동 실행 페이지
│   ├── services/                  # 비즈니스 로직 서비스
│   │   ├── audio_recorder_service.dart  # 오디오 녹음 서비스
│   │   ├── exercise_db_service.dart     # 운동 데이터베이스 서비스
│   │   ├── rhythm_engine.dart           # 리듬/타이밍 엔진
│   │   └── tempo_metronome_service.dart # 메트로놈 서비스
│   ├── utils/                     # 유틸리티 함수
│   │   └── dummy_data_generator.dart    # 테스트 데이터 생성
│   ├── widgets/                   # 재사용 가능한 UI 컴포넌트
│   │   ├── calendar/              # 캘린더 관련 위젯
│   │   │   ├── calendar_modal_sheet.dart
│   │   │   ├── day_timeline_list.dart
│   │   │   ├── month_header.dart
│   │   │   └── week_strip.dart
│   │   ├── common/                # 공통/공유 위젯
│   │   │   ├── fm_app_bar.dart    # 커스텀 앱 바
│   │   │   ├── fm_bottom_nav.dart # 커스텀 하단 네비게이션
│   │   │   └── fm_section_header.dart  # 섹션 헤더 위젯
│   │   ├── exercise_set_card.dart
│   │   ├── exercise_set_card_demo.dart
│   │   ├── goal_card.dart
│   │   ├── rest_timer_bar.dart
│   │   ├── set_input_card.dart
│   │   ├── summary_chart.dart
│   │   └── tempo_settings_modal.dart
│   └── main.dart                  # 애플리케이션 진입점
├── scripts/                       # 유틸리티 스크립트
│   ├── fetch_exercises.dart       # 운동 데이터 가져오기 스크립트
│   ├── fetch_free_exercises.dart  # 무료 운동 데이터 가져오기 스크립트
│   └── README.md
├── test/                          # 단위 및 통합 테스트
│   ├── calendar_config_test.dart
│   └── session_repo_test.dart
├── web/                           # 웹 관련 파일
│   ├── icons/                     # 웹 앱 아이콘
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── favicon.png
│   ├── index.html                 # 웹 진입점
│   └── manifest.json              # PWA 매니페스트
├── .flutter-plugins-dependencies  # Flutter 플러그인 메타데이터
├── .gitignore                     # Git 무시 규칙
├── .metadata                      # Flutter 메타데이터
├── analysis_options.yaml          # Dart 분석 설정
├── l10n.yaml                      # 다국어 설정
├── pubspec.lock                   # 잠금된 의존성 버전
├── pubspec.yaml                   # 프로젝트 의존성 및 메타데이터
└── README.md                      # 프로젝트 README
```

## 아키텍처 계층

### 1. 프레젠테이션 계층 (pages/ & widgets/)
- **Pages**: 다양한 라우트를 나타내는 전체 화면 UI 컴포넌트
- **Widgets**: 페이지 전체에서 사용되는 재사용 가능한 UI 컴포넌트
- 사용자 상호작용을 처리하고 데이터를 표시

### 2. 비즈니스 로직 계층 (services/)
- **AudioRecorderService**: 오디오 녹음 기능 관리
- **ExerciseDbService**: 운동 데이터베이스 작업 처리
- **RhythmEngine**: 운동 리듬 및 타이밍 관리
- **TempoMetronomeService**: 메트로놈 기능 제공

### 3. 데이터 계층 (data/)
- **저장소**: 데이터 접근 패턴 추상화
  - AuthRepo: 인증 작업
  - ExerciseLibraryRepo: 운동 라이브러리 데이터
  - SessionRepo: 운동 세션 데이터
  - SettingsRepo: 사용자 설정
  - UserRepo: 사용자 프로필 데이터

### 4. 도메인 계층 (models/)
- **데이터 모델**: 핵심 비즈니스 엔티티
  - Exercise: 개별 운동 정의
  - ExerciseSet: 운동 세트
  - Session: 운동 세션
  - UserProfile: 사용자 정보

### 5. 핵심 계층 (core/)
- **설정**: 앱 전체 설정 및 상수
- **테마 관리**: 테마 상태 및 스타일링
- **다국어 지원**: 다중 언어 지원
- **에러 처리**: 중앙화된 에러 관리
- **기능 플래그**: 기능 토글 관리

## 주요 기능

### 국제화 (i18n)
- 영어, 일본어, 한국어 지원
- 번역 관리를 위한 ARB 파일
- 자동 생성되는 다국어 클래스

### 지역화 (l10n)
- 지역별 캘린더 설정
- 로케일 기반 날짜/시간 형식

### 상태 관리
- ThemeNotifier를 통한 테마 상태
- 단계적 롤아웃을 위한 기능 플래그

### UI 컴포넌트
- 커스텀 앱 바 (fm_app_bar)
- 커스텀 하단 네비게이션 (fm_bottom_nav)
- 날짜 선택을 위한 캘린더 위젯
- 운동 표시를 위한 운동 세트 카드
- 인터벌 추적을 위한 휴식 타이머 바

## 빌드 및 배포

### 빌드 산출물
- `build/`: 생성된 빌드 출력
- `.dart_tool/`: Dart 컴파일 캐시

### 웹 배포
- `web/index.html`: 웹 진입점
- `web/manifest.json`: PWA 매니페스트
- GitHub Pages 워크플로우: `.github/workflows/pages.yml`

## 설정 파일

- `pubspec.yaml`: 프로젝트 의존성 및 메타데이터
- `analysis_options.yaml`: Dart 린터 설정
- `l10n.yaml`: 다국어 설정
- `.vscode/settings.json`: VS Code 워크스페이스 설정

## 테스트

- `test/` 디렉토리의 단위 테스트
- 캘린더 설정 및 세션 저장소 테스트 커버리지
- Flutter 테스트 프레임워크를 통한 통합 테스트 지원

## 문서

- `doc/`: 프로젝트 문서
  - 아키텍처 결정 사항
  - 국제화 가이드라인
  - 기능 구현 가이드
  - 프로젝트 상태 및 로드맵

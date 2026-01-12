# Iron Log - Noir 감성 웨이트 트레이닝 앱

> **Noir & Dark 감성의 진지한 쇠질러를 위한 운동 기록 앱**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🎯 프로젝트 개요

**Iron Log**는 Noir 미학을 기반으로 한 웨이트 트레이닝 기록 앱입니다.

- **Iron (쇠)**: 무게, 강철 같은 의지
- **Log (기록)**: 운동 일지, 데이터 로그
- **타겟**: 글로벌 시장 (북미, 일본)

### 핵심 가치
- ⚫ **Noir 미학**: 순수 블랙 배경, Courier 폰트, 대문자 타이포그래피
- 🎯 **직관성**: 복잡한 설정 없이 바로 기록
- 🔥 **본질에 집중**: 불필요한 기능 제거

---

## ✨ 주요 기능

### 완료된 기능 (Phase 1: Athlete 모드)
- ✅ **운동 기록**: 세트/무게/횟수 추적
- ✅ **루틴 관리**: 루틴 생성/저장/불러오기
- ✅ **운동 라이브러리**: 40개 기본 운동 (다국어 지원)
- ✅ **템포 모드**: TTS/비프음/햅틱 피드백
- ✅ **휴식 타이머**: 커스텀 시간 설정
- ✅ **캘린더 & 히트맵**: 운동 기록 시각화
- ✅ **다국어**: 영어, 한국어, 일본어 (Hybrid Noir 전략)

### 진행 중
- 🚧 **Iron Pro 구독**: 고급 분석, 클라우드 백업
- 🚧 **고급 통계**: 주간/월간 리포트

---

## � 빠른 시작

### 요구사항
- Flutter 3.9.2 이상
- Dart 3.0 이상
- iOS 14.0+ / Android 6.0+

### 설치 및 실행

```bash
# 1. 패키지 설치
flutter pub get

# 2. Hive TypeAdapter 생성
flutter packages pub run build_runner build --delete-conflicting-outputs

# 3. 다국어 파일 생성
flutter gen-l10n

# 4. 실행
flutter run

# 5. 빌드
flutter build ios --release
flutter build apk --release
```

---

## 📚 문서

### 핵심 문서
- **[IRON_LOG_MASTER.md](doc/IRON_LOG_MASTER.md)** - 📖 **마스터 문서 (필독!)**
  - 프로젝트 개요
  - 기술 스택 & 코딩 규칙
  - 데이터베이스 스키마
  - 현재 기능 & 상태
  - 프로젝트 파일 구조

### 추가 문서
- [ROADMAP.md](doc/ROADMAP.md) - 개발 로드맵 (Phase 1~3)
- [DEVELOPMENT.md](doc/DEVELOPMENT.md) - 개발 환경 설정
- [ARCHITECTURE.md](doc/ARCHITECTURE.md) - 아키텍처 설계
- [AGENTS.md](doc/AGENTS.md) - AI 에이전트 규칙

### 아카이브
- [doc/archive/](doc/archive/) - 이전 문서 및 작업 기록

---

## 🛠️ 기술 스택

### Frontend
- **Flutter** - UI 프레임워크
- **Material Design 3** - 디자인 시스템

### Data & State
- **Hive** - NoSQL 로컬 데이터베이스
- **GetIt** - 의존성 주입

### Localization
- **flutter_localizations** - 다국어 지원
- **Hybrid Noir 전략** - Design Elements 영어 고정, Usability 다국어

### Charts & Visualization
- **fl_chart** - 차트 라이브러리
- **table_calendar** - 캘린더 위젯

### Audio & Haptics
- **flutter_tts** - TTS (템포 모드)
- **audioplayers** - 비프음

---

## 🌍 다국어 전략: "Hybrid Noir"

Iron Log는 독특한 다국어 전략을 사용합니다:

- **Design Elements (영어 고정)**: 타이틀, 라벨, 상태 메시지
  - 예: `WEEKLY STATUS`, `MONTHLY GOAL`, `EXERCISES`
  - 이유: Noir 미학, 브랜드 아이덴티티 유지

- **Usability Elements (다국어)**: 버튼, 입력 힌트, 에러 메시지
  - 예: `운동 시작` / `Start Workout` / `ワークアウト開始`
  - 이유: 사용자 경험 향상

---

## 📁 프로젝트 구조

```
fitmix_pwa/
├── lib/
│   ├── core/           # 공통 설정 (테마, DI, 상수)
│   ├── data/           # Repository 레이어
│   ├── models/         # Hive 모델
│   ├── pages/          # 화면
│   ├── widgets/        # 재사용 위젯
│   ├── services/       # 비즈니스 로직
│   ├── l10n/           # 다국어 ARB 파일
│   └── main.dart       # 앱 진입점
├── assets/             # 폰트, 사운드, 이미지
├── doc/                # 문서
│   ├── IRON_LOG_MASTER.md  # 📖 마스터 문서
│   └── archive/        # 이전 문서
└── README.md           # 이 파일
```

---

## 💰 수익화 모델

### Free (무료)
- 운동 기록 무제한
- 기본 통계
- 휴식 타이머
- 템포 모드

### Iron Pro ($3.99/월)
- 고급 차트 및 분석
- 클라우드 백업
- 테마 변경
- 광고 제거
- 무제한 루틴 저장

### Coach Pro ($20~/월) - Phase 3
- 회원 관리 (최대 50명)
- 프로그램 배포
- 수익 분석

---

## 🎨 디자인 철학

### Noir 미학
- **배경**: 순수 블랙 (#000000)
- **폰트**: Courier (고정폭)
- **타이포그래피**: 대문자, 넓은 자간
- **컬러**: 화이트, 다크 그레이, 미니멀 액센트

### UI 원칙
1. **무게감**: 묵직하고 진지한 느낌
2. **직관성**: 복잡한 설정 없이 바로 사용
3. **심플함**: 불필요한 요소 제거

---

## 📊 개발 진행률

```
Phase 1 (Athlete 모드): ████████░░ 80%
├─ Core Features:       ██████████ 100%
├─ UI/UX:               ██████████ 100%
├─ Advanced Features:   ████████░░ 80%
└─ Monetization:        ████░░░░░░ 40%

Phase 2 (Squad 모드):   ░░░░░░░░░░ 0%
Phase 3 (Coach 모드):   ░░░░░░░░░░ 0%
```

---

## 🤝 기여

현재 개인 프로젝트로 진행 중입니다.

---

## 📄 라이선스

MIT License

---

## 📞 문의

프로젝트 관련 문의는 이슈를 통해 남겨주세요.

---

**Built with 🏋️ by Iron Log Team**  
**Last Updated**: 2026-01-12

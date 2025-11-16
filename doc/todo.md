# FitMix TODO List

**프로젝트:** FitMix PS0 → PS1 전환 준비  
**작성일:** 2024-11-16  
**최종 업데이트:** 2024-11-16

---

## 📋 소개

이 문서는 FitMix 프로젝트의 전체 TODO 항목을 관리합니다.
- PS0: 현재 로컬 전용 버전 (Hive 기반)
- PS1: Supabase 연동 버전 (동기화 지원)
- PS2: 유료 기능 및 Tier 시스템
- Social: 소셜 기능 및 3대 중량 인증 시스템

각 항목은 체크박스로 관리되며, 완료 시 `[x]`로 표시합니다.

---

## ✅ 1. PS0 클린업

### 1-1. BuildContext Async Gaps (20개)

**목표:** async 함수에서 BuildContext 사용 시 안전성 확보

- [ ] async 함수에서 await 이후 mounted/context.mounted 체크 추가
- [ ] Navigator push/pop 안전화
- [ ] showDialog / SnackBar / ScaffoldMessenger 호출부 점검
- [ ] workout_page.dart 반영
- [x] settings_page.dart 반영 (2024-11-16)
- [ ] analysis_page.dart 반영
- [ ] library_page.dart 반영
- [ ] profile_page.dart 반영
- [ ] user_info_form_page.dart 반영
- [ ] login_page.dart 반영
- [ ] plan_page.dart 반영
- [ ] 전체 20개 포인트 수정 완료

**참고 패턴:**
```dart
// Before
await someAsyncFunction();
Navigator.of(context).push(...);

// After
await someAsyncFunction();
if (!mounted) return;
Navigator.of(context).push(...);
```

---

## ✅ 2. Deprecated / 스타일 정리

### 2-1. RadioGroup 마이그레이션

- [x] RadioListTile → RadioGroup 변경
- [x] deprecated 경고 제거 (settings_page.dart)
- [x] deprecated 경고 제거 (workout_page.dart)
- [x] 기존 동작 유지 확인
- [x] 테스트 완료
- [x] settings_page.dart 불필요한 import 제거 (2024-11-16)

### 2-2. 코드 스타일 정리

- [ ] 불필요한 문자열 보간 제거 (analysis_page.dart)
- [ ] 불필요한 문자열 보간 제거 (plan_page.dart)
- [ ] 불필요한 문자열 보간 제거 (workout_page.dart)
- [ ] 불필요한 .toString() 제거
- [ ] 공통 스타일 guideline 반영
- [ ] flutter analyze 0 issues 달성

---

## ✅ 3. i18n 최종 정리

### 3-1. 화면 번역 적용

**완료:**
- [x] home_page.dart
- [x] shell_page.dart
- [x] doc/i18n_guideline.md 작성

**진행 중:**
- [ ] calendar_page.dart
- [ ] analysis_page.dart
- [ ] library_page.dart
- [ ] workout_page.dart
- [ ] profile_page.dart
- [ ] settings_page.dart
- [ ] login_page.dart
- [ ] splash_page.dart
- [ ] user_info_form_page.dart
- [ ] plan_page.dart

**ARB 파일 업데이트:**
- [ ] app_ko.arb 키 추가
- [ ] app_en.arb 키 추가
- [ ] app_ja.arb 키 추가
- [ ] i18n 키 네이밍 규칙 준수 확인

### 3-2. locale 구조 개선

- [ ] SettingsRepo에 preferredLocale 저장 기능 추가
- [ ] MaterialApp.locale 연동
- [ ] 언어 선택 UI 시안 작성
- [ ] 언어 변경 시 앱 재시작 없이 반영
- [ ] 시스템 언어 자동 감지 옵션

---

## ✅ 4. PS1 준비 (Supabase 연동 설계)

### 4-1. DB 스키마 설계

- [ ] profiles 테이블 스키마 정의
  - user_id (UUID, PK)
  - display_name, email, profile_image_url
  - height, weight, monthly_workout_goal, monthly_volume_goal
  - created_at, updated_at
- [ ] workout_sessions 테이블 스키마 정의
  - session_id (UUID, PK)
  - user_id (FK)
  - ymd (date), total_volume, is_workout_day
  - created_at, updated_at
- [ ] workout_sets 테이블 스키마 정의
  - set_id (UUID, PK)
  - session_id (FK)
  - exercise_id (FK)
  - set_number, weight, reps, is_completed
  - created_at
- [ ] exercises 테이블 스키마 정의
  - exercise_id (UUID, PK)
  - name_ko, name_en, name_ja
  - category, muscle_group
  - is_custom, user_id (nullable)
- [ ] sync_logs 테이블 스키마 정의 (옵션)
  - log_id (UUID, PK)
  - user_id (FK)
  - sync_type, status, error_message
  - synced_at
- [ ] doc/db_schema_v1.md 생성
- [ ] RLS (Row Level Security) 정책 정의
- [ ] 인덱스 최적화 계획

### 4-2. Sync 설계 (Hive ↔ Supabase)

- [ ] 동기화 시점 정의
  - 앱 시작 시
  - 운동 종료 시
  - 수동 동기화 버튼
  - 백그라운드 주기적 동기화
- [ ] 충돌 정책 확정 (LWW - Last Write Wins)
- [ ] 네트워크 오류 처리
  - 재시도 로직
  - 오프라인 큐
  - 사용자 알림
- [ ] 동기화 상태 UI 설계
- [ ] doc/sync_policy.md 작성
- [ ] 동기화 테스트 시나리오 작성

### 4-3. Supabase 설정

- [ ] Supabase 프로젝트 생성
- [ ] 환경 변수 설정 (.env)
- [ ] supabase_flutter 패키지 추가
- [ ] 인증 플로우 구현
  - Google Sign-In 연동
  - 게스트 → 회원 전환
- [ ] 초기 데이터 마이그레이션 스크립트

---

## ✅ 5. PS2 대비 (Feature Flags / Tier)

### 5-1. Tier 정의

- [ ] tier_free 기능 정의
  - 기본 운동 기록
  - 로컬 저장
  - 기본 통계
- [ ] tier_basic 기능 정의
  - 클라우드 동기화
  - 무제한 운동 기록
  - 고급 통계
- [ ] tier_pro 기능 정의
  - AI 운동 추천
  - 소셜 기능
  - 3대 중량 인증
  - 프리미엄 테마

### 5-2. Feature Flag 시스템

- [ ] Feature Flag 매핑표 작성
- [ ] FeatureFlagRepo 구현
- [ ] UI에서 Feature Flag 체크 로직 추가
- [ ] 업그레이드 유도 UI 설계
- [ ] doc/feature_flags.md 생성

### 5-3. 결제 시스템

- [ ] 결제 라우팅 플로우 초안
- [ ] 인앱 결제 패키지 선정 (in_app_purchase)
- [ ] 구독 관리 UI 설계
- [ ] 영수증 검증 로직
- [ ] 환불 정책 문서화

---

## 🌟 6. Social / 3대 중량(PR) 인증 기능 (초안)

### 6-1. 인증(PR) 기록 시스템

- [ ] bench/squat/dead 전용 lift_records 테이블 설계
  - record_id (UUID, PK)
  - user_id (FK)
  - lift_type (bench/squat/deadlift)
  - weight, reps, estimated_1rm
  - recorded_at, is_verified
- [ ] 1RM 자동 계산 룰 정의
  - Epley 공식: 1RM = weight × (1 + reps/30)
  - Brzycki 공식: 1RM = weight × (36/(37-reps))
  - 사용자 선택 옵션
- [ ] PR 갱신 시 "인증 카드" 자동 생성
- [ ] PR 기록 시 애니메이션/모션 플로우 설계
  - 축하 애니메이션 (confetti)
  - 사운드 효과
  - 햅틱 피드백
- [ ] PR 히스토리 조회 UI

### 6-2. 인증 카드(Instagram 감성) UI

- [ ] PR 카드 기본 템플릿 디자인
  - 카드 크기: 1080x1920 (Instagram Story 비율)
  - 레이아웃: 상단 프로필, 중앙 PR 정보, 하단 날짜
- [ ] 배경 디자인 옵션
  - 그라데이션 (블루 → 퍼플)
  - 블러 효과
  - 운동 머신 라인아트
  - 사용자 업로드 이미지
- [ ] 텍스트 스타일
  - "오늘의 PR" 헤더
  - "새로운 3대 합계" 강조
  - 폰트: 굵은 산세리프
- [ ] 공유용 이미지 Export 기능
  - PNG 저장
  - 갤러리 저장
  - SNS 직접 공유

### 6-3. 피드(FEED) / 타임라인 기능

- [ ] posts 테이블 설계
  - post_id (UUID, PK)
  - user_id (FK)
  - content_text, post_type (workout/pr/story)
  - like_count, comment_count
  - created_at, updated_at
- [ ] post_assets 테이블 설계 (이미지/영상 업로드)
  - asset_id (UUID, PK)
  - post_id (FK)
  - asset_url, asset_type (image/video)
  - order_index
- [ ] 하루 PR/운동 요약 자동 포스팅 옵션
- [ ] Like(🔥), 댓글, 저장 기능 설계
  - likes 테이블
  - comments 테이블
  - saved_posts 테이블
- [ ] 피드 UI 구현
  - 무한 스크롤
  - 이미지 캐싱
  - 좋아요 애니메이션

### 6-4. 스토리(Story) 기능 (인스타 느낌)

- [ ] stories 테이블 설계
  - story_id (UUID, PK)
  - user_id (FK)
  - story_type (workout_start/workout_end/pr)
  - asset_url, expires_at (24시간)
- [ ] 운동 시작 → 스토리 자동 생성
  - "운동 시작!" 템플릿
  - 시작 시간 표시
- [ ] 운동 종료 → "오늘 성과 요약" 스토리 생성
  - 총 볼륨, 운동 시간
  - PR 갱신 여부
- [ ] GIF 배경 + 텍스트 + PR 자동 배치
- [ ] 스토리 24시간 유지 또는 개인 기록 저장 옵션
- [ ] 스토리 뷰어 UI
  - 좌우 스와이프
  - 진행 바
  - 자동 재생

### 6-5. 랭킹 시스템

- [ ] 3대 총합 합산 로직 설계
  - bench + squat + deadlift 1RM 합계
  - 체급별 분류 (선택)
- [ ] 랭킹 카테고리
  - 전체 랭킹
  - 지역별 랭킹
  - 헬스장별 랭킹
  - 친구 랭킹
- [ ] 인증 배지 시스템
  - 300kg 클럽
  - 400kg 클럽
  - 500kg 클럽
  - 600kg+ 엘리트
- [ ] 월간 랭킹 리셋 룰
- [ ] 랭킹 UI 구현
  - 리더보드
  - 내 순위 표시
  - 배지 표시

### 6-6. 기존 FitMix와 통합 여부 검토

- [ ] Social 기능을 탭 하나로 추가할지 결정
  - 장점: 통합된 경험
  - 단점: 앱 복잡도 증가
- [ ] 또는 "프로필 페이지 확장" 구조로 넣을지 결정
  - 장점: 기존 구조 유지
  - 단점: 접근성 낮음
- [ ] 향후 서비스 분리 필요 여부 검토
  - FitMix (운동 기록)
  - FitMix Social (소셜 기능)
- [ ] 아키텍처 결정 문서 작성

---

## 🔍 7. 유지관리

### 7-1. 코드 품질

- [ ] flutter analyze 정기 실행 (주 1회)
- [ ] deprecated 항목 TODO 자동 반영
- [ ] 린트 규칙 100% 준수
- [ ] 코드 리뷰 체크리스트 작성

### 7-2. 문서화

- [ ] Kiro TODO → todo.md 싱크 유지
- [ ] release note 템플릿 작성 (doc/release_notes.md)
- [ ] API 문서 자동 생성 (dartdoc)
- [ ] 개발자 가이드 작성

### 7-3. 테스트

- [ ] 단위 테스트 커버리지 50% 이상
- [ ] 위젯 테스트 주요 화면
- [ ] 통합 테스트 시나리오 작성
- [ ] CI/CD 파이프라인 구축

### 7-4. 성능 최적화

- [ ] 앱 시작 시간 측정 및 개선
- [ ] 메모리 사용량 프로파일링
- [ ] 이미지 최적화 (압축, 캐싱)
- [ ] 데이터베이스 쿼리 최적화

---

## 📊 진행 상황 요약

### PS0 클린업
- 완료: 3/22 (14%)
- 진행 중: BuildContext Async Gaps
- 최근 완료: settings_page.dart 정리 (2024-11-16)

### i18n
- 완료: 2/10 (20%)
- 진행 중: 나머지 페이지 번역

### PS1 준비
- 완료: 0/15 (0%)
- 대기 중: DB 스키마 설계

### PS2 대비
- 완료: 0/10 (0%)
- 대기 중: Tier 정의

### Social 기능
- 완료: 0/30 (0%)
- 대기 중: 기획 확정

---

## 🎯 오늘 완료 (2024-11-16)

### UI/UX 개선
- [x] main.dart _themeMode 초기화 에러 수정 (LateInitializationError 해결)
- [x] settings_page.dart 불필요한 import 3개 제거
- [x] settings_page.dart BuildContext async gap 수정
- [x] 캘린더 "오늘" 버튼 선택 상태 로직 개선
  - 오늘 날짜 선택 시: 파란색 강조
  - 다른 날짜 선택 시: 회색 표시

### 코드 품질
- [x] flutter analyze 에러 0개 유지
- [x] 경고 30개 (기능 영향 없음, info/warning만)

---

## 📝 메모

### 우선순위
1. **High:** PS0 클린업 (BuildContext, i18n)
2. **Medium:** PS1 준비 (Supabase 연동)
3. **Low:** PS2, Social 기능 (장기 계획)

### 다음 스프린트 목표
- [ ] BuildContext Async Gaps 완료
- [ ] i18n 50% 완료
- [ ] DB 스키마 v1 확정

### 참고 링크
- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Supabase 문서](https://supabase.com/docs)
- [i18n 가이드라인](./i18n_guideline.md)
- [마이그레이션 보고서](./i18n_migration_report.md)

---

**마지막 업데이트:** 2024-11-16  
**다음 리뷰:** 2024-11-23

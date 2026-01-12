# YouTube 스타일 Shell 구조 리팩터링 완료

## 개요
FitMix 앱을 YouTube 앱과 유사한 구조로 리팩터링했습니다. 기존 "주간 스트립 + 모달 달력" 캘린더 구조는 그대로 유지하면서, 전체 앱 레이아웃을 개선했습니다.

## 주요 변경사항

### 1. 공통 위젯 생성

#### `lib/widgets/common/fm_app_bar.dart`
- 재사용 가능한 AppBar 위젯
- 알림/프로필/설정 아이콘 옵션
- 커스텀 actions 지원

#### `lib/widgets/common/fm_bottom_nav.dart`
- 공통 BottomNavigationBar 위젯
- SVG 아이콘 또는 Material Icons 지원
- 4개 탭 구성 (홈/캘린더/라이브러리/분석)

#### `lib/widgets/common/fm_section_header.dart`
- 섹션 헤더 위젯
- 제목 + 액션 버튼 구조
- 홈 화면 섹션에서 재사용 가능

### 2. ShellPage 리팩터링

**변경 전:**
- 각 페이지마다 Scaffold 사용
- 탭 전환 시 페이지 상태 손실

**변경 후:**
- IndexedStack 사용으로 탭 상태 보존
- 단일 Scaffold 구조
- 모든 페이지는 body 콘텐츠만 렌더링

```dart
// IndexedStack으로 상태 보존
body: IndexedStack(
  index: _currentIndex,
  children: _pages,
),
```

### 3. 각 페이지 개선

#### HomePage
- Scaffold 제거 → SafeArea + CustomScrollView
- 스크롤 중심 구조 유지
- 기존 기능 모두 유지 (목표 카드, 활동 추세 등)

#### CalendarPage
- Scaffold 제거 → SafeArea + Column
- 주간 스트립 + 모달 달력 구조 **완전히 유지**
- 좌우 화살표로 주 이동
- 오늘 버튼 추가 (MonthHeader에 위치)
- maxWidth 720px 제약으로 웹 최적화

#### LibraryPage
- 헤더 추가 (ライブラリ + 추가 버튼)
- FloatingActionButton 제거
- 기존 운동 라이브러리 기능 유지

#### AnalysisPage
- 헤더 추가 (分析)
- 부위별 볼륨 파이 차트
- 월별 운동 시간 라인 차트
- 기존 분석 기능 유지

### 4. 레이아웃 구조

```
ShellPage (Scaffold)
├── IndexedStack (body)
│   ├── HomePage (SafeArea + CustomScrollView)
│   ├── CalendarPage (SafeArea + Column)
│   ├── LibraryPage (SafeArea + Column)
│   └── AnalysisPage (SafeArea + Column)
└── FMBottomNav (bottomNavigationBar)
```

## 동작 확인

### ✅ 완료된 기능
1. **탭 전환 시 상태 보존** - IndexedStack 사용
2. **캘린더 기능 완전 유지**
   - 주간 스트립 좌우 화살표 이동
   - 날짜 탭 선택
   - 오늘 버튼으로 빠른 이동
   - 월 모달 열기/선택
3. **홈 화면 스크롤** - 목표/활동 추세 카드
4. **라이브러리** - 운동 추가/수정/삭제
5. **분석** - 차트 표시

### 🎨 디자인 개선
- 일관된 헤더 스타일 (흰색 배경 + 그림자)
- 깔끔한 BottomNavigationBar
- 웹 최적화 (maxWidth 제약)
- YouTube 스타일 레이아웃

## 코드 품질

```bash
flutter analyze --no-fatal-infos
```

**결과:**
- ✅ 에러 없음
- ⚠️ 경고 2개 (불필요한 중괄호, async gap) - 기능에 영향 없음

## 다음 단계 (향후 확장)

### 홈 화면 섹션 추가 (placeholder 준비됨)
- [ ] 추천 루틴 섹션 (가로 스크롤 카드)
- [ ] 최근 PR/하이라이트 섹션
- [ ] 최근 운동 기록 타임라인

### 라이브러리 확장
- [ ] 저장된 루틴 관리
- [ ] 루틴 템플릿

### 분석 확장
- [ ] 인바디 데이터 연동
- [ ] 더 많은 통계 차트
- [ ] 기간별 비교

## 파일 목록

### 새로 생성된 파일
- `lib/widgets/common/fm_app_bar.dart`
- `lib/widgets/common/fm_bottom_nav.dart`
- `lib/widgets/common/fm_section_header.dart`

### 수정된 파일
- `lib/pages/shell_page.dart` - IndexedStack 구조로 변경
- `lib/pages/home_page.dart` - CustomScrollView 구조
- `lib/pages/calendar_page.dart` - Scaffold 제거
- `lib/pages/library_page.dart` - 헤더 추가
- `lib/pages/analysis_page.dart` - 헤더 추가

### 유지된 파일 (변경 없음)
- `lib/widgets/calendar/week_strip.dart` - 주간 스트립
- `lib/widgets/calendar/calendar_modal_sheet.dart` - 월 모달
- `lib/widgets/calendar/month_header.dart` - 월 헤더
- `lib/widgets/calendar/day_timeline_list.dart` - 타임라인

## 결론

YouTube 스타일의 Shell 구조로 성공적으로 리팩터링되었습니다. 기존 캘린더 기능은 완전히 유지되며, 탭 상태 보존과 일관된 UI/UX를 제공합니다.

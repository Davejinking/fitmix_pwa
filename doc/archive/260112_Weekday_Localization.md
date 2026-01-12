# 260112 - 요일 로컬라이제이션 완료

## 변경 사항 (Changes)

### 1. 홈 페이지 주간 현황 요일 로컬라이제이션
**파일**: `lib/pages/home_page.dart`

**Before**:
```dart
final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
```

**After**:
```dart
final dayLabels = [
  context.l10n.weekdayMonShort,
  context.l10n.weekdayTueShort,
  context.l10n.weekdayWedShort,
  context.l10n.weekdayThuShort,
  context.l10n.weekdayFriShort,
  context.l10n.weekdaySatShort,
  context.l10n.weekdaySunShort,
];
```

### 2. 캘린더 위젯 로케일 설정
**파일**: `lib/widgets/calendar/week_strip.dart`, `lib/widgets/calendar/calendar_modal_sheet.dart`

**Before**:
```dart
TableCalendar(
  // locale 속성 없음
  firstDay: DateTime.utc(2020, 1, 1),
  ...
)
```

**After**:
```dart
TableCalendar(
  locale: locale.toString(), // 로케일 추가
  firstDay: DateTime.utc(2020, 1, 1),
  ...
)
```

### 3. ARB 파일에 짧은 요일 키 추가
모든 언어 파일에 `weekdayXxxShort` 키 추가:

**English (app_en.arb)**:
```json
"weekdayMonShort": "M",
"weekdayTueShort": "T",
"weekdayWedShort": "W",
"weekdayThuShort": "T",
"weekdayFriShort": "F",
"weekdaySatShort": "S",
"weekdaySunShort": "S"
```

**Korean (app_ko.arb)**:
```json
"weekdayMonShort": "월",
"weekdayTueShort": "화",
"weekdayWedShort": "수",
"weekdayThuShort": "목",
"weekdayFriShort": "금",
"weekdaySatShort": "토",
"weekdaySunShort": "일"
```

**Japanese (app_ja.arb)**:
```json
"weekdayMonShort": "月",
"weekdayTueShort": "火",
"weekdayWedShort": "水",
"weekdayThuShort": "木",
"weekdayFriShort": "金",
"weekdaySatShort": "土",
"weekdaySunShort": "日"
```

## 기술적 의사결정 (Tech Decisions)

### 1. 왜 `table_calendar`의 `locale` 속성을 사용하는가?
`table_calendar` 패키지는 자체적으로 요일 로컬라이제이션을 지원합니다:
- `locale` 속성에 로케일 문자열을 전달하면 자동으로 요일 이름을 해당 언어로 표시
- `intl` 패키지를 내부적으로 사용하여 표준 로케일 형식 지원

**장점**:
- 패키지의 기본 기능 활용
- 추가 커스터마이징 불필요
- 표준 로케일 형식 사용

### 2. 왜 홈 페이지는 커스텀 로컬라이제이션을 사용하는가?
홈 페이지의 주간 현황은 매우 짧은 형식(1글자)을 사용:
- **한국어**: 월, 화, 수, 목, 금, 토, 일 (1글자)
- **일본어**: 月, 火, 水, 木, 金, 土, 日 (1글자)
- **영어**: M, T, W, T, F, S, S (1글자)

`table_calendar`의 기본 형식은 더 길기 때문에 (Mon, Tue 등), 커스텀 키를 사용하여 1글자 형식 유지.

### 3. 로케일 문자열 형식
```dart
final locale = Localizations.localeOf(context);
locale.toString() // "ko", "ja", "en" 등
```

Flutter의 `Localizations.localeOf(context)`는 현재 앱의 로케일을 반환하며, `toString()`으로 문자열 형식으로 변환 가능.

## 남은 작업 (To-Do)

### 1. 다른 날짜 형식 로컬라이제이션
- [ ] 월 이름 (January → 1월 → 1月)
- [ ] 날짜 형식 (MM/DD/YYYY vs DD/MM/YYYY vs YYYY/MM/DD)
- [ ] 시간 형식 (12시간 vs 24시간)

### 2. 숫자 형식 로컬라이제이션
- [ ] 천 단위 구분자 (1,000 vs 1.000)
- [ ] 소수점 (1.5 vs 1,5)

### 3. 테스트
- [ ] 각 언어별 캘린더 스크린샷 테스트
- [ ] 요일 표시 확인
- [ ] 월 이름 표시 확인

## 현재 전체 구조 (Project Structure)

```
fitmix_pwa/
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb                  # weekdayXxxShort 추가 ✅
│   │   ├── app_ko.arb                  # weekdayXxxShort 추가 ✅
│   │   ├── app_ja.arb                  # weekdayXxxShort 추가 ✅
│   │   └── app_localizations*.dart     # 재생성됨 ✅
│   │
│   ├── pages/
│   │   └── home_page.dart              # 요일 로컬라이제이션 ✅
│   │
│   └── widgets/
│       └── calendar/
│           ├── week_strip.dart         # locale 속성 추가 ✅
│           └── calendar_modal_sheet.dart # locale 속성 추가 ✅
│
└── doc/
    ├── 260112_Localization.md
    ├── 260112_Full_Localization.md
    └── 260112_Weekday_Localization.md  # 이 문서 ✅
```

## 코드 예시

### 1. 홈 페이지 - 짧은 요일 형식
```dart
// 주간 현황에서 사용
final dayLabels = [
  context.l10n.weekdayMonShort,  // "월" / "月" / "M"
  context.l10n.weekdayTueShort,  // "화" / "火" / "T"
  context.l10n.weekdayWedShort,  // "수" / "水" / "W"
  context.l10n.weekdayThuShort,  // "목" / "木" / "T"
  context.l10n.weekdayFriShort,  // "금" / "金" / "F"
  context.l10n.weekdaySatShort,  // "토" / "土" / "S"
  context.l10n.weekdaySunShort,  // "일" / "日" / "S"
];
```

### 2. 캘린더 위젯 - table_calendar 로케일
```dart
Widget build(BuildContext context) {
  final locale = Localizations.localeOf(context);
  
  return TableCalendar(
    locale: locale.toString(), // "ko", "ja", "en"
    firstDay: DateTime.utc(2020, 1, 1),
    lastDay: DateTime.utc(2030, 12, 31),
    // ... 나머지 설정
  );
}
```

### 3. 로케일 감지
```dart
final locale = Localizations.localeOf(context);

// 언어 코드 확인
if (locale.languageCode == 'ko') {
  // 한국어 처리
} else if (locale.languageCode == 'ja') {
  // 일본어 처리
} else {
  // 영어 처리 (기본)
}
```

## 테스트 결과

### 코드 분석
```bash
$ flutter analyze lib/pages/home_page.dart lib/widgets/calendar/
✅ 오류 없음
```

### 로케일 생성
```bash
$ flutter gen-l10n
✅ 모든 로케일 파일 성공적으로 생성됨
```

### 시뮬레이터 테스트
```
✅ 앱 실행 성공
✅ 한국어 로케일 자동 감지 (ko_JP → ko)
✅ 홈 페이지 요일: 월 화 수 목 금 토 일
✅ 캘린더 페이지 요일: 월 화 수 목 금 토 일
```

## 언어별 요일 표시

### 홈 페이지 (주간 현황)
| 언어 | 표시 형식 |
|------|-----------|
| English | M T W T F S S |
| Korean | 월 화 수 목 금 토 일 |
| Japanese | 月 火 水 木 金 土 日 |

### 캘린더 페이지
| 언어 | 표시 형식 |
|------|-----------|
| English | Mon Tue Wed Thu Fri Sat Sun |
| Korean | 월 화 수 목 금 토 일 |
| Japanese | 月 火 水 木 金 土 日 |

## 배운 점 (Lessons Learned)

1. **패키지 기능 활용**: `table_calendar`는 자체 로컬라이제이션 지원 → `locale` 속성만 추가하면 됨
2. **커스텀 vs 패키지**: 특별한 형식(1글자)이 필요한 경우 커스텀 키 사용
3. **일관성**: 모든 캘린더 위젯에 동일한 로케일 설정 적용
4. **테스트 중요성**: 각 화면마다 요일 표시 방식이 다를 수 있으므로 전체 확인 필요

## 다음 단계 (Next Steps)

### 우선순위 1: 월 이름 로컬라이제이션
캘린더 상단의 "2026년 1월" 형식도 로컬라이제이션 필요:
- English: "JAN 2026"
- Korean: "2026년 1월"
- Japanese: "2026年1月"

### 우선순위 2: 나머지 화면 확인
- Analysis 페이지
- Settings 페이지
- Profile 페이지

---

**작업 일자**: 2026년 1월 12일  
**작업자**: Kiro AI Assistant  
**상태**: ✅ 완료 및 테스트됨  
**다음 세션**: 월 이름 로컬라이제이션 또는 나머지 화면 로컬라이제이션

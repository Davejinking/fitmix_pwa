# YouTube 스타일 하단 네비게이션 구현 완료

## 개요
FitMix PS0 프로젝트의 하단 네비게이션을 YouTube 스타일로 변경했습니다. Material Icons의 outline/filled 형태를 사용하여 선택 상태를 명확하게 표시합니다.

## 구현 내용

### 1. FMBottomNav 위젯 개선

**파일:** `lib/widgets/common/fm_bottom_nav.dart`

**주요 변경사항:**
- SVG 아이콘 지원 제거
- Material Icons의 outline/filled 형태 지원
- `icon` (비활성) / `activeIcon` (활성) 구분
- YouTube 스타일 다크 테마 적용

**스타일 설정:**
```dart
selectedItemColor: Colors.white
unselectedItemColor: Colors.white70
backgroundColor: Color(0xFF1F1F1F) // 다크 그레이
type: BottomNavigationBarType.fixed
```

### 2. 탭별 아이콘 구성

| 탭 | 비활성 아이콘 | 활성 아이콘 |
|---|---|---|
| 홈 | `Icons.home_outlined` | `Icons.home` |
| 캘린더 | `Icons.calendar_month_outlined` | `Icons.calendar_month` |
| 라이브러리 | `Icons.list_alt_outlined` | `Icons.list_alt` |
| 분석 | `Icons.analytics_outlined` | `Icons.analytics` |

### 3. ShellPage 적용

**파일:** `lib/pages/shell_page.dart`

```dart
bottomNavigationBar: FMBottomNav(
  currentIndex: _currentIndex,
  onTap: onItemTapped,
  items: [
    FMBottomNavItem(
      label: context.l10n.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    FMBottomNavItem(
      label: context.l10n.calendar,
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
    ),
    FMBottomNavItem(
      label: context.l10n.library,
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
    ),
    FMBottomNavItem(
      label: context.l10n.analysis,
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
    ),
  ],
),
```

## UI 변경사항

### Before (이전)
- SVG 아이콘 사용
- 흰색 배경
- 파란색 선택 색상

### After (현재)
- Material Icons outline/filled
- 다크 그레이 배경 (#1F1F1F)
- 흰색/반투명 흰색 아이콘
- YouTube 스타일 디자인

## 레이아웃 설명

```
┌─────────────────────────────────┐
│                                 │
│         Page Content            │
│      (IndexedStack)             │
│                                 │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│  🏠    📅    📋    📊          │ ← BottomNavigationBar
│ ホーム カレンダー ライブラリ 分析 │   (다크 그레이 배경)
└─────────────────────────────────┘
```

**특징:**
- 선택된 탭: filled 아이콘 + 흰색
- 비선택 탭: outlined 아이콘 + 반투명 흰색
- 모든 페이지에서 공통 적용
- IndexedStack으로 탭 상태 보존

## 코드 품질

```bash
flutter analyze
```

**결과:**
- ✅ 에러 없음
- ✅ 경고 없음

## FMBottomNavItem 클래스

```dart
class FMBottomNavItem {
  final String label;        // 탭 라벨
  final IconData icon;       // 비활성 아이콘 (outlined)
  final IconData activeIcon; // 활성 아이콘 (filled)

  FMBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
```

## 커스터마이징 옵션

FMBottomNav는 다음 파라미터로 커스터마이징 가능:

```dart
FMBottomNav(
  currentIndex: _currentIndex,
  onTap: onItemTapped,
  items: [...],
  selectedItemColor: Colors.white,      // 선택 색상 (옵션)
  unselectedItemColor: Colors.white70,  // 비선택 색상 (옵션)
  backgroundColor: Color(0xFF1F1F1F),   // 배경색 (옵션)
)
```

## 장점

1. **명확한 선택 상태** - outline/filled로 현재 탭 명확히 표시
2. **Material Design 준수** - Material Icons 사용
3. **YouTube 스타일** - 익숙한 UX 패턴
4. **유지보수 용이** - SVG 파일 관리 불필요
5. **일관된 디자인** - 모든 플랫폼에서 동일한 아이콘

## 향후 개선 가능 사항

- [ ] 라이트 테마 지원 (배경색 자동 전환)
- [ ] 아이콘 크기 커스터마이징
- [ ] 애니메이션 효과 추가
- [ ] 뱃지 알림 기능

## 결론

YouTube 스타일의 하단 네비게이션이 성공적으로 구현되었습니다. Material Icons의 outline/filled 형태를 사용하여 직관적이고 세련된 UI를 제공합니다.

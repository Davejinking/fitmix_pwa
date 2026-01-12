# Iron Log - Localization Usage Examples

## 🌍 Quick Start Guide

### Basic Usage Pattern

```dart
// Import the extension (already imported in most files)
import '../core/l10n_extensions.dart';

// Use in your widget
Text(context.l10n.weeklyStatus.toUpperCase())
```

---

## 📝 Common Patterns

### 1. Simple Text Display
```dart
// Static text
Text(
  context.l10n.exercises.toUpperCase(),
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    fontFamily: 'Courier',
    letterSpacing: 1.5,
  ),
)
```

### 2. Conditional Text
```dart
// Different text based on state
Text(
  isCompleted 
    ? context.l10n.sessionComplete.toUpperCase() 
    : context.l10n.sessionReady.toUpperCase(),
  style: TextStyle(
    color: isCompleted ? Colors.white : Colors.grey[700],
  ),
)
```

### 3. Button Labels
```dart
ElevatedButton(
  onPressed: () => _startWorkout(),
  child: Text(
    context.l10n.initiateWorkout.toUpperCase(),
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
      fontFamily: 'Courier',
    ),
  ),
)
```

### 4. Filter Chips
```dart
FilterChip(
  label: Text(
    context.l10n.push.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      fontFamily: 'Courier',
    ),
  ),
  selected: isSelected,
  onSelected: (value) => _onFilterSelected(value),
)
```

---

## 🎯 Real-World Examples

### Home Page - Weekly Status
```dart
Widget _buildWeeklyCalendar() {
  return FutureBuilder<Set<String>>(
    future: _getWorkoutDates(),
    builder: (context, snapshot) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with localization
          Text(
            context.l10n.weeklyStatus.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey[700],
              fontFamily: 'Courier',
              letterSpacing: 2.0,
            ),
          ),
          // ... rest of widget
        ],
      );
    },
  );
}
```

### Home Page - Main Action Button
```dart
Widget _buildMainActionCard() {
  return FutureBuilder<Session?>(
    future: _getTodaySession(),
    builder: (context, snapshot) {
      final todaySession = snapshot.data;
      final isRest = todaySession?.isRest ?? false;
      
      if (isRest) {
        return Text(
          context.l10n.statusResting.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
            fontFamily: 'Courier',
            letterSpacing: 2.0,
          ),
        );
      }
      
      return ElevatedButton(
        onPressed: () => _initiateWorkout(),
        child: Text(
          context.l10n.initiateWorkout.toUpperCase(),
        ),
      );
    },
  );
}
```

### Library Page - Toggle Switch
```dart
Widget _buildTacticalSwitch(AppLocalizations l10n) {
  return Container(
    child: Row(
      children: [
        // Routines Tab
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isRoutineMode = true),
            child: Text(
              l10n.routines.toUpperCase(),
              style: TextStyle(
                color: _isRoutineMode ? Colors.black : Colors.grey,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        // Exercises Tab
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isRoutineMode = false),
            child: Text(
              l10n.exercises.toUpperCase(),
              style: TextStyle(
                color: !_isRoutineMode ? Colors.black : Colors.grey,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## 🔧 Advanced Patterns

### 1. Parameterized Strings
```dart
// In ARB file
{
  "exerciseCount": "{count} exercises",
  "@exerciseCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}

// In Dart code
Text(context.l10n.exerciseCount(5))  // "5 exercises"
```

### 2. Plural Forms
```dart
// In ARB file
{
  "workoutDays": "{count, plural, =0{No workouts} =1{1 workout} other{{count} workouts}}",
  "@workoutDays": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}

// In Dart code
Text(context.l10n.workoutDays(workoutCount))
```

### 3. Date Formatting
```dart
// Using intl package with localization
import 'package:intl/intl.dart';

String formatDate(DateTime date, BuildContext context) {
  final locale = Localizations.localeOf(context);
  final formatter = DateFormat.yMMMd(locale.toString());
  return formatter.format(date);
}

// Usage
Text(formatDate(DateTime.now(), context))
// English: "Jan 12, 2026"
// Korean: "2026년 1월 12일"
// Japanese: "2026年1月12日"
```

---

## 🎨 Styling Best Practices

### 1. Uppercase for Tactical Feel
```dart
// Always use .toUpperCase() for main labels
Text(context.l10n.weeklyStatus.toUpperCase())  // "WEEKLY STATUS"
```

### 2. Courier Font for Noir Aesthetic
```dart
Text(
  context.l10n.initiateWorkout.toUpperCase(),
  style: const TextStyle(
    fontFamily: 'Courier',
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  ),
)
```

### 3. Color Hierarchy
```dart
// High emphasis (white)
Text(
  context.l10n.sessionComplete.toUpperCase(),
  style: const TextStyle(color: Colors.white),
)

// Medium emphasis (grey[700])
Text(
  context.l10n.weeklyStatus.toUpperCase(),
  style: TextStyle(color: Colors.grey[700]),
)

// Low emphasis (grey[600])
Text(
  context.l10n.exercises.toUpperCase(),
  style: TextStyle(color: Colors.grey[600]),
)
```

---

## 🚫 Common Mistakes to Avoid

### ❌ DON'T: Hardcode strings
```dart
// BAD
Text('WEEKLY STATUS')
Text('운동 시작')
Text('ワークアウト開始')
```

### ✅ DO: Use localization
```dart
// GOOD
Text(context.l10n.weeklyStatus.toUpperCase())
```

### ❌ DON'T: Store uppercase in ARB
```json
// BAD
{
  "weeklyStatus": "WEEKLY STATUS"
}
```

### ✅ DO: Store normal case, transform in UI
```json
// GOOD
{
  "weeklyStatus": "Weekly Status"
}
```
```dart
// Transform in UI
Text(context.l10n.weeklyStatus.toUpperCase())
```

### ❌ DON'T: Mix languages
```dart
// BAD
Text('PUSH')  // English
Text('하체')  // Korean
Text('PULL')  // English
```

### ✅ DO: Use consistent localization
```dart
// GOOD
Text(context.l10n.push.toUpperCase())
Text(context.l10n.legs.toUpperCase())
Text(context.l10n.pull.toUpperCase())
```

---

## 🧪 Testing Localization

### 1. Test Different Locales
```dart
// In main.dart
MaterialApp(
  locale: const Locale('ko'),  // Force Korean
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: HomePage(),
)
```

### 2. Check for Missing Keys
```dart
// This will throw an error if key doesn't exist
try {
  final text = context.l10n.myNewKey;
  print('Key exists: $text');
} catch (e) {
  print('Key missing: $e');
}
```

### 3. Test Long Text Overflow
```dart
// Use constraints to test overflow
Container(
  width: 100,
  child: Text(
    context.l10n.veryLongText,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
)
```

---

## 📚 Available Keys Reference

### Navigation & Tabs
- `home` - "Home" / "홈" / "ホーム"
- `calendar` - "Calendar" / "캘린더" / "カレンダー"
- `library` - "Library" / "라이브러리" / "ライブラリ"
- `analysis` - "Analysis" / "분석" / "分析"
- `settings` - "Settings" / "설정" / "設定"

### Actions
- `initiateWorkout` - "Initiate Workout" / "운동 시작" / "ワークアウト開始"
- `planWorkout` - "Plan Workout" / "운동 계획하기" / "ワークアウト計画"
- `startSession` - "Start Session" / "세션 시작" / "セッション開始"
- `editSession` - "Edit Session" / "세션 편집" / "セッション編集"
- `createRoutine` - "Create New Routine" / "새 루틴 만들기" / "新しいルーティンを作成"

### Labels
- `weeklyStatus` - "Weekly Status" / "주간 현황" / "週間ステータス"
- `monthlyGoal` - "Monthly Goal" / "월간 목표" / "月間目標"
- `exercises` - "Exercises" / "운동" / "エクササイズ"
- `routines` - "Routines" / "루틴" / "ルーティン"
- `workouts` - "Workouts" / "운동" / "ワークアウト"

### Status
- `sessionReady` - "Session Ready" / "세션 준비됨" / "セッション準備完了"
- `sessionComplete` - "Session Complete" / "세션 완료" / "セッション完了"
- `noActiveSession` - "No Active Session" / "활성 세션 없음" / "アクティブセッションなし"
- `statusResting` - "Status: Resting" / "상태: 휴식 중" / "ステータス: 休息中"

### Filters
- `all` - "All" / "전체" / "全て"
- `push` - "Push" / "밀기" / "プッシュ"
- `pull` - "Pull" / "당기기" / "プル"
- `legs` - "Legs" / "하체" / "下半身"
- `upper` - "Upper" / "상체" / "上半身"
- `lower` - "Lower" / "하체" / "下半身"
- `fullBody` - "Full Body" / "전신" / "全身"

---

## 🔄 Migration Guide

### Converting Existing Code

**Before:**
```dart
Text('WEEKLY STATUS')
```

**After:**
```dart
Text(context.l10n.weeklyStatus.toUpperCase())
```

**Before:**
```dart
ElevatedButton(
  child: Text('INITIATE WORKOUT'),
  onPressed: () => _start(),
)
```

**After:**
```dart
ElevatedButton(
  child: Text(context.l10n.initiateWorkout.toUpperCase()),
  onPressed: () => _start(),
)
```

---

## 🎯 Quick Reference Card

```dart
// Basic usage
context.l10n.keyName

// With uppercase
context.l10n.keyName.toUpperCase()

// With parameters
context.l10n.keyName(value)

// Conditional
condition ? context.l10n.key1 : context.l10n.key2

// In AppLocalizations parameter
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return Text(l10n.keyName);
}
```

---

**Last Updated:** January 12, 2026  
**Supported Languages:** English, Korean, Japanese  
**Status:** ✅ Production Ready

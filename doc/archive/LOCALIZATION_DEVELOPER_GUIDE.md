# Iron Log - Localization Developer Guide

## 🌍 Quick Start

### 1. Import AppLocalizations
```dart
import '../l10n/app_localizations.dart';
```

### 2. Get Localization Instance
```dart
final l10n = AppLocalizations.of(context);
```

### 3. Use Localized Strings
```dart
Text(l10n.push)  // "Push" (EN), "밀기" (KR), "プッシュ" (JP)
```

---

## 📚 Available Localization Keys

### Filter & Category Keys
```dart
l10n.all        // "All" / "전체" / "全て"
l10n.push       // "Push" / "밀기" / "プッシュ"
l10n.pull       // "Pull" / "당기기" / "プル"
l10n.legs       // "Legs" / "하체" / "下半身"
l10n.upper      // "Upper" / "상체" / "上半身"
l10n.lower      // "Lower" / "하체" / "下半身"
l10n.fullBody   // "Full Body" / "전신" / "全身"
```

### Body Part Keys
```dart
l10n.chest      // "Chest" / "가슴" / "胸"
l10n.back       // "Back" / "등" / "背中"
l10n.shoulders  // "Shoulders" / "어깨" / "肩"
l10n.arms       // "Arms" / "팔" / "腕"
l10n.abs        // "Abs" / "복근" / "腹筋"
l10n.cardio     // "Cardio" / "유산소" / "有酸素"
```

### Equipment Keys
```dart
l10n.bodyweight // "Bodyweight" / "맨몸" / "自重"
l10n.barbell    // "Barbell" / "바벨" / "バーベル"
l10n.dumbbell   // "Dumbbell" / "덤벨" / "ダンベル"
l10n.machine    // "Machine" / "머신" / "マシン"
l10n.cable      // "Cable" / "케이블" / "ケーブル"
l10n.band       // "Band" / "밴드" / "バンド"
```

---

## 🎯 Common Use Cases

### 1. Filter Chips (Library Screen)
```dart
String _getRoutineFilterLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'all': return l10n.all;
    case 'push': return l10n.push.toUpperCase();
    case 'pull': return l10n.pull.toUpperCase();
    case 'legs': return l10n.legs.toUpperCase();
    case 'upper': return l10n.upper.toUpperCase();
    case 'lower': return l10n.lower.toUpperCase();
    case 'fullBody': return l10n.fullBody.toUpperCase();
    default: return key.toUpperCase(); // User-created tags
  }
}

// Usage
FilterChip(
  label: Text(_getRoutineFilterLabel(l10n, 'push')),
  // Displays: "PUSH" (EN), "밀기" (KR), "プッシュ" (JP)
)
```

### 2. Body Part Display
```dart
// In Exercise Card
Text(
  l10n.chest,
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
  ),
)
```

### 3. Button Labels
```dart
ElevatedButton(
  onPressed: () => _createRoutine(),
  child: Text(l10n.createRoutine.toUpperCase()),
  // Displays: "CREATE NEW ROUTINE" (EN)
  //           "새 루틴 만들기" (KR)
  //           "新しいルーティンを作成" (JP)
)
```

### 4. Parameterized Strings
```dart
// Exercise count
Text(l10n.exerciseCount(5))
// "5 exercises" (EN)
// "5개 운동" (KR)
// "5個の運動" (JP)

// Days completed
Text(l10n.daysCompleted(10, 20))
// "10/20 days completed" (EN)
// "10/20일 완료" (KR)
// "10/20日完了" (JP)
```

---

## 🔧 Adding New Localization Keys

### Step 1: Add to English ARB (Base)
**File:** `lib/l10n/app_en.arb`
```json
{
  "myNewKey": "My New Text",
  "@myNewKey": {
    "description": "Description of what this key is for"
  }
}
```

### Step 2: Add to Korean ARB
**File:** `lib/l10n/app_ko.arb`
```json
{
  "myNewKey": "내 새로운 텍스트"
}
```

### Step 3: Add to Japanese ARB
**File:** `lib/l10n/app_ja.arb`
```json
{
  "myNewKey": "私の新しいテキスト"
}
```

### Step 4: Generate Localization Files
```bash
flutter gen-l10n
```

### Step 5: Use in Code
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.myNewKey)
```

---

## 🎨 Styling Best Practices

### Uppercase Transformation
```dart
// For tactical/industrial feel
Text(l10n.push.toUpperCase())  // "PUSH"
```

### Courier Font (Monospace)
```dart
Text(
  l10n.routines.toUpperCase(),
  style: const TextStyle(
    fontFamily: 'Courier',
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
  ),
)
```

### Conditional Styling
```dart
Text(
  isSelected ? l10n.selected : l10n.notSelected,
  style: TextStyle(
    color: isSelected ? Colors.white : Colors.grey[600],
    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
  ),
)
```

---

## 🌐 Language Detection

### Automatic Detection
```dart
// Flutter automatically detects device language
// No manual configuration needed
```

### Manual Override (Testing)
```dart
MaterialApp(
  locale: const Locale('ko'), // Force Korean
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

### Get Current Locale
```dart
final locale = Localizations.localeOf(context);
print(locale.languageCode); // "en", "ko", or "ja"
```

---

## 🚫 Common Mistakes to Avoid

### ❌ DON'T: Hardcode Strings
```dart
// BAD
Text('Push')
Text('하체')
Text('プッシュ')
```

### ✅ DO: Use Localization
```dart
// GOOD
Text(l10n.push)
```

### ❌ DON'T: Mix Languages
```dart
// BAD
case 'push': return 'PUSH';
case 'legs': return '하체';
```

### ✅ DO: Use Consistent Keys
```dart
// GOOD
case 'push': return l10n.push.toUpperCase();
case 'legs': return l10n.legs.toUpperCase();
```

### ❌ DON'T: Forget to Regenerate
```dart
// After adding new keys to ARB files
// DON'T forget to run:
flutter gen-l10n
```

---

## 🔍 Debugging Localization

### Check Available Locales
```dart
print(AppLocalizations.supportedLocales);
// [Locale('en'), Locale('ko'), Locale('ja')]
```

### Verify Key Exists
```dart
try {
  final text = l10n.myKey;
  print('Key exists: $text');
} catch (e) {
  print('Key missing: $e');
}
```

### Test All Languages
```dart
// In main.dart
void main() {
  runApp(
    MaterialApp(
      locale: const Locale('en'), // Change to 'ko' or 'ja'
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    ),
  );
}
```

---

## 📦 File Structure

```
lib/
├── l10n/
│   ├── app_en.arb                    # English (Base)
│   ├── app_ko.arb                    # Korean
│   ├── app_ja.arb                    # Japanese
│   ├── app_localizations.dart        # Generated
│   ├── app_localizations_en.dart     # Generated
│   ├── app_localizations_ko.dart     # Generated
│   └── app_localizations_ja.dart     # Generated
└── ...

l10n.yaml                              # Configuration
```

---

## 🎯 Migration Checklist

### Converting Hardcoded Strings
1. ✅ Find hardcoded string: `'Push'`
2. ✅ Check if key exists: `l10n.push`
3. ✅ If not, add to ARB files
4. ✅ Run `flutter gen-l10n`
5. ✅ Replace: `Text('Push')` → `Text(l10n.push)`
6. ✅ Test in all languages

### Search for Hardcoded Strings
```bash
# Find Korean characters
grep -r "하체\|가슴\|등\|어깨" lib/

# Find English hardcoded strings
grep -r "\"Push\"\|\"Pull\"\|\"Legs\"" lib/
```

---

## 🚀 Production Checklist

- ✅ All ARB files have matching keys
- ✅ No hardcoded strings in UI
- ✅ `flutter gen-l10n` runs without errors
- ✅ Tested in all supported languages (EN, KR, JP)
- ✅ Fallback to English if translation missing
- ✅ No mixed language displays

---

## 📚 Resources

### Official Documentation
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)

### Iron Log Specific
- `LOCALIZATION_AND_UI_POLISH_COMPLETE.md` - Implementation summary
- `UI_POLISH_VISUAL_COMPARISON.md` - Visual changes
- `l10n.yaml` - Configuration file

---

**Last Updated:** January 12, 2026  
**Supported Languages:** English, Korean, Japanese  
**Status:** ✅ Production Ready

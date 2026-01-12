# Iron Log - Quick Reference Card

## 🚀 Quick Commands

```bash
# Generate localization files
flutter gen-l10n

# Analyze code
flutter analyze

# Run app
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## 🌍 Localization Quick Reference

### Get Localization Instance
```dart
final l10n = AppLocalizations.of(context);
```

### Common Keys
```dart
// Filters
l10n.all        // All / 전체 / 全て
l10n.push       // Push / 밀기 / プッシュ
l10n.pull       // Pull / 당기기 / プル
l10n.legs       // Legs / 하체 / 下半身
l10n.upper      // Upper / 상체 / 上半身
l10n.lower      // Lower / 하체 / 下半身
l10n.fullBody   // Full Body / 전신 / 全身

// Body Parts
l10n.chest      // Chest / 가슴 / 胸
l10n.back       // Back / 등 / 背中
l10n.shoulders  // Shoulders / 어깨 / 肩
l10n.arms       // Arms / 팔 / 腕
l10n.abs        // Abs / 복근 / 腹筋

// Actions
l10n.save       // Save / 저장 / 保存
l10n.cancel     // Cancel / 취소 / キャンセル
l10n.delete     // Delete / 삭제 / 削除
l10n.edit       // Edit / 수정 / 編集
```

---

## 🎨 Design System

### Colors
```dart
// Background
Colors.black                    // #000000

// Text
Colors.white                    // #FFFFFF (High emphasis)
Colors.grey[700]                // #616161 (Medium emphasis)
Colors.grey[600]                // #757575 (Low emphasis)

// Primary Action
Colors.grey[200]                // #EEEEEE (Button background)
Colors.black                    // #000000 (Button text)

// Accent
Color(0xFFFF0033)               // Iron Red
```

### Typography
```dart
TextStyle(
  fontFamily: 'Courier',        // Monospace
  fontWeight: FontWeight.w900,  // Bold
  letterSpacing: 1.5,           // Tactical spacing
  fontSize: 14,                 // Standard size
)
```

### Button Styles
```dart
// Primary (Filled)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[200],
    foregroundColor: Colors.black,
    elevation: 0,
  ),
)

// Secondary (Outlined)
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: BorderSide(color: Colors.white, width: 1.5),
  ),
)

// Tertiary (Text)
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Colors.white,
  ),
)
```

---

## 📁 File Locations

### Localization
```
lib/l10n/
├── app_en.arb              # English (Base)
├── app_ko.arb              # Korean
├── app_ja.arb              # Japanese
└── app_localizations.dart  # Generated
```

### Key Screens
```
lib/pages/
├── home_page.dart          # Home screen
├── library_page_v2.dart    # Library/Routines
├── calendar_page.dart      # Calendar
└── analysis_page.dart      # Analytics
```

### Widgets
```
lib/widgets/
├── workout_heatmap.dart    # Contribution graph
└── tactical_exercise_list.dart
```

---

## 🔧 Common Tasks

### Add New Localization Key
1. Add to `lib/l10n/app_en.arb`
2. Add to `lib/l10n/app_ko.arb`
3. Add to `lib/l10n/app_ja.arb`
4. Run `flutter gen-l10n`
5. Use: `l10n.yourNewKey`

### Change Button Style
```dart
// From Outlined to Filled
OutlinedButton(...) → ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[200],
    foregroundColor: Colors.black,
  ),
)
```

### Test Different Languages
```dart
// In main.dart
MaterialApp(
  locale: const Locale('ko'), // 'en', 'ko', or 'ja'
  ...
)
```

---

## 🐛 Troubleshooting

### Localization not working?
```bash
flutter gen-l10n
flutter clean
flutter pub get
```

### Missing translation?
- Check all ARB files have the same keys
- Verify key name matches exactly
- Run `flutter gen-l10n` again

### Button not showing correctly?
- Check `backgroundColor` and `foregroundColor`
- Verify `elevation: 0` for flat look
- Ensure `fontFamily: 'Courier'`

---

## 📊 Supported Languages

| Language | Code | Status |
|----------|------|--------|
| English  | en   | ✅ Complete |
| Korean   | ko   | ✅ Complete |
| Japanese | ja   | ✅ Complete |

---

## 🎯 Key Changes Made

### 1. Localization
- ✅ English set as base language
- ✅ Added push, pull, upper, lower keys
- ✅ Refactored library filter labels

### 2. UI Polish
- ✅ Changed "INITIATE WORKOUT" to filled button
- ✅ Improved visual hierarchy
- ✅ Maintained noir aesthetic

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| `IMPLEMENTATION_SUMMARY.md` | Overview of changes |
| `LOCALIZATION_DEVELOPER_GUIDE.md` | How to use l10n |
| `UI_POLISH_VISUAL_COMPARISON.md` | Before/after visuals |
| `LOCALIZATION_AND_UI_POLISH_COMPLETE.md` | Technical details |
| `QUICK_REFERENCE.md` | This file |

---

## ✅ Production Checklist

- ✅ All ARB files synced
- ✅ `flutter gen-l10n` runs successfully
- ✅ No hardcoded strings in UI
- ✅ Tested in all languages
- ✅ Button hierarchy clear
- ✅ Noir aesthetic maintained
- ✅ Code analysis passes

---

## 🚀 Launch Ready

**Status:** ✅ **PRODUCTION READY**

Iron Log is now fully localized and polished for:
- 🇺🇸 English market
- 🇰🇷 Korean market
- 🇯🇵 Japanese market

---

**Last Updated:** January 12, 2026  
**Version:** 1.0.0

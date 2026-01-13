# Rest Timer Redesign - Industrial/Tactical Aesthetic

> **Date**: 2026-01-14  
> **Status**: ✅ Completed  
> **Design Goal**: Transform generic kitchen timer into Iron Log noir identity

---

## Design Specifications Applied

### 1. Color Palette

| Element | Before | After |
|---------|--------|-------|
| Background | Gradient (#0A0A0A → #1A1A1A) | Solid Deep Dark (#121212) |
| Accent | Standard Blue (#2196F3) | Electric Cyan (#00E5FF) |
| Text | White (default) | White + Monospace (Courier) |
| Labels | Grey (#888) | Grey (#666) + Uppercase |

### 2. Timer Display ("The Clock")

**Before**:
- Thick rounded progress circle (strokeWidth: 8)
- Standard font (72pt, w700)
- No special effects

**After**:
- Thin sharp ring (strokeWidth: 4)
- Massive monospace typography (72pt Courier, w900)
- Cyan glow effect (Shadow with blur: 20, alpha: 0.5)
- "REST" label above timer
- Dark background box behind numbers

### 3. Control Buttons

**Before**:
```dart
// Circular soft buttons
Container(
  width: 64,
  height: 64,
  decoration: BoxDecoration(
    color: Colors.white.withAlpha(0.12),
    shape: BoxShape.circle, // ❌ Soft
  ),
  child: Text('-1분'),
)
```

**After**:
```dart
// Angular machine interface
Container(
  width: 72,
  height: 72,
  decoration: BoxDecoration(
    color: Color(0xFF2C2C2E), // Dark surface
    borderRadius: BorderRadius.circular(12), // ✅ Angular
    border: Border.all(
      color: Colors.white.withAlpha(0.1),
      width: 1,
    ),
  ),
  child: Text('-1M', // Concise
    style: TextStyle(
      fontFamily: 'Courier',
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

### 4. Primary Action Button

**Before**:
```dart
// Full-width filled blue button
Container(
  decoration: BoxDecoration(
    color: Color(0xFF2196F3), // ❌ Too distracting
    borderRadius: BorderRadius.circular(14),
  ),
  child: Text('휴식 건너뛰기'),
)
```

**After**:
```dart
// Outlined button with accent border
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Color(0xFF00E5FF), width: 2), // ✅ Subtle
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    foregroundColor: Color(0xFF00E5FF),
  ),
  child: Text(
    'SKIP', // Concise + Uppercase
    style: TextStyle(
      fontFamily: 'Courier',
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
    ),
  ),
)
```

---

## Visual Comparison

### Full Screen Timer

**Before**:
```
┌─────────────────────────────┐
│ [○ Close]                   │
│                             │
│        ╭─────────╮          │
│        │         │          │
│        │  01:29  │  ← Thick ring
│        │         │          │
│        ╰─────────╯          │
│                             │
│  (○)  (○)  (○)  (○)  ← Circles
│                             │
│ ┌─────────────────────────┐ │
│ │   휴식 건너뛰기 (Blue)  │ │ ← Filled
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**After**:
```
┌─────────────────────────────┐
│ [▢ Close]                   │
│                             │
│        ╭─────────╮          │
│        │  REST   │          │
│        │ ┌─────┐ │          │
│        │ │01:29│ │  ← Thin ring + Glow
│        │ └─────┘ │          │
│        ╰─────────╯          │
│                             │
│  [▢]  [▢]  [▢]  [▢]  ← Angular
│ -1M  -10  +10  +1M          │
│                             │
│ ┌─────────────────────────┐ │
│ │      SKIP (Cyan)        │ │ ← Outlined
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### Mini Timer (Bottom Bar)

**Before**:
```
┌─────────────────────────────┐
│ (○) REST      01:29    [○]  │
│                             │
│ [▢] [▢] [▢] [▢]  ← Rounded  │
│                             │
│ ┌─────────────────────────┐ │
│ │ 휴식 건너뛰기 (Blue)    │ │ ← Filled
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

**After**:
```
┌─────────────────────────────┐
│ (○) REST      01:29    [▢]  │
│                             │
│ [▢] [▢] [▢] [▢]  ← Angular  │
│ -1M -10 +10 +1M             │
│                             │
│ ┌─────────────────────────┐ │
│ │      SKIP (Cyan)        │ │ ← Outlined
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

---

## Technical Implementation

### Key Changes

1. **Accent Color Constant**:
   ```dart
   // Before
   const accentColor = Color(0xFF2196F3);
   
   // After
   const accentColor = Color(0xFF00E5FF); // Electric Cyan
   ```

2. **Background**:
   ```dart
   // Before
   decoration: BoxDecoration(
     gradient: LinearGradient(
       colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
     ),
   )
   
   // After
   color: Color(0xFF121212), // Solid deep dark
   ```

3. **Timer Typography**:
   ```dart
   // Before
   Text(
     _formatTime(_restSeconds),
     style: TextStyle(
       fontSize: 72,
       fontWeight: FontWeight.w700,
     ),
   )
   
   // After
   Text(
     _formatTime(_restSeconds),
     style: TextStyle(
       fontSize: 72,
       fontWeight: FontWeight.w900,
       fontFamily: 'Courier',
       letterSpacing: 4,
       shadows: [
         Shadow(
           color: Color(0xFF00E5FF).withAlpha(0.5),
           blurRadius: 20,
         ),
       ],
     ),
   )
   ```

4. **Button Shape**:
   ```dart
   // Before
   decoration: BoxDecoration(
     shape: BoxShape.circle,
   )
   
   // After
   decoration: BoxDecoration(
     borderRadius: BorderRadius.circular(12), // Angular
   )
   ```

5. **Button Labels**:
   ```dart
   // Before: '-1분', '-10초', '+10초', '+1분'
   // After:  '-1M',  '-10',   '+10',   '+1M'
   ```

---

## Design Rationale

### Why Electric Cyan?

- **High Contrast**: Stands out against deep dark background
- **Industrial Feel**: Common in tactical/military interfaces
- **Energy**: Conveys action and urgency
- **Noir Aesthetic**: Fits the cyberpunk/industrial theme

### Why Thin Ring?

- **Focus on Numbers**: Less visual weight on the ring
- **Precision**: Thin lines = precision instrument
- **Modern**: Minimalist approach
- **Performance**: Lighter rendering

### Why Angular Buttons?

- **Machine Interface**: Looks like control panel
- **Tactical**: Military/industrial equipment aesthetic
- **Consistency**: Matches the overall Iron Log design
- **Touch Target**: Still maintains good touch area

### Why Outlined Primary Button?

- **Less Distraction**: Doesn't dominate the screen
- **Sophistication**: More refined than filled button
- **Consistency**: Matches the End Workout button style
- **Focus**: Keeps attention on the timer

---

## Behavior Notes

### Auto-Popup Constraint

✅ **Implemented**: Timer does NOT auto-popup when set is checked
- Only appears when user taps "Rest Timer" in bottom bar
- User has full control over timer visibility
- Reduces interruption during workout

### Timer Visibility Toggle

- X button hides UI but timer continues running
- Timer value shows in bottom bar when hidden
- Tap bottom bar to show UI again

---

## Files Modified

- `lib/pages/active_workout_page.dart`
  - `_buildFullScreenTimerOverlay()`: Complete redesign
  - `_buildMiniFloatingTimer()`: Angular style applied
  - `_buildTacticalTimeButton()`: New angular button (was `_buildCircleTimeButton`)
  - `_buildMiniTimeButton()`: Updated styling

---

## Testing Checklist

- [x] Full screen timer displays correctly
- [x] Mini timer displays correctly
- [x] Time adjustment buttons work (-1M, -10, +10, +1M)
- [x] Skip button works
- [x] X button hides UI
- [x] Timer continues when UI hidden
- [x] Localization works (SKIP REST / 휴식 건너뛰기 / 休憩をスキップ)
- [x] Glow effect visible on timer numbers
- [x] Angular buttons have proper touch targets
- [x] No auto-popup on set completion

---

## Future Enhancements

### Optional: Industrial Amber Variant

Could add a setting to switch between:
- **Electric Cyan** (#00E5FF) - Default, energetic
- **Industrial Amber** (#FFC107) - Warmer, warning-like

### Optional: Sound Effects

- Mechanical "click" sound for button presses
- Industrial "beep" when timer completes
- Matches the tactical aesthetic

---

**Status**: ✅ Completed and Pushed  
**Commit**: `be6c42a`  
**Branch**: `main`

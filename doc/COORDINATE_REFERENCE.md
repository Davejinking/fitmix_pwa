# Equipment Slot Coordinate Reference

## Quick Adjustment Guide

### Understanding the Coordinate System

```
        -1.0 (TOP)
           ↑
           |
-1.0 ←─────┼─────→ +1.0
(LEFT)     |     (RIGHT)
           |
           ↓
        +1.0 (BOTTOM)
```

### Current Slot Positions

```dart
// TOP ROW (Above Character)
'head':     Alignment(-0.35, -0.78),  // Upper-left
'neck':     Alignment( 0.35, -0.78),  // Upper-right

// SIDE FLANKS (Around Character)
'mainHand': Alignment(-0.82, -0.25),  // Left upper (Weapon)
'offHand':  Alignment( 0.82, -0.25),  // Right upper (Shield)
'gloves':   Alignment(-0.82,  0.15),  // Left lower
'chest':    Alignment( 0.82,  0.15),  // Right lower (Armor)

// BOTTOM ROW (Below Character)
'legs':     Alignment(-0.25,  0.55),  // Bottom-left
'boots':    Alignment( 0.25,  0.55),  // Bottom-right
```

## Common Adjustments

### Move Slot RIGHT
```dart
// Increase X value by 0.05
Alignment(-0.35, -0.78) → Alignment(-0.30, -0.78)
```

### Move Slot LEFT
```dart
// Decrease X value by 0.05
Alignment(0.35, -0.78) → Alignment(0.30, -0.78)
```

### Move Slot DOWN
```dart
// Increase Y value by 0.05
Alignment(-0.35, -0.78) → Alignment(-0.35, -0.73)
```

### Move Slot UP
```dart
// Decrease Y value by 0.05
Alignment(-0.35, -0.78) → Alignment(-0.35, -0.83)
```

## Fine-Tuning Tips

### Small Adjustments (±0.02 to ±0.05)
Use for minor alignment corrections when slots are close but not perfect.

```dart
// Example: Head slot slightly off to the right
Alignment(-0.35, -0.78) → Alignment(-0.33, -0.78)
```

### Medium Adjustments (±0.10 to ±0.20)
Use when slots are noticeably misaligned.

```dart
// Example: Weapon slot too far left
Alignment(-0.82, -0.25) → Alignment(-0.72, -0.25)
```

### Large Adjustments (±0.30+)
Use when completely repositioning a slot.

```dart
// Example: Moving from left side to right side
Alignment(-0.82, -0.25) → Alignment(0.82, -0.25)
```

## Visual Reference

```
┌─────────────────────────────────┐
│                                 │ -1.0
│    HEAD(-0.35)  NECK(0.35)      │ -0.78
│                                 │
│                                 │
│ WEAPON(-0.82)         🔥        │ -0.25
│                                 │
│      [CHARACTER]                │  0.0
│                                 │
│ GLOVES(-0.82)    ARMOR(0.82)    │  0.15
│                                 │
│                                 │
│   LEGS(-0.25)  BOOTS(0.25)      │  0.55
│                                 │
│                                 │
│  [INVENTORY GRID]               │  0.92
└─────────────────────────────────┘
-1.0              0.0           1.0
```

## Slot Size Reference

Current slot size: **70x70 pixels**

Adjust if needed:
```dart
_buildSlot(
  alignment: const Alignment(-0.35, -0.78),
  slotKey: 'head',
  size: 80, // Increase for larger hitbox
),
```

## Testing Checklist

- [ ] All slots visible on screen
- [ ] No slots overlapping
- [ ] Slots align with background image borders
- [ ] Touch targets are comfortable (not too small)
- [ ] Consistent spacing between slots
- [ ] Works on different screen sizes (test with AspectRatio)

## Device-Specific Notes

### iPhone SE (Small Screen)
- Slots may appear smaller but positions remain consistent
- Consider increasing slot size to 75-80px

### iPad (Tablet)
- Black letterbox bars on sides (expected)
- Positions remain perfectly aligned
- No adjustments needed

### Android Phones (Various Ratios)
- AspectRatio ensures consistent positioning
- Letterboxing handles different screen ratios
- Test on 18:9, 19:9, 20:9 screens

## Troubleshooting

### Slots drift on different devices
**Cause**: AspectRatio not applied or incorrect ratio
**Fix**: Ensure `AspectRatio(aspectRatio: 9/16)` wraps the Stack

### Slots don't match image
**Cause**: Image aspect ratio doesn't match 9:16
**Fix**: Resize image to exactly 9:16 ratio (e.g., 1080x1920)

### Slots too close to edges
**Cause**: Alignment values too extreme (close to ±1.0)
**Fix**: Reduce absolute values (e.g., -0.95 → -0.85)

### Inventory grid misaligned
**Cause**: Y-coordinate doesn't match image
**Fix**: Adjust in `_buildInventoryGrid()`:
```dart
Align(
  alignment: const Alignment(0, 0.88), // Try different values
  child: SizedBox(...),
)
```

## Export Format

When using the calibration tool, coordinates are exported as:

```dart
_buildSlot(
  alignment: const Alignment(-0.35, -0.78),
  slotKey: 'head',
  size: 70,
),
```

Copy this directly into `equipment_overlay_page.dart` in the Stack children.

## Best Practices

1. **Start with calibration tool** - Visual adjustment is faster
2. **Test on real device** - Emulator may have different aspect ratios
3. **Use debug grid** - Enable to see alignment zones
4. **Adjust in small increments** - ±0.05 at a time
5. **Document changes** - Note which coordinates you modified
6. **Test all slots** - Ensure no regressions when adjusting one slot

## Quick Copy-Paste Template

```dart
// Equipment Slots - Adjust coordinates as needed
_buildSlot(
  alignment: const Alignment(-0.35, -0.78),
  slotKey: 'head',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(0.35, -0.78),
  slotKey: 'neck',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(-0.82, -0.25),
  slotKey: 'mainHand',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(0.82, -0.25),
  slotKey: 'offHand',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(-0.82, 0.15),
  slotKey: 'gloves',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(0.82, 0.15),
  slotKey: 'chest',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(-0.25, 0.55),
  slotKey: 'legs',
  size: 70,
),
_buildSlot(
  alignment: const Alignment(0.25, 0.55),
  slotKey: 'boots',
  size: 70,
),
```

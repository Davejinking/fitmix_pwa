# Equipment Overlay System - Complete Implementation

## 🎯 What This Is

A **pixel-perfect equipment screen** implementation for Flutter that uses:
- A vertical background image (9:16 ratio) for all visual design
- Transparent interactive overlays positioned exactly over painted slots
- No code-drawn borders or backgrounds - the image does all the visual work

## 📦 What's Included

### Core Implementation Files

1. **`lib/pages/equipment_overlay_page.dart`**
   - Main equipment screen with overlay approach
   - Production-ready implementation
   - Includes inventory grid at bottom

2. **`lib/pages/equipment_calibration_page.dart`**
   - Interactive tool for fine-tuning slot positions
   - Drag-and-drop or slider-based adjustment
   - Export coordinates as code

3. **`lib/pages/equipment_demo_page.dart`**
   - Demo page to compare implementations
   - Quick access to all equipment screens
   - Setup instructions included

### Documentation Files

4. **`doc/EQUIPMENT_OVERLAY_GUIDE.md`**
   - Complete implementation guide
   - Coordinate system explanation
   - Troubleshooting section
   - Advanced customization examples

5. **`doc/COORDINATE_REFERENCE.md`**
   - Quick reference for coordinate adjustments
   - Visual diagrams
   - Common adjustment patterns
   - Copy-paste templates

6. **`doc/INTEGRATION_EXAMPLE.md`**
   - Step-by-step integration guide
   - Data model connection examples
   - Navigation patterns
   - Testing checklist

7. **`assets/images/EQUIPMENT_SETUP.md`**
   - Image requirements and specifications
   - Slot layout reference
   - Fine-tuning instructions

## 🚀 Quick Start (3 Steps)

### Step 1: Add Background Image

Place your vertical equipment background as:
```
assets/images/vertical_equipment_bg.jpg
```

**Requirements:**
- Aspect ratio: 9:16 (e.g., 1080x1920)
- Style: Dark Fantasy RPG with stone texture
- Format: JPG or PNG

### Step 2: Test the Layout

Navigate to the equipment screen:

```dart
import 'package:fitmix_pwa/pages/equipment_overlay_page.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentOverlayPage()),
);
```

### Step 3: Fine-Tune (If Needed)

Use the calibration tool:

```dart
import 'package:fitmix_pwa/pages/equipment_calibration_page.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentCalibrationPage()),
);
```

Drag slots to correct positions, then export coordinates.

## 📐 Coordinate System

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

### Default Slot Positions

| Slot | X | Y | Position |
|------|---|---|----------|
| Head | -0.35 | -0.78 | Upper-left |
| Neck | 0.35 | -0.78 | Upper-right |
| Main Hand | -0.82 | -0.25 | Left upper flank |
| Off Hand | 0.82 | -0.25 | Right upper flank |
| Gloves | -0.82 | 0.15 | Left lower flank |
| Chest | 0.82 | 0.15 | Right lower flank |
| Legs | -0.25 | 0.55 | Bottom-left |
| Boots | 0.25 | 0.55 | Bottom-right |

## 🎨 Key Features

### 1. Pixel-Perfect Alignment
- AspectRatio widget locks layout to 9:16
- Coordinates never drift across devices
- Consistent on all screen sizes

### 2. Clean Separation
- **Image**: Handles all visual design (borders, textures, labels)
- **Code**: Handles only interaction and content (icons, taps)

### 3. Easy Customization
- Adjust coordinates with visual tool
- Change icon colors for different themes
- Modify slot sizes independently

### 4. Touch Feedback
- InkWell ripple effects (gold color)
- Empty slots show subtle "+" hint
- Smooth navigation to inventory

### 5. Responsive Design
- Black letterbox bars on non-9:16 screens
- Perfect fit on most phones
- No device-specific code needed

## 🎯 Design Principles

### CPO's Advice (Icon Colors)

Background is dark with stone texture, so use:

✅ **Good Colors:**
- Gold: `Color(0xFFD4C5A0)` or `Color(0xFFC7B377)`
- Amber: `Colors.amber.shade300`
- Light Grey: `Colors.grey.shade300`

❌ **Avoid:**
- Black or dark grey (invisible)
- Brown (poor contrast)

### Visual Hierarchy

```
┌─────────────────────────────────┐
│  [HEAD]      [NECK]             │ <- Top row
│                                 │
│ [WEAPON]  [CHARACTER]  🔥       │ <- Flanks + torches
│                                 │
│ [GLOVES]   [BODY]   [ARMOR]     │ <- Mid section
│                                 │
│  [LEGS]      [BOOTS]            │ <- Bottom row
│                                 │
│ [INVENTORY GRID - 8 SLOTS]      │ <- Quick items
└─────────────────────────────────┘
```

## 🔧 Customization Examples

### Change Accent Color

```dart
// In equipment_overlay_page.dart
splashColor: const Color(0xFF2196F3).withValues(alpha: 0.3), // Blue
```

### Adjust Slot Size

```dart
_buildSlot(
  alignment: const Alignment(-0.35, -0.78),
  slotKey: 'head',
  size: 80, // Increased from 70
),
```

### Add Rarity Glow

```dart
Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.amber.withValues(alpha: 0.5),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  ),
  child: Icon(...),
)
```

## 📱 Testing

### Devices to Test

- [ ] iPhone SE (small screen)
- [ ] iPhone 14 Pro (standard)
- [ ] iPad (tablet - letterboxing)
- [ ] Android phone (various ratios)
- [ ] Android tablet

### What to Check

- [ ] All slots visible
- [ ] Slots align with image
- [ ] Touch targets work
- [ ] No overlapping
- [ ] Smooth animations
- [ ] Performance is good

## 🐛 Common Issues

### Issue: Image not found
**Solution:**
```bash
flutter clean
flutter pub get
# Restart app (not hot reload)
```

### Issue: Slots don't align
**Solution:** Use calibration tool to adjust coordinates

### Issue: Hitboxes shift on different devices
**Solution:** Verify AspectRatio(9/16) wraps the Stack

### Issue: Icons too dark
**Solution:** Use light colors (gold, amber, white)

## 📚 Documentation Structure

```
doc/
├── EQUIPMENT_OVERLAY_README.md      (This file - Overview)
├── EQUIPMENT_OVERLAY_GUIDE.md       (Complete guide)
├── COORDINATE_REFERENCE.md          (Quick reference)
└── INTEGRATION_EXAMPLE.md           (Integration steps)

assets/images/
└── EQUIPMENT_SETUP.md               (Image setup)

lib/pages/
├── equipment_overlay_page.dart      (Main implementation)
├── equipment_calibration_page.dart  (Calibration tool)
└── equipment_demo_page.dart         (Demo/comparison)
```

## 🎓 Learning Path

### For First-Time Users

1. Read this README (you are here!)
2. Add background image
3. Run demo page to see it in action
4. Read INTEGRATION_EXAMPLE.md
5. Integrate into your app

### For Customization

1. Read EQUIPMENT_OVERLAY_GUIDE.md
2. Use calibration tool
3. Read COORDINATE_REFERENCE.md
4. Adjust as needed

### For Troubleshooting

1. Check EQUIPMENT_OVERLAY_GUIDE.md troubleshooting section
2. Verify image setup in EQUIPMENT_SETUP.md
3. Review COORDINATE_REFERENCE.md for alignment issues

## 💡 Pro Tips

1. **Always use calibration tool first** - Visual adjustment is faster than manual
2. **Test on real device** - Emulator may have different aspect ratios
3. **Enable debug grid** - Helps visualize alignment zones
4. **Adjust in small increments** - ±0.05 at a time
5. **Remove debug code** - Before production (hitbox borders, grid)

## 🔄 Migration from DiabloStatusPage

If you're replacing the existing equipment screen:

```dart
// Old
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const DiabloStatusPage()),
);

// New
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentOverlayPage()),
);
```

Both can coexist during transition. Use `equipment_demo_page.dart` to compare.

## 📊 Performance

- **Image Loading**: Cached automatically by Flutter
- **Overlay Widgets**: Minimal (8 equipment + 8 inventory slots)
- **Rebuild Optimization**: Only selected slot rebuilds
- **Memory**: Single background image loaded once
- **Frame Rate**: 60 FPS on most devices

## 🎯 Next Steps

1. **Add your background image** to `assets/images/`
2. **Run the demo page** to see all implementations
3. **Use calibration tool** to fine-tune positions
4. **Integrate with your data model**
5. **Test on multiple devices**
6. **Remove debug code**
7. **Deploy!**

## 📞 Support

For questions or issues:
1. Check the troubleshooting sections in the guides
2. Review the coordinate reference for alignment issues
3. Use the calibration tool to visually debug
4. Refer to integration examples for data model connection

## 🎉 Summary

This implementation provides:
- ✅ Pixel-perfect alignment with background image
- ✅ Consistent behavior across all devices
- ✅ Easy coordinate adjustment with visual tool
- ✅ Clean separation of design (image) and logic (code)
- ✅ Smooth touch interactions with visual feedback
- ✅ Dark fantasy aesthetic with proper icon visibility
- ✅ Production-ready code with comprehensive documentation

**The key insight:** Let the image do the visual work, code handles the interaction.

---

**Created for:** Iron Log - Gamified Workout Tracking App  
**Style:** Dark Fantasy RPG (Diablo-inspired)  
**Approach:** Image Overlay with Transparent Interactive Widgets  
**Aspect Ratio:** 9:16 (Vertical/Portrait)

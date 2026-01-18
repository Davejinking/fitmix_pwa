# Equipment Overlay - Quick Start Guide

## ⚡ 5-Minute Setup

### 1. Add Background Image (1 min)

Save your vertical equipment background (9:16 ratio) as:
```
assets/images/vertical_equipment_bg.jpg
```

### 2. Test It (2 min)

Add this to any button or navigation in your app:

```dart
import 'package:fitmix_pwa/pages/equipment_overlay_page.dart';

// In your onPressed or onTap:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentOverlayPage()),
);
```

Run the app and tap the button!

### 3. Fine-Tune (2 min - Optional)

If slots don't align perfectly with your image:

```dart
import 'package:fitmix_pwa/pages/equipment_calibration_page.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentCalibrationPage()),
);
```

- Drag slots to correct positions
- Tap code icon (</>) to export
- Copy coordinates to `equipment_overlay_page.dart`

## ✅ Done!

You now have a pixel-perfect equipment screen!

## 📚 Need More Details?

See comprehensive documentation:
- `doc/EQUIPMENT_OVERLAY_README.md` - Complete overview
- `doc/EQUIPMENT_OVERLAY_GUIDE.md` - Detailed guide
- `doc/INTEGRATION_EXAMPLE.md` - Integration examples
- `doc/COORDINATE_REFERENCE.md` - Coordinate adjustments

## 🎨 Current Slot Positions

```dart
Head:      Alignment(-0.35, -0.78)  // Upper-left
Neck:      Alignment( 0.35, -0.78)  // Upper-right
Main Hand: Alignment(-0.82, -0.25)  // Left upper (Weapon)
Off Hand:  Alignment( 0.82, -0.25)  // Right upper (Shield)
Gloves:    Alignment(-0.82,  0.15)  // Left lower
Chest:     Alignment( 0.82,  0.15)  // Right lower (Armor)
Legs:      Alignment(-0.25,  0.55)  // Bottom-left
Boots:     Alignment( 0.25,  0.55)  // Bottom-right
```

## 🐛 Troubleshooting

**Image not loading?**
```bash
flutter clean
flutter pub get
# Restart app (not hot reload)
```

**Slots misaligned?**
- Use calibration tool
- Check image is exactly 9:16 ratio

**Icons too dark?**
- Use light colors: `Color(0xFFD4C5A0)` (gold)

## 🎯 Key Features

- ✅ Pixel-perfect alignment
- ✅ Works on all screen sizes
- ✅ Touch feedback (ripple effect)
- ✅ Empty slot hints
- ✅ Bottom inventory grid
- ✅ Easy to customize

## 🔄 Next Steps

1. **Integrate with your data model** (see INTEGRATION_EXAMPLE.md)
2. **Customize colors and sizes** (see EQUIPMENT_OVERLAY_GUIDE.md)
3. **Add item interactions** (equip, unequip, details)
4. **Test on multiple devices**
5. **Remove debug code** before production

---

**That's it!** You're ready to go. 🚀

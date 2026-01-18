# Equipment Overlay Implementation Guide

## 📋 Overview

This implementation uses a **pixel-perfect overlay approach** where:
1. A vertical background image (9:16 ratio) provides the visual design
2. Transparent interactive widgets are positioned exactly over the painted slots
3. No borders or backgrounds are drawn in code - the image handles all visuals

## 🎨 Design Philosophy

**"The Image IS the Design"**
- Background image contains all visual elements (stone texture, borders, torches, labels)
- Flutter code only handles interaction and content (icons, tap handlers)
- AspectRatio widget locks the layout to prevent coordinate drift across devices

## 📁 Files Created

### 1. `lib/pages/equipment_overlay_page.dart`
The main equipment screen implementation.

**Key Features:**
- AspectRatio(9/16) wrapper ensures consistent hitbox positions
- Transparent InkWell widgets for touch feedback
- Gold/light colored icons for visibility on dark background
- Empty slots show subtle "+" hint icon
- Bottom inventory grid overlay (8 quick slots)

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentOverlayPage()),
);
```

### 2. `lib/pages/equipment_calibration_page.dart`
Interactive tool for fine-tuning slot positions.

**Features:**
- Drag slots to adjust positions
- Sliders for precise X/Y coordinate control
- Toggle debug grid overlay
- Export coordinates as code
- Real-time visual feedback

**Usage:**
```dart
// For development only - remove before production
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentCalibrationPage()),
);
```

### 3. `assets/images/EQUIPMENT_SETUP.md`
Instructions for adding the background image.

## 🖼️ Background Image Setup

### Step 1: Add Your Image

Place your vertical equipment background as:
```
assets/images/vertical_equipment_bg.jpg
```

### Step 2: Image Requirements

- **Aspect Ratio**: 9:16 (portrait/vertical)
- **Recommended Resolution**: 1080x1920 or higher
- **Style**: Dark Fantasy RPG (stone walls, torches, medieval aesthetic)
- **Format**: JPG or PNG

### Step 3: Slot Layout

Your image should have equipment slots at these positions:

```
┌─────────────────┐
│  [HEAD] [NECK]  │  <- Top row
│                 │
│ [WEAPON]   [🔥] │  <- Torches for atmosphere
│    [BODY]       │  <- Central character silhouette
│ [GLOVES] [ARMOR]│
│                 │
│  [LEGS] [BOOTS] │  <- Bottom row
│                 │
│ [INVENTORY GRID]│  <- 8 quick slots
└─────────────────┘
```

## 🎯 Coordinate System

### Alignment Values

Flutter's Alignment system:
- **X-axis**: -1.0 (left edge) to 1.0 (right edge)
- **Y-axis**: -1.0 (top edge) to 1.0 (bottom edge)
- **Center**: (0.0, 0.0)

### Current Coordinates

Based on the provided image layout:

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

## 🔧 Fine-Tuning Process

### Method 1: Using Calibration Tool (Recommended)

1. Run the calibration page:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentCalibrationPage()),
);
```

2. Tap a slot to select it
3. Drag it to the correct position OR use sliders
4. Tap the code icon (</>) to export coordinates
5. Copy the generated code to `equipment_overlay_page.dart`

### Method 2: Manual Adjustment

1. Enable debug mode in `equipment_overlay_page.dart`:
```dart
// In _buildSlot method, uncomment:
decoration: BoxDecoration(
  color: Colors.red.withValues(alpha: 0.3),
  border: Border.all(color: Colors.yellow, width: 1),
),
```

2. Run the app and visually check alignment
3. Adjust coordinates by ±0.05 increments:
```dart
_buildSlot(
  alignment: const Alignment(-0.30, -0.78), // Moved right from -0.35
  slotKey: 'head',
  size: 70,
),
```

4. Hot reload and repeat until perfect

## 🎨 Icon Color Guidelines

**CPO's Advice**: The background is dark with stone texture, so:

### Recommended Colors

```dart
// Equipped items - High visibility
color: const Color(0xFFD4C5A0), // Gold/Antique White

// Alternative options:
color: const Color(0xFFC7B377), // Darker Gold
color: const Color(0xFFFFD700), // Bright Gold
color: Colors.amber.shade300,   // Amber Gold
```

### Colors to AVOID

```dart
// ❌ Too dark - will be invisible
color: Colors.black,
color: Colors.grey.shade800,

// ❌ Poor contrast
color: Colors.brown,
color: const Color(0xFF5A4F45),
```

### Empty Slot Hints

```dart
// Subtle hint for empty slots
color: const Color(0xFF6A5F55).withValues(alpha: 0.5),
```

## 📱 Responsive Behavior

### How AspectRatio Works

```dart
AspectRatio(
  aspectRatio: 9 / 16, // Locks to this ratio
  child: Stack(...),
)
```

**On different screens:**
- **Wider screens** (tablets): Black letterbox bars on sides
- **Taller screens**: Black letterbox bars on top/bottom
- **9:16 screens** (most phones): Perfect fit, no letterboxing

**Why this matters:**
- Alignment coordinates remain consistent across all devices
- No need for responsive breakpoints or device-specific adjustments
- Hitboxes never drift from their visual positions

## 🔄 Integration with Existing Code

### Replace Current Equipment Screen

In your navigation code, replace:
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

### Data Integration

Update the `_equippedItems` map with your actual data model:

```dart
class _EquipmentOverlayPageState extends State<EquipmentOverlayPage> {
  // Replace this mock data
  final Map<String, IconData?> _equippedItems = {
    'head': Icons.face,
    'neck': Icons.circle_outlined,
    // ...
  };
  
  // With your actual equipment model
  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }
  
  Future<void> _loadEquipment() async {
    final equipment = await equipmentRepo.getUserEquipment();
    setState(() {
      _equippedItems = equipment.toIconMap();
    });
  }
}
```

## 🎮 Interaction Features

### Current Implementation

1. **Tap Feedback**: InkWell ripple effect (gold color)
2. **Empty Slots**: Show subtle "+" icon hint
3. **Equipped Items**: Display icon with shadow for depth
4. **Navigation**: Tap any slot → opens Inventory page

### Customization Options

```dart
// Change ripple color
splashColor: const Color(0xFFC7B377).withValues(alpha: 0.3),

// Change highlight color
highlightColor: const Color(0xFFC7B377).withValues(alpha: 0.1),

// Adjust icon size
size: size * 0.6, // 60% of slot size

// Add long-press handler
onLongPress: () => _showItemDetails(slotKey),
```

## 🐛 Troubleshooting

### Issue: Slots don't align with image

**Solution**: Use the calibration tool to adjust coordinates

### Issue: Image not found error

**Solution**: 
1. Check file path: `assets/images/vertical_equipment_bg.jpg`
2. Verify pubspec.yaml includes: `- assets/images/`
3. Run `flutter pub get`
4. Restart app (hot reload won't load new assets)

### Issue: Hitboxes shift on different devices

**Solution**: Ensure AspectRatio wrapper is present and ratio is exactly 9/16

### Issue: Icons too dark/invisible

**Solution**: Use light colors (gold, amber, white) as recommended above

### Issue: Inventory grid doesn't align

**Solution**: Adjust the Alignment Y value in `_buildInventoryGrid()`:
```dart
Align(
  alignment: const Alignment(0, 0.92), // Adjust this value
  child: SizedBox(...),
)
```

## 📊 Performance Notes

- **Image Loading**: Use `Image.asset` with caching (default behavior)
- **Overlay Widgets**: Minimal - only 8 equipment slots + 8 inventory slots
- **Rebuild Optimization**: Only selected slot rebuilds on interaction
- **Memory**: Single background image loaded once

## 🚀 Next Steps

1. **Add your background image** to `assets/images/`
2. **Test the layout** using the calibration tool
3. **Fine-tune coordinates** if needed
4. **Integrate with your data model**
5. **Remove debug code** before production
6. **Test on multiple devices** to verify consistency

## 💡 Advanced Customization

### Add Glow Effect to Equipped Items

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

### Add Rarity Colors

```dart
Color _getRarityColor(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return Colors.grey;
    case ItemRarity.rare:
      return Colors.blue;
    case ItemRarity.epic:
      return Colors.purple;
    case ItemRarity.legendary:
      return Colors.amber;
  }
}
```

### Add Stat Tooltips

```dart
onLongPress: () {
  showDialog(
    context: context,
    builder: (_) => ItemStatsDialog(item: equippedItem),
  );
}
```

## 📝 Summary

This implementation provides:
- ✅ Pixel-perfect alignment with background image
- ✅ Consistent behavior across all devices
- ✅ Easy coordinate adjustment with calibration tool
- ✅ Clean separation of design (image) and logic (code)
- ✅ Smooth touch interactions with visual feedback
- ✅ Dark fantasy aesthetic with proper icon visibility

The key insight: **Let the image do the visual work, code handles the interaction.**

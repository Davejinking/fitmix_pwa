# Equipment Screen Background Setup

## Required Image

Place your vertical equipment background image as:
```
assets/images/vertical_equipment_bg.jpg
```

## Image Specifications

- **Aspect Ratio**: 9:16 (vertical/portrait)
- **Style**: Dark Fantasy RPG (stone texture, torches, medieval)
- **Resolution**: Recommended 1080x1920 or higher
- **Format**: JPG or PNG

## Slot Layout Reference

The image should have equipment slots at these approximate positions:

### Top Row (Above Character)
- **Head**: Upper-left area
- **Neck**: Upper-right area

### Side Flanks (Around Character Body)
- **Main Hand (Weapon)**: Left side, upper
- **Off Hand (Shield)**: Right side, upper
- **Gloves**: Left side, lower
- **Chest/Armor**: Right side, lower

### Bottom Row (Below Character)
- **Legs**: Bottom-left
- **Boots**: Bottom-right

### Bottom Section
- **Inventory Grid**: 8 slots in a row at the very bottom

## Coordinate Fine-Tuning

If the slots don't align perfectly with your image, adjust the `Alignment` values in `equipment_overlay_page.dart`:

```dart
// Example: Move Head slot slightly right
_buildSlot(
  alignment: const Alignment(-0.30, -0.78), // Changed from -0.35
  slotKey: 'head',
  size: 70,
),
```

**Alignment System:**
- X-axis: -1.0 (left) to 1.0 (right)
- Y-axis: -1.0 (top) to 1.0 (bottom)
- Center: (0.0, 0.0)

**Fine-tuning tips:**
- Adjust by ±0.05 increments for small movements
- Use the debug grid (uncomment in code) to visualize positions

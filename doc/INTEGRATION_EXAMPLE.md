# Integration Example

## Quick Start

### 1. Add Background Image

Save your vertical equipment background as:
```
assets/images/vertical_equipment_bg.jpg
```

### 2. Test the Implementation

Add to your navigation (e.g., in a button or menu):

```dart
import 'package:fitmix_pwa/pages/equipment_overlay_page.dart';

// In your widget
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EquipmentOverlayPage(),
      ),
    );
  },
  child: const Text('Equipment'),
)
```

### 3. Fine-Tune Coordinates (Optional)

If slots don't align perfectly:

```dart
import 'package:fitmix_pwa/pages/equipment_calibration_page.dart';

// Temporary - for development only
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const EquipmentCalibrationPage(),
  ),
);
```

## Integration with Existing Status Page

### Option A: Replace DiabloStatusPage

In your navigation code:

```dart
// Before
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const DiabloStatusPage()),
);

// After
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const EquipmentOverlayPage()),
);
```

### Option B: Add as New Tab/Page

If you have a bottom navigation bar:

```dart
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const EquipmentOverlayPage(), // Add here
    const LibraryPage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Equipment'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Library'),
        ],
      ),
    );
  }
}
```

### Option C: Add to Drawer Menu

```dart
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        child: Text('Iron Log'),
      ),
      ListTile(
        leading: Icon(Icons.shield),
        title: Text('Equipment'),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EquipmentOverlayPage()),
          );
        },
      ),
      // ... other menu items
    ],
  ),
)
```

## Data Integration

### Connect to Your Equipment Model

Replace the mock data in `equipment_overlay_page.dart`:

```dart
class _EquipmentOverlayPageState extends State<EquipmentOverlayPage> {
  // Remove mock data
  // final Map<String, IconData?> _equippedItems = {...};
  
  // Add your data model
  Map<String, EquipmentItem?> _equippedItems = {};
  
  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }
  
  Future<void> _loadEquipment() async {
    final equipmentRepo = getIt<EquipmentRepo>();
    final equipment = await equipmentRepo.getUserEquipment();
    
    if (mounted) {
      setState(() {
        _equippedItems = {
          'head': equipment.head,
          'neck': equipment.neck,
          'mainHand': equipment.mainHand,
          'offHand': equipment.offHand,
          'gloves': equipment.gloves,
          'chest': equipment.chest,
          'legs': equipment.legs,
          'boots': equipment.boots,
        };
        _isLoading = false;
      });
    }
  }
}
```

### Update Slot Builder

Modify `_buildSlot` to use your equipment model:

```dart
Widget _buildSlot({
  required Alignment alignment,
  required String slotKey,
  required double size,
  String? label,
}) {
  final item = _equippedItems[slotKey];
  
  return Align(
    alignment: alignment,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSlotTapped(slotKey),
        borderRadius: BorderRadius.circular(8),
        splashColor: const Color(0xFFC7B377).withValues(alpha: 0.3),
        child: Container(
          width: size,
          height: size,
          child: Center(
            child: item != null
                ? _buildItemIcon(item) // Your custom icon builder
                : Icon(
                    Icons.add_circle_outline,
                    size: size * 0.4,
                    color: const Color(0xFF6A5F55).withValues(alpha: 0.5),
                  ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildItemIcon(EquipmentItem item) {
  // Use your item's icon or image
  if (item.iconPath != null) {
    return Image.asset(
      item.iconPath!,
      width: 42,
      height: 42,
      color: _getRarityColor(item.rarity),
    );
  }
  
  return Icon(
    item.iconData ?? Icons.help_outline,
    size: 42,
    color: _getRarityColor(item.rarity),
    shadows: const [
      Shadow(
        color: Colors.black,
        blurRadius: 4,
        offset: Offset(1, 1),
      ),
    ],
  );
}

Color _getRarityColor(ItemRarity rarity) {
  switch (rarity) {
    case ItemRarity.common:
      return const Color(0xFF9E9E9E); // Grey
    case ItemRarity.uncommon:
      return const Color(0xFF4CAF50); // Green
    case ItemRarity.rare:
      return const Color(0xFF2196F3); // Blue
    case ItemRarity.epic:
      return const Color(0xFF9C27B0); // Purple
    case ItemRarity.legendary:
      return const Color(0xFFFFD700); // Gold
  }
}
```

## Handling Slot Interactions

### Navigate to Inventory

```dart
void _onSlotTapped(String slotKey) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => InventoryPage(
        selectedSlot: slotKey, // Pass context
      ),
    ),
  ).then((selectedItem) {
    // Handle item selection
    if (selectedItem != null) {
      _equipItem(slotKey, selectedItem);
    }
  });
}

Future<void> _equipItem(String slotKey, EquipmentItem item) async {
  final equipmentRepo = getIt<EquipmentRepo>();
  await equipmentRepo.equipItem(slotKey, item);
  
  setState(() {
    _equippedItems[slotKey] = item;
  });
  
  // Show feedback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${item.name} equipped!'),
      backgroundColor: const Color(0xFF4CAF50),
    ),
  );
}
```

### Show Item Details

```dart
void _onSlotTapped(String slotKey) {
  final item = _equippedItems[slotKey];
  
  if (item != null) {
    // Show details modal
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      builder: (_) => ItemDetailsSheet(item: item),
    );
  } else {
    // Navigate to inventory to select item
    _openInventoryForSlot(slotKey);
  }
}
```

## Styling Customization

### Change Color Scheme

```dart
// In equipment_overlay_page.dart

// Gold theme (current)
static const Color _accentColor = Color(0xFFC7B377);
static const Color _iconColor = Color(0xFFD4C5A0);

// Blue theme
static const Color _accentColor = Color(0xFF64B5F6);
static const Color _iconColor = Color(0xFFBBDEFB);

// Red theme
static const Color _accentColor = Color(0xFFE57373);
static const Color _iconColor = Color(0xFFFFCDD2);

// Green theme
static const Color _accentColor = Color(0xFF81C784);
static const Color _iconColor = Color(0xFFC8E6C9);
```

### Adjust Slot Sizes

```dart
// Make all slots larger
_buildSlot(
  alignment: const Alignment(-0.35, -0.78),
  slotKey: 'head',
  size: 80, // Increased from 70
),

// Or make specific slots larger
Widget _buildSlot({
  required Alignment alignment,
  required String slotKey,
  required double size,
  String? label,
}) {
  // Weapon slots are larger
  final adjustedSize = (slotKey == 'mainHand' || slotKey == 'offHand')
      ? size * 1.2
      : size;
  
  return Align(
    alignment: alignment,
    child: Container(
      width: adjustedSize,
      height: adjustedSize,
      // ...
    ),
  );
}
```

## Testing Checklist

Before deploying:

- [ ] Background image loads correctly
- [ ] All slots are visible and aligned
- [ ] Touch targets work on all slots
- [ ] Empty slots show hint icon
- [ ] Equipped items display correctly
- [ ] Navigation to inventory works
- [ ] Item equipping updates UI
- [ ] Works on different screen sizes
- [ ] No performance issues
- [ ] Debug code removed (hitbox borders, grid)

## Performance Optimization

### Lazy Load Equipment Data

```dart
@override
void initState() {
  super.initState();
  // Don't block UI
  _loadEquipment();
}

Future<void> _loadEquipment() async {
  // Show loading state
  setState(() => _isLoading = true);
  
  try {
    final equipment = await equipmentRepo.getUserEquipment();
    if (mounted) {
      setState(() {
        _equippedItems = equipment.toMap();
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      // Show error
    }
  }
}
```

### Cache Background Image

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // Precache image
  precacheImage(
    const AssetImage('assets/images/vertical_equipment_bg.jpg'),
    context,
  );
}
```

## Troubleshooting

### Image not loading
```bash
# Run these commands
flutter clean
flutter pub get
# Restart app (not hot reload)
```

### Coordinates don't match
- Use calibration tool
- Check image aspect ratio is exactly 9:16
- Verify AspectRatio widget is present

### Touch not working
- Ensure InkWell/GestureDetector is present
- Check if another widget is blocking touches
- Verify slot size is reasonable (>= 44x44 for accessibility)

## Next Steps

1. **Add your background image**
2. **Test basic layout** with demo page
3. **Fine-tune coordinates** with calibration tool
4. **Integrate with your data model**
5. **Add item interactions**
6. **Test on real devices**
7. **Remove debug code**
8. **Deploy!**

## Support

See also:
- `doc/EQUIPMENT_OVERLAY_GUIDE.md` - Complete implementation guide
- `doc/COORDINATE_REFERENCE.md` - Coordinate adjustment reference
- `assets/images/EQUIPMENT_SETUP.md` - Image setup instructions

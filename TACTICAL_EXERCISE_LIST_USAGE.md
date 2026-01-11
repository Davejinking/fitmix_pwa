# TacticalExerciseList - Usage Guide

## Overview

`TacticalExerciseList` is a reusable Flutter widget for browsing and selecting exercises. It provides a consistent, polished UI with search, filtering, and selection capabilities.

---

## Basic Usage

### View Mode (Browse Only)

Use this mode when you want users to browse exercises and view details.

```dart
import 'package:your_app/widgets/tactical_exercise_list.dart';

TacticalExerciseList(
  isSelectionMode: false,
  showBookmarks: true,
)
```

**Features:**
- Search exercises
- Filter by body part and equipment
- Tap exercise to view details modal
- Bookmark/unbookmark exercises

**Use Cases:**
- Library/Exercise database page
- Exercise information browser
- Workout planning reference

---

### Selection Mode (Multi-Select)

Use this mode when you want users to select multiple exercises.

```dart
import 'package:your_app/widgets/tactical_exercise_list.dart';

TacticalExerciseList(
  isSelectionMode: true,
  onExercisesSelected: (List<Exercise> selectedExercises) {
    // Handle selected exercises
    print('Selected ${selectedExercises.length} exercises');
    for (var exercise in selectedExercises) {
      print('- ${exercise.name}');
    }
  },
)
```

**Features:**
- All View Mode features
- Multi-select with checkmarks
- Visual selection feedback
- Confirmation button with count
- Returns selected exercises via callback

**Use Cases:**
- Adding exercises to workout plan
- Creating routines
- Building exercise programs

---

## Parameters

### `isSelectionMode` (bool)
**Default:** `false`

Controls the widget's behavior:
- `false`: View mode - tap to see details
- `true`: Selection mode - tap to select/deselect

```dart
// View mode
TacticalExerciseList(isSelectionMode: false)

// Selection mode
TacticalExerciseList(isSelectionMode: true)
```

---

### `onExercisesSelected` (Function(List<Exercise>)?)
**Default:** `null`
**Required when:** `isSelectionMode = true`

Callback function that receives the list of selected exercises when user confirms selection.

```dart
TacticalExerciseList(
  isSelectionMode: true,
  onExercisesSelected: (selectedExercises) {
    // Navigate back with results
    Navigator.pop(context, selectedExercises);
    
    // Or add to state
    setState(() {
      _workoutExercises.addAll(selectedExercises);
    });
  },
)
```

---

### `initialBodyPart` (String?)
**Default:** `null` (shows 'all')

Pre-select a specific body part filter when the widget loads.

```dart
// Start with chest exercises
TacticalExerciseList(
  initialBodyPart: 'chest',
)

// Start with favorites
TacticalExerciseList(
  initialBodyPart: 'favorites',
)
```

**Valid values:**
- `'all'` - All exercises
- `'favorites'` - Bookmarked exercises
- `'chest'` - Chest exercises
- `'back'` - Back exercises
- `'legs'` - Leg exercises
- `'shoulders'` - Shoulder exercises
- `'arms'` - Arm exercises
- `'abs'` - Core/abs exercises
- `'cardio'` - Cardio exercises
- `'stretching'` - Stretching exercises
- `'fullBody'` - Full body exercises

---

### `showBookmarks` (bool)
**Default:** `true`

Controls whether bookmark functionality is visible.

```dart
// With bookmarks (default)
TacticalExerciseList(showBookmarks: true)

// Without bookmarks
TacticalExerciseList(showBookmarks: false)
```

---

## Complete Examples

### Example 1: Exercise Library Page

```dart
import 'package:flutter/material.dart';
import 'package:your_app/widgets/tactical_exercise_list.dart';

class ExerciseLibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EXERCISE LIBRARY'),
        backgroundColor: Colors.black,
      ),
      body: TacticalExerciseList(
        isSelectionMode: false,
        showBookmarks: true,
      ),
    );
  }
}
```

---

### Example 2: Add Exercise to Workout

```dart
import 'package:flutter/material.dart';
import 'package:your_app/widgets/tactical_exercise_list.dart';
import 'package:your_app/models/exercise.dart';

class AddExercisePage extends StatelessWidget {
  final Function(List<Exercise>) onExercisesAdded;

  const AddExercisePage({
    required this.onExercisesAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ADD EXERCISES'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: TacticalExerciseList(
        isSelectionMode: true,
        onExercisesSelected: (selectedExercises) {
          // Call callback with selected exercises
          onExercisesAdded(selectedExercises);
          
          // Close the page
          Navigator.pop(context);
          
          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${selectedExercises.length} exercises'),
            ),
          );
        },
      ),
    );
  }
}

// Usage:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddExercisePage(
      onExercisesAdded: (exercises) {
        setState(() {
          _workoutPlan.addAll(exercises);
        });
      },
    ),
  ),
);
```

---

### Example 3: Create Routine with Pre-filter

```dart
import 'package:flutter/material.dart';
import 'package:your_app/widgets/tactical_exercise_list.dart';

class CreateChestRoutinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CREATE CHEST ROUTINE'),
        backgroundColor: Colors.black,
      ),
      body: TacticalExerciseList(
        isSelectionMode: true,
        initialBodyPart: 'chest', // Pre-filter to chest exercises
        showBookmarks: true,
        onExercisesSelected: (selectedExercises) async {
          // Save as routine
          final routineName = await _promptForRoutineName(context);
          if (routineName != null) {
            await _saveRoutine(routineName, selectedExercises);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<String?> _promptForRoutineName(BuildContext context) async {
    // Show dialog to get routine name
    // ...
  }

  Future<void> _saveRoutine(String name, List<Exercise> exercises) async {
    // Save routine to database
    // ...
  }
}
```

---

### Example 4: Modal Bottom Sheet

```dart
void showExerciseSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Exercise list
          Expanded(
            child: TacticalExerciseList(
              isSelectionMode: true,
              onExercisesSelected: (exercises) {
                Navigator.pop(context, exercises);
              },
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## Styling

The widget uses the Iron Theme by default:

```dart
// Colors
- Background: Colors.black
- Surface: IronTheme.surface
- Primary: IronTheme.primary
- Text High: IronTheme.textHigh
- Text Medium: IronTheme.textMedium
- Text Low: IronTheme.textLow

// Typography
- Font Family: 'Courier' (monospace)
- Letter Spacing: 0.5 - 1.5
- Font Weight: w600 - w900
```

---

## State Management

The widget manages its own state internally:
- Search query
- Selected body part filter
- Selected equipment filter
- Selected exercises (in selection mode)
- Bookmark state
- Loading state

**No external state management required!**

---

## Performance

### Optimizations
- Lazy loading of exercise list
- Efficient filtering with multiple criteria
- Minimal rebuilds with proper state management
- Smooth scrolling with ListView.builder

### Best Practices
```dart
// ✅ Good: Reuse the same instance
final exerciseList = TacticalExerciseList(
  isSelectionMode: false,
);

// ❌ Avoid: Creating new instances on every build
Widget build(BuildContext context) {
  return TacticalExerciseList(...); // This is fine for most cases
}
```

---

## Accessibility

The widget includes:
- Semantic labels for screen readers
- Sufficient touch targets (44x44 minimum)
- High contrast colors
- Clear visual feedback
- Keyboard navigation support

---

## Testing

### Unit Testing
```dart
testWidgets('TacticalExerciseList shows search bar', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TacticalExerciseList(isSelectionMode: false),
      ),
    ),
  );

  expect(find.byType(TextField), findsOneWidget);
});
```

### Integration Testing
```dart
testWidgets('Can select and confirm exercises', (tester) async {
  List<Exercise>? selectedExercises;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TacticalExerciseList(
          isSelectionMode: true,
          onExercisesSelected: (exercises) {
            selectedExercises = exercises;
          },
        ),
      ),
    ),
  );

  // Wait for exercises to load
  await tester.pumpAndSettle();

  // Tap first exercise
  await tester.tap(find.byType(InkWell).first);
  await tester.pump();

  // Tap confirm button
  await tester.tap(find.text('ADD 1 EXERCISE'));
  await tester.pump();

  expect(selectedExercises, isNotNull);
  expect(selectedExercises!.length, 1);
});
```

---

## Troubleshooting

### Issue: Exercises not loading
**Solution:** Ensure `ExerciseSeedingService` is properly initialized.

### Issue: Callback not firing
**Solution:** Make sure `isSelectionMode = true` when using `onExercisesSelected`.

### Issue: Filters not working
**Solution:** Check that exercise data has proper `targetPart` and `equipmentType` fields.

### Issue: Bookmarks not persisting
**Solution:** Bookmark state is currently in-memory. Implement persistence if needed.

---

## Future Enhancements

Potential improvements:
1. Persistent bookmark storage
2. Custom filter combinations
3. Exercise preview images
4. Recent exercises filter
5. Bulk bookmark actions
6. Exercise sorting options
7. Advanced search (by muscle group, difficulty, etc.)

---

## Support

For issues or questions:
1. Check this documentation
2. Review the source code: `lib/widgets/tactical_exercise_list.dart`
3. Check example implementations in:
   - `lib/pages/library_page_v2.dart`
   - `lib/pages/exercise_selection_page_v2.dart`

---

## License

Part of the FitMix PWA project.

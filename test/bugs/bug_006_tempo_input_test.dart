// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/widgets/tempo_settings_modal.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/services/tempo_controller.dart';

void main() {
  group('BUG-006: Tempo Settings Input Test', () {
    late Exercise testExercise;

    setUp(() {
      testExercise = Exercise(
        name: 'Bench Press',
        targetBodyPart: 'Chest',
        eccentricSeconds: 2,
        concentricSeconds: 2,
        isTempoEnabled: true,
      );
    });

    testWidgets('User should be able to input tempo seconds directly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TempoSettingsModal(
              exercise: testExercise,
              onUpdate: () {},
              initialMode: TempoMode.beep,
            ),
          ),
        ),
      );

      // Verify initial value (2 초)
      expect(find.text('2 초'), findsNWidgets(2)); // eccentric and concentric

      // The bug is that the user cannot tap to edit directly.
      // We look for the container displaying the text.
      final textFinder = find.text('2 초').first;
      final containerFinder = find.ancestor(of: textFinder, matching: find.byType(Container));

      await tester.tap(containerFinder);
      await tester.pump();

      // Verify +/- buttons work as context
      await tester.tap(find.widgetWithIcon(IconButton, Icons.add_circle_outline).first);
      await tester.pump();
      expect(find.text('3 초'), findsOneWidget);

      // Assert that the widget displaying the time allows direct interaction (e.g. is a TextField or GestureDetector).
      // Currently, this fails (as expected for a bug reproduction) because it is just a Text widget.
      final editableText = find.descendant(of: containerFinder, matching: find.byType(EditableText));
      final gestureDetector = find.ancestor(of: textFinder, matching: find.byType(GestureDetector));

      // We expect one of these to enable editing
      final bool isEditable = editableText.evaluate().isNotEmpty || gestureDetector.evaluate().isNotEmpty;

      expect(isEditable, isTrue, reason: "BUG-006: Tempo duration display should be tappable/editable directly.");
    });
  });
}

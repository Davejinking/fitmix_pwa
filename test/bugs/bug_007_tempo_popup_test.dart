// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/widgets/tempo_countdown_modal.dart';
import 'package:fitmix_pwa/services/tempo_controller.dart';
import 'package:fitmix_pwa/services/tempo_metronome_service.dart';

void main() {
  group('BUG-007: Tempo Mode Popup Options', () {
    testWidgets('TempoCountdownModal should have options to minimize or hide', (WidgetTester tester) async {
      final controller = TempoController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showTempoCountdownModal(
                      context: context,
                      controller: controller,
                      totalReps: 5,
                      downSeconds: 4,
                      upSeconds: 2,
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Open the modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify Modal is open
      expect(find.byType(TempoCountdownModal), findsOneWidget);

      // BUG-007: "No option to hide/minimize"
      // We search for icons or text indicating this feature (Minimize/Hide).
      final minimizeIcon = find.byIcon(Icons.keyboard_arrow_down);
      final hideText = find.text('Hide');
      final minimizeText = find.text('Minimize');

      // Correcting the invalid `find.anyOf` usage.
      // We check if ANY of these widgets exist.
      bool foundOption = minimizeIcon.evaluate().isNotEmpty ||
                         hideText.evaluate().isNotEmpty ||
                         minimizeText.evaluate().isNotEmpty;

      expect(foundOption, isTrue, reason: "BUG-007: Should provide an option to minimize or hide the tempo popup");
    });
  });
}

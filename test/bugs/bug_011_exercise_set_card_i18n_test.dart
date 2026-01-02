import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/widgets/exercise_set_card.dart';

void main() {
  testWidgets('BUG-011: ExerciseSetCard should use localized strings', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ko'),
        ],
        locale: const Locale('en'),
        home: Scaffold(
          body: ExerciseSetCard(
            exerciseNumber: '1',
            category: 'Chest',
            exerciseName: 'Bench Press',
            sets: [
              SetData(kg: '100', reps: '10'),
            ],
            onAddSet: () {},
            onDeleteLastSet: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify "Set" and "Completed" are present (English locale)
    // Note: If AppLocalizations fails to provide "Set", this test will fail, indicating the bug.
    // We assume the desired behavior is that these strings are NOT Korean characters.

    // Check for Set label (Row header)
    expect(find.text('Set'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Also verify absence of hardcoded Korean
    expect(find.text('세트'), findsNothing);
    expect(find.text('완료'), findsNothing);
  });
}

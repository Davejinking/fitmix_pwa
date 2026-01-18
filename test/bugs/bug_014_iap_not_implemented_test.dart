import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/features/subscription/pages/upgrade_page.dart';

void main() {
  testWidgets('BUG-014: In-app purchase button should be implemented', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('ko'),
        ],
        locale: Locale('ko'),
        home: UpgradePage(),
      ),
    );

    final buttonFinder = find.widgetWithText(ElevatedButton, '월 9,900원으로 시작하기');
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);

    // Wait for the simulated delay (2 seconds)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}

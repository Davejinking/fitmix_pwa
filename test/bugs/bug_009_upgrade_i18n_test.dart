// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/upgrade_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('BUG-009: Upgrade Page i18n', () {
    testWidgets('Upgrade Page should display English text when locale is English', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('ko')],
          locale: Locale('en'), // Force English
          home: UpgradePage(),
        ),
      );

      // Verify absence of Korean text which indicates i18n failure
      expect(find.text('프리미엄으로 업그레이드'), findsNothing, reason: "BUG-009: Korean text found despite English locale");
    });

    testWidgets('Upgrade Page should display Japanese text when locale is Japanese', (WidgetTester tester) async {
       await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('ko'), Locale('ja')],
          locale: Locale('ja'), // Force Japanese
          home: UpgradePage(),
        ),
      );

      expect(find.text('프리미엄으로 업그레이드'), findsNothing, reason: "BUG-009: Korean text found despite Japanese locale");
    });
  });
}

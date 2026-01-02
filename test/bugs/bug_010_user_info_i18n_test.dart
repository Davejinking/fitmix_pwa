// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('BUG-010: User Info Form Page i18n', () {
    testWidgets('UserInfoFormPage should display English text when locale is English', (WidgetTester tester) async {
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
          home: UserInfoFormPage(),
        ),
      );

      // Verify absence of Korean text which indicates i18n failure
      expect(find.text('확인'), findsNothing, reason: "BUG-010: Korean '확인' found in English locale");
      expect(find.text('키를 입력해 주세요.'), findsNothing, reason: "BUG-010: Korean title found in English locale");
    });
  });
}

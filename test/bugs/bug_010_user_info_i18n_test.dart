// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/features/auth/pages/user_info_form_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepo extends Mock implements UserRepo {}

void main() {
  group('BUG-010: User Info Form Page i18n', () {
    late MockUserRepo mockUserRepo;

    setUp(() {
      mockUserRepo = MockUserRepo();
      when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => null);
    });

    testWidgets('UserInfoFormPage should display English text when locale is English', (WidgetTester tester) async {
      // Set larger test size to avoid overflow
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ko')],
          locale: const Locale('en'), // Force English
          home: UserInfoFormPage(userRepo: mockUserRepo),
        ),
      );

      // Verify absence of Korean text which indicates i18n failure
      expect(find.text('확인'), findsNothing, reason: "BUG-010: Korean '확인' found in English locale");
      expect(find.text('키를 입력해 주세요.'), findsNothing, reason: "BUG-010: Korean title found in English locale");
      
      // Reset view size
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}

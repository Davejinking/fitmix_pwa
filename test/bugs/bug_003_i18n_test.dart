import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/analysis_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockUserRepo extends Mock implements UserRepo {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockUserRepo mockUserRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockUserRepo = MockUserRepo();

    // Stub methods to prevent crashes
    when(() => mockSessionRepo.getSessionsInRange(any(), any()))
        .thenAnswer((_) async => []);
    when(() => mockSessionRepo.getWorkoutSessions())
        .thenAnswer((_) async => []);
  });

  testWidgets('BUG-003: AnalysisPage should not contain hardcoded Korean text when locale is English', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'), // Force English
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ko')],
        home: Scaffold(
          body: AnalysisPage(repo: mockSessionRepo, userRepo: mockUserRepo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // If "신체 밸런스 분석" is hardcoded in build() method, it will appear regardless of locale.
    // If it's localized, it should be something else (e.g., "Body Balance Analysis") or nothing if empty.

    // This assertion checks if the BUG exists.
    // If the test passes (findsNothing), the bug is fixed.
    // If the test fails (findsOneWidget), the bug is reproduced.
    expect(find.text('신체 밸런스 분석'), findsNothing, reason: 'Korean text should not be visible in English mode');
    expect(find.text('집중 공략 필요'), findsNothing, reason: 'Korean text should not be visible in English mode');
  });
}

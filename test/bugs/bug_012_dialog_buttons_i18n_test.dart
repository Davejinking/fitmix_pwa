import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/models/user_profile.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepo extends Mock implements UserRepo {}

void main() {
  late MockUserRepo mockUserRepo;

  setUp(() {
    mockUserRepo = MockUserRepo();
    when(() => mockUserRepo.getUserProfile()).thenAnswer((_) async => UserProfile(
      weight: 70,
      height: 170,
      birthDate: DateTime(1990, 1, 1),
      gender: '남성',
    ));
  });

  testWidgets('BUG-012: Dialog buttons should be localized', (WidgetTester tester) async {
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
        supportedLocales: const [
          Locale('en'),
          Locale('ko'),
        ],
        locale: const Locale('en'),
        home: UserInfoFormPage(userRepo: mockUserRepo),
      ),
    );

    // Wait for initial profile load
    await tester.pumpAndSettle();

    // Tap on a field to show picker (e.g., first TextField which is Weight)
    final textField = find.byType(TextField).first;
    await tester.tap(textField);
    await tester.pumpAndSettle(); // Wait for bottom sheet

    // Check for "Confirm" and "Cancel" (English) in the picker dialog
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Ensure Korean is not present
    expect(find.text('확인'), findsNothing);
    expect(find.text('취소'), findsNothing);
    
    // Reset view size
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}

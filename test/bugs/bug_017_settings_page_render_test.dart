import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/features/profile/pages/settings_page.dart';
import 'package:fitmix_pwa/data/user_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/settings_repo.dart';
import 'package:fitmix_pwa/data/auth_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

// Mocks
class MockUserRepo extends Mock implements UserRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}
class MockSessionRepo extends Mock implements SessionRepo {}
class MockSettingsRepo extends Mock implements SettingsRepo {}
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockUserRepo mockUserRepo;
  late MockExerciseLibraryRepo mockExerciseLibraryRepo;
  late MockSessionRepo mockSessionRepo;
  late MockSettingsRepo mockSettingsRepo;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockUserRepo = MockUserRepo();
    mockExerciseLibraryRepo = MockExerciseLibraryRepo();
    mockSessionRepo = MockSessionRepo();
    mockSettingsRepo = MockSettingsRepo();
    mockAuthRepo = MockAuthRepo();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<UserRepo>()) getIt.unregister<UserRepo>();
    if (getIt.isRegistered<ExerciseLibraryRepo>()) getIt.unregister<ExerciseLibraryRepo>();
    if (getIt.isRegistered<SessionRepo>()) getIt.unregister<SessionRepo>();
    if (getIt.isRegistered<SettingsRepo>()) getIt.unregister<SettingsRepo>();
    if (getIt.isRegistered<AuthRepo>()) getIt.unregister<AuthRepo>();

    getIt.registerSingleton<UserRepo>(mockUserRepo);
    getIt.registerSingleton<ExerciseLibraryRepo>(mockExerciseLibraryRepo);
    getIt.registerSingleton<SessionRepo>(mockSessionRepo);
    getIt.registerSingleton<SettingsRepo>(mockSettingsRepo);
    getIt.registerSingleton<AuthRepo>(mockAuthRepo);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  testWidgets('BUG-017: SettingsPage should render without error (Unused imports check)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SettingsPage(
          userRepo: mockUserRepo,
          exerciseRepo: mockExerciseLibraryRepo,
          sessionRepo: mockSessionRepo,
          settingsRepo: mockSettingsRepo,
          authRepo: mockAuthRepo,
        ),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

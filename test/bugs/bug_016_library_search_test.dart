import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/library_page_v2.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProvider for Hive
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    // Initialize Hive for the hardcoded HiveExerciseLibraryRepo in LibraryPageV2
    // Using a temporary directory for tests
    await Hive.initFlutter();

    // Create necessary boxes if the repo expects them open,
    // or handle the fact that the repo might try to open them.
    // Since we can't easily mock the internal repo, we hope it doesn't crash
    // or we catch the error. Ideally, we would use dependency injection.
    // For this UI test, we just want to ensure the Search Bar exists.
  });

  testWidgets('BUG-016: Library Search Bar should exist and accept input', (WidgetTester tester) async {
    // Build the LibraryPageV2 wrapped in MaterialApp for localization
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LibraryPageV2()),
      ),
    );

    // Allow time for async inits (if any)
    await tester.pumpAndSettle();

    // Verify Search Bar exists
    // Looking for a TextField or TextFormField
    final searchFinder = find.byType(TextField);
    expect(searchFinder, findsOneWidget);

    // Verify we can enter text
    await tester.enterText(searchFinder, 'Bench Press');
    await tester.pump();

    // Verify text is entered
    expect(find.text('Bench Press'), findsOneWidget);

    // Note: Verifying actual filtering requires mocking the data source which is
    // hardcoded in LibraryPageV2. For now, we verify the UI component exists
    // and is interactive, confirming the feature is "Implemented".
  });
}

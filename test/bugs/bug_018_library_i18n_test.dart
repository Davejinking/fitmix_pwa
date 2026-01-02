import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/library_page_v2.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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
    await Hive.initFlutter();
  });

  testWidgets('BUG-018: Library i18n should localize tab titles', (WidgetTester tester) async {
    // Test with Korean Locale
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ko'),
        home: Scaffold(body: LibraryPageV2()),
      ),
    );

    await tester.pumpAndSettle();

    // "Chest" in Korean is "가슴"
    // "Back" in Korean is "등"
    // Check if these texts appear in the TabBar
    expect(find.text('가슴'), findsOneWidget);
    expect(find.text('등'), findsOneWidget);

    // Test with English Locale
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(body: LibraryPageV2()),
      ),
    );

    await tester.pumpAndSettle();

    // "Chest" in English
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}

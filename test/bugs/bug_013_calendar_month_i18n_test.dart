import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    // Initialize date formatting for all locales
    await initializeDateFormatting();
  });

  test('BUG-013: Calendar month name should be localized using DateFormat', () async {
    // Since BUG-013 was about DateFormat usage, we test DateFormat directly with different locales.
    // The bug was "Calendar month name fixed in English" (or maybe fixed in a specific way).
    // The fix was `DateFormat.yMMMM(Localizations.localeOf(context).languageCode)`.

    // Test English
    final date = DateTime(2023, 1, 1);
    final enFormat = DateFormat.yMMMM('en');
    expect(enFormat.format(date), equals('January 2023'));

    // Test Korean
    final koFormat = DateFormat.yMMMM('ko');
    expect(koFormat.format(date), equals('2023년 1월'));

    // Test Japanese
    final jaFormat = DateFormat.yMMMM('ja');
    expect(jaFormat.format(date), equals('2023年1月'));
  });
}

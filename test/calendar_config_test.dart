import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitmix_pwa/core/calendar_config.dart';

void main() {
  test('월만 노출(기본)', () {
    final map = availableFormats(enableMultiFormat: false);
    expect(map.keys.contains(CalendarFormat.month), true);   // 성공 케이스
    expect(map.keys.contains(CalendarFormat.twoWeeks), false); // 실패 케이스(있으면 안 됨)
    expect(formatButtonVisible(enableMultiFormat: false), false);
  });

  test('2주 노출(플래그=on)', () {
    final map = availableFormats(enableMultiFormat: true);
    expect(map.keys.contains(CalendarFormat.twoWeeks), true); // 성공 케이스
    expect(formatButtonVisible(enableMultiFormat: true), true);
  });
}

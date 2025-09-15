import 'package:table_calendar/table_calendar.dart';
import 'feature_flags.dart';

/// 달력 포맷 맵(월만 or 월+2주). 테스트용으로 주입도 가능.
Map<CalendarFormat, String> availableFormats({bool? enableMultiFormat}) {
  final enabled = enableMultiFormat ?? FeatureFlags.calendarMultiFormat;
  return enabled
      ? const {
          CalendarFormat.month: '월',
          CalendarFormat.twoWeeks: '2주',
          // 필요 시 주간도 여기서 열면 됨:
          // CalendarFormat.week: '1주',
        }
      : const {
          CalendarFormat.month: '월',
        };
}

bool formatButtonVisible({bool? enableMultiFormat}) =>
    enableMultiFormat ?? FeatureFlags.calendarMultiFormat;

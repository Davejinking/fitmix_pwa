/// PS0: 상수 플래그. 나중에 PS2에서 서버/구독과 연동하면 됨.
/// --dart-define=CALENDAR_MULTI_FORMAT=true 로 실행 시 켜짐.
class FeatureFlags {
  static const bool calendarMultiFormat =
      bool.fromEnvironment('CALENDAR_MULTI_FORMAT', defaultValue: false);
}

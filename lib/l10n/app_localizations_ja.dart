// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'FitMix PS0';

  @override
  String greetingWithName(String name) {
    return 'こんにちは、$nameさん';
  }

  @override
  String get defaultUser => 'ユーザー';

  @override
  String get burnFit => 'BURN FIT';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get updateNote => '9月22日アップデートノート';

  @override
  String get myGoal => 'マイ目標';

  @override
  String get createNow => '今すぐ作成';

  @override
  String workoutDaysGoal(int days, int goal) {
    return '運動日数: $days / $goal 日';
  }

  @override
  String workoutVolumeGoal(String volume, String goal) {
    return '運動ボリューム: $volume / $goal kg';
  }

  @override
  String get startWorkout => 'ワークアウトを開始';

  @override
  String get activityTrend => '運動量の変化';

  @override
  String get time => '時間';

  @override
  String get volume => 'ボリューム';

  @override
  String get density => '密度';

  @override
  String weeklyAverageVolume(String volume) {
    return '今週の平均運動ボリュームは${volume}kgです。';
  }

  @override
  String weeklyComparison(String diff) {
    return '先週比 ${diff}kg';
  }

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String get weekdaySun => '日';

  @override
  String get home => 'ホーム';

  @override
  String get calendar => 'カレンダー';

  @override
  String get library => 'ライブラリ';

  @override
  String get analysis => '分析';

  @override
  String get unknownPage => '不明なページ';

  @override
  String get fitMix => 'FitMix';

  @override
  String get editGoal => '目標を編集';
}

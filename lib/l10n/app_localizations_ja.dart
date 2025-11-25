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

  @override
  String get selectDate => '行く日';

  @override
  String get planWorkout => 'ワークアウトを計画';

  @override
  String get noWorkoutRecords => '運動記録がありません';

  @override
  String get workoutRecord => '運動記録';

  @override
  String totalVolume(String volume) {
    return '総ボリューム: ${volume}kg';
  }

  @override
  String andMore(int count) {
    return '他 $count個';
  }

  @override
  String get todayWorkout => '今日のワークアウト';

  @override
  String get restTimeSetting => '休憩時間設定';

  @override
  String get endWorkout => 'ワークアウト終了';

  @override
  String get endWorkoutConfirm => 'ワークアウトを終了して記録を保存しますか？';

  @override
  String get endAndSaveWorkout => 'ワークアウト終了・保存';

  @override
  String get noWorkoutPlan => '今日のワークアウト計画がありません。\\nカレンダーで先に計画を立ててください。';

  @override
  String get skipRest => '休憩をスキップ';

  @override
  String seconds(int count) {
    return '$count秒';
  }

  @override
  String get close => '閉じる';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Lifto';

  @override
  String greetingWithName(Object name) {
    return 'こんにちは、$nameさん';
  }

  @override
  String get defaultUser => 'ユーザー';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get myGoal => 'マイ目標';

  @override
  String get createNow => '今すぐ作成';

  @override
  String workoutDaysGoal(Object days, Object goal) {
    return '運動日数: $days / $goal 日';
  }

  @override
  String workoutVolumeGoal(Object goal, Object volume) {
    return '運動ボリューム: $volume / $goal kg';
  }

  @override
  String get startWorkout => 'ワークアウト開始';

  @override
  String get activityTrend => '運動量の変化';

  @override
  String get time => '時間';

  @override
  String get volume => 'ボリューム';

  @override
  String get density => '密度';

  @override
  String weeklyAverageVolume(Object volume) {
    return '今週の平均運動ボリュームは${volume}kgです。';
  }

  @override
  String weeklyComparison(Object diff) {
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
  String get fitMix => 'Lifto';

  @override
  String get editGoal => '目標を編集';

  @override
  String get selectDate => '日付選択';

  @override
  String get planWorkout => 'ワークアウトを計画';

  @override
  String get noWorkoutRecords => '運動記録がありません';

  @override
  String get workoutRecord => '運動記録';

  @override
  String totalVolume(Object volume) {
    return '総ボリューム: ${volume}kg';
  }

  @override
  String totalVolumeShort(Object volume) {
    return '総ボリューム ${volume}kg';
  }

  @override
  String andMore(Object count) {
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
  String get endAndSaveWorkout => '終了して保存';

  @override
  String get noWorkoutPlan => '今日のワークアウト計画がありません。\nカレンダーで先に計画を立ててください。';

  @override
  String get noWorkoutPlanDesc => '下の「運動追加」ボタンをタップして\n運動を追加してください';

  @override
  String get skipRest => '休憩をスキップ';

  @override
  String get restTimer => '休憩タイマー';

  @override
  String get adjustRestTime => '休憩時間調整';

  @override
  String get workoutDuration => 'ワークアウト時間';

  @override
  String get restTimeRemaining => '休憩時間残り';

  @override
  String seconds(Object count) {
    return '$count秒';
  }

  @override
  String get secondsUnit => '秒';

  @override
  String get close => '閉じる';

  @override
  String get confirm => '確認';

  @override
  String get continueWorkout => '続ける';

  @override
  String get quit => '終了';

  @override
  String get volumeByBodyPart => '部位別総ボリューム';

  @override
  String get monthlyWorkoutTime => '月別総運動時間';

  @override
  String get noAnalysisData => '分析する運動記録がありません。';

  @override
  String errorOccurred(Object error) {
    return 'エラー発生: $error';
  }

  @override
  String hours(Object count) {
    return '$count 時間';
  }

  @override
  String get addExercise => '運動追加';

  @override
  String get editExercise => '運動修正';

  @override
  String get exerciseName => '運動名';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get saved => '保存しました。';

  @override
  String saveFailed(Object error) {
    return '保存に失敗しました。';
  }

  @override
  String loadFailed(Object error) {
    return '読み込み失敗: $error';
  }

  @override
  String get deleteExercise => '運動削除';

  @override
  String deleteExerciseConfirm(Object name) {
    return '\'$name\' を削除しますか？';
  }

  @override
  String get deleteFailed => '削除に失敗しました。';

  @override
  String get libraryEmpty => '運動ライブラリが空です。';

  @override
  String get profile => 'プロフィール';

  @override
  String get bodyInfo => '身体情報';

  @override
  String get edit => '修正';

  @override
  String height(Object value) {
    return '身長: $value cm';
  }

  @override
  String weight(Object value) {
    return '体重: $value kg';
  }

  @override
  String get workoutGoal => '運動目標';

  @override
  String get monthlyWorkoutDays => '月別運動日数';

  @override
  String get monthlyTotalVolume => '月別総ボリューム';

  @override
  String get saveGoal => '目標保存';

  @override
  String get selectFromGallery => 'ギャラリーから選択';

  @override
  String get deletePhoto => '写真削除';

  @override
  String get guest => 'ゲスト';

  @override
  String get settings => '設定';

  @override
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get systemSetting => 'システム設定';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get account => 'アカウント';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String get version => 'バージョン';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => 'ログアウトしますか？';

  @override
  String get loginWithGoogle => 'Googleでログイン';

  @override
  String get continueAsGuest => 'ゲストとして続ける';

  @override
  String get allInOnePlace => 'すべてのワークアウトを一か所で';

  @override
  String get enterWeight => '体重を入力してください。';

  @override
  String get enterHeight => '身長を入力してください。';

  @override
  String get requiredInfo => 'ワークアウトを始めるために\n必須情報を教えてください。';

  @override
  String get weightLabel => '体重 *';

  @override
  String get heightLabel => '身長 *';

  @override
  String get saveInfoFailed => '情報保存に失敗しました。';

  @override
  String get import => 'インポート';

  @override
  String added(Object text) {
    return '追加: $text';
  }

  @override
  String get exerciseAdded => '運動が追加されました。';

  @override
  String get reorderSaveFailed => '順序変更の保存に失敗しました。';

  @override
  String deleted(Object name) {
    return '$name 削除';
  }

  @override
  String get undo => '元に戻す';

  @override
  String get addSet => 'セット追加';

  @override
  String get deleteSet => 'セット削除';

  @override
  String get planYourWorkout => 'ワークアウトを計画しましょう！';

  @override
  String setNumber(Object number) {
    return '$numberセット';
  }

  @override
  String get setLabel => 'セット';

  @override
  String get weightKg => '重量(kg)';

  @override
  String get reps => '回数';

  @override
  String get repsUnit => '回';

  @override
  String get completed => '完了';

  @override
  String get notCompleted => '未完了';

  @override
  String get minOneSet => '最低1セット必要です。';

  @override
  String get enterRepsFirst => '先に目標回数を入力してください';

  @override
  String get favorites => 'お気に入り';

  @override
  String get chest => '胸';

  @override
  String get back => '背中';

  @override
  String get legs => '下半身';

  @override
  String get shoulders => '肩';

  @override
  String get arms => '腕';

  @override
  String get abs => '腹筋';

  @override
  String get cardio => '有酸素';

  @override
  String get stretching => 'ストレッチ';

  @override
  String get fullBody => '全身';

  @override
  String get all => '全て';

  @override
  String get bodyweight => '自重';

  @override
  String get machine => 'マシン';

  @override
  String get barbell => 'バーベル';

  @override
  String get dumbbell => 'ダンベル';

  @override
  String get cable => 'ケーブル';

  @override
  String get band => 'バンド';

  @override
  String get searchExercise => '運動を検索';

  @override
  String get noExercises => '運動がありません。';

  @override
  String get retry => '再試行';

  @override
  String get addCustomExercise => 'カスタム運動追加';

  @override
  String get customExerciseName => '運動名';

  @override
  String get selectBodyPart => '部位選択';

  @override
  String get selectEquipment => '器具選択';

  @override
  String get add => '追加';

  @override
  String get pleaseEnterExerciseName => '運動名を入力してください。';

  @override
  String get workoutPlan => 'ワークアウト計画';

  @override
  String get selectExercise => '運動選択';

  @override
  String workoutInProgress(Object day, Object month, Object weekday) {
    return '$month月$day日 ($weekday) ワークアウト中';
  }

  @override
  String exerciseCount(Object count) {
    return '$count個の運動';
  }

  @override
  String get cannotChangeDateDuringWorkout => 'ワークアウト中は日付を変更できません';

  @override
  String get workoutCompleted => 'ワークアウト完了！🎉';

  @override
  String get cancelTimer => 'タイマーキャンセル';

  @override
  String get rest => '休憩';

  @override
  String get waiting => '待機';

  @override
  String get tempo => 'テンポ';

  @override
  String tempoStart(Object concentric, Object eccentric) {
    return 'テンポ開始 ($eccentric/$concentric秒)';
  }

  @override
  String get memo => 'メモ';

  @override
  String get dayUnit => '日';

  @override
  String get validWorkoutDaysGoal => '正しい運動日数目標を入力してください。';

  @override
  String get validVolumeGoal => '正しいボリューム目標を入力してください。';

  @override
  String get goalSaved => '目標が保存されました。';

  @override
  String get profilePhotoChanged => 'プロフィール写真が変更されました。';

  @override
  String get profilePhotoDeleted => 'プロフィール写真が削除されました。';

  @override
  String get birthDate => '生年月日 *';

  @override
  String get enterBirthDate => '生年月日を入力してください。';

  @override
  String get gender => '性別 *';

  @override
  String get enterGender => '性別を選択してください。';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get next => '次へ';

  @override
  String get infoUsageNotice => '入力情報は運動推薦のみに使用されます。';

  @override
  String get analysisTitle => '分析';

  @override
  String get totalVolumeLabel => '総ボリューム';

  @override
  String get bodyBalanceAnalysis => '身体バランス分析';

  @override
  String get last30DaysSets => '最近30日の部位別運動セット数';

  @override
  String get analysisResult => '分析結果';

  @override
  String bodyPartAnalysisResult(
    Object strongest,
    Object strongestSets,
    Object weakest,
    Object weakestSets,
  ) {
    return '現在$strongest運動の比重が高く($strongestSetsセット)、$weakest運動が不足しています($weakestSetsセット)。';
  }

  @override
  String get focusNeeded => '集中強化が必要';

  @override
  String lowBodyPartWarning(Object parts) {
    return '現在$parts運動の比重が低いです。バランスのためにもう少し注意してください！';
  }

  @override
  String get goToSupplementExercise => '補完運動へ';

  @override
  String totalXpWeekly(Object total, Object weekly) {
    return '合計 $total XP · 今週 $weekly XP';
  }

  @override
  String streakMessage(Object days) {
    return '$days日連続運動中！🔥';
  }

  @override
  String get startWorkoutToday => '今日のワークアウトを始めましょう！';

  @override
  String longestRecord(Object days) {
    return '最長記録: $days日';
  }

  @override
  String get createFirstStreak => '最初のストリークを作りましょう';

  @override
  String get oneMinute => '1分';

  @override
  String get oneMinute30Sec => '1分30秒';

  @override
  String get twoMinutes => '2分';

  @override
  String get threeMinutes => '3分';

  @override
  String xpRemaining(int xp) {
    return '$xp XP 残り';
  }

  @override
  String get achievement => '実績';

  @override
  String get achieveFirst => '最初の実績を達成しましょう！';

  @override
  String exerciseUnit(int count) {
    return '$count個';
  }

  @override
  String get exercise => '運動';

  @override
  String get totalSets => '総セット';

  @override
  String setsUnit(int count) {
    return '$countセット';
  }

  @override
  String get startWorkoutNow => '今すぐワークアウト開始';

  @override
  String get noRecentWorkout => '最近の運動記録がありません';

  @override
  String level(int level) {
    return 'レベル $level';
  }

  @override
  String get leagueBronze => 'ブロンズ';

  @override
  String get leagueSilver => 'シルバー';

  @override
  String get leagueGold => 'ゴールド';

  @override
  String get leaguePlatinum => 'プラチナ';

  @override
  String get leagueDiamond => 'ダイヤモンド';

  @override
  String get leagueMaster => 'マスター';

  @override
  String get completeLabel => '完了';

  @override
  String get currentStreak => '現在のストリーク';

  @override
  String get totalWorkouts => '総ワークアウト';

  @override
  String get achievementUnlocked => '✅ 達成完了!';

  @override
  String get achievementLocked => '🔒 未達成';
}

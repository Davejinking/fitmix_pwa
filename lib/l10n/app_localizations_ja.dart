// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'アイアンログ';

  @override
  String greetingWithName(Object name) {
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
  String get weekdayMonShort => '月';

  @override
  String get weekdayTueShort => '火';

  @override
  String get weekdayWedShort => '水';

  @override
  String get weekdayThuShort => '木';

  @override
  String get weekdayFriShort => '金';

  @override
  String get weekdaySatShort => '土';

  @override
  String get weekdaySunShort => '日';

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
  String get operationalStatus => '運用状況';

  @override
  String get weekLabel => '週';

  @override
  String get totalLoad => '総負荷';

  @override
  String get vsLast => '前回比';

  @override
  String get sessionAvg => 'セッション平均';

  @override
  String get heartRate => '心拍数';

  @override
  String get duration => '時間';

  @override
  String get restTime => '休憩時間';

  @override
  String get latestLogs => '最新の記録';

  @override
  String get noRecentWorkouts => '最近のトレーニングなし';

  @override
  String get startSession => 'セッション開始';

  @override
  String get systemReady => 'システム準備完了';

  @override
  String get buildVersion => 'ビルド';

  @override
  String get calendarTitle => '月間カレンダー';

  @override
  String get weekdayMonAbbr => '月';

  @override
  String get weekdayTueAbbr => '火';

  @override
  String get weekdayWedAbbr => '水';

  @override
  String get weekdayThuAbbr => '木';

  @override
  String get weekdayFriAbbr => '金';

  @override
  String get weekdaySatAbbr => '土';

  @override
  String get weekdaySunAbbr => '日';

  @override
  String get quickActionRoutine => 'ルーティン';

  @override
  String get quickActionProgram => 'プログラム';

  @override
  String get quickActionPlan => '計画';

  @override
  String get quickActionRest => '休息';

  @override
  String get quickActionLog => '記録';

  @override
  String get fitMix => 'アイアンログ';

  @override
  String get editGoal => '目標を編集';

  @override
  String get selectDate => '日付選択';

  @override
  String get planWorkout => 'ワークアウトを計画';

  @override
  String get markRest => '休息日にする';

  @override
  String get cancelRest => '休息日を解除';

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
  String get finishWorkoutTitle => 'ワークアウトを終了しますか？';

  @override
  String get finishWorkout => 'ワークアウト完了';

  @override
  String get continueWorkout => '続ける';

  @override
  String get workoutWillBeSaved => 'すべての記録が保存されます';

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
  String get restDaySet => '休息日に設定されました。';

  @override
  String get restDayUnset => '休息日設定が解除されました。';

  @override
  String get saveFailed => '保存に失敗しました。';

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
  String get enterWeightAndReps => '重量と回数を入力してください';

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
  String get push => 'プッシュ';

  @override
  String get pull => 'プル';

  @override
  String get upper => '上半身';

  @override
  String get lower => '下半身';

  @override
  String get exercises => 'エクササイズ';

  @override
  String get weeklyStatus => '週間ステータス';

  @override
  String get monthlyGoal => '月間目標';

  @override
  String get initiateWorkout => 'ワークアウト開始';

  @override
  String get editSession => 'セッション編集';

  @override
  String get workouts => 'ワークアウト';

  @override
  String get totalVol => '総ボリューム';

  @override
  String get avgVol => '平均ボリューム';

  @override
  String get consistency => '一貫性';

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
  String get kettlebell => 'ケトルベル';

  @override
  String get searchExercise => '運動を検索';

  @override
  String get exerciseSelect => '種目選択';

  @override
  String get searchDatabase => 'ワークアウトを検索...';

  @override
  String get selectWorkout => 'ワークアウト選択';

  @override
  String get filterParameters => '絞り込み設定';

  @override
  String get applyFilters => '適用する';

  @override
  String get reset => 'リセット';

  @override
  String get targetMuscle => '対象筋肉';

  @override
  String get equipmentType => '器具タイプ';

  @override
  String get indexStatus => 'インデックス状態';

  @override
  String get statusReady => '準備完了';

  @override
  String get availableUnits => '利用可能';

  @override
  String get searchRoutine => 'ルーティン検索';

  @override
  String get noExercises => '運動がありません。';

  @override
  String get retry => '再試行';

  @override
  String get addCustomExercise => '新しい運動を追加';

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
  String exerciseCount(int count) {
    return '$count個の運動';
  }

  @override
  String get cannotChangeDateDuringWorkout => 'ワークアウト中は日付を変更できません';

  @override
  String get workoutCompleted => 'ワークアウト完了！🎉';

  @override
  String get editCompleted => '編集が完了しました。';

  @override
  String get workoutCompletedTitle => 'ワークアウト完了';

  @override
  String get incompleteSetWarning => '一部のセットが完了していません。\nそれでもワークアウトを完了しますか？';

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
  String get recentRecord => '最近の記録';

  @override
  String get noRecentRecords => '最近の記録がありません';

  @override
  String get workingOut => 'ワークアウト中';

  @override
  String get setsCompleted => 'セット完了';

  @override
  String get restTimeSettings => '休憩時間設定';

  @override
  String get showOnScreen => '画面に表示';

  @override
  String get showOnScreenDescription => '休憩タイマーを画面に大きく表示します';

  @override
  String get tapToAdjustTime => 'タップして時間調整';

  @override
  String get dayUnit => '日';

  @override
  String get timesUnit => '回';

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
    return '残り$xp XP';
  }

  @override
  String get achievement => '実績';

  @override
  String get currentStreak => '現在のストリーク';

  @override
  String get totalWorkouts => '総ワークアウト';

  @override
  String get achievementUnlocked => '✅ 達成完了!';

  @override
  String get achievementLocked => '🔒 未達成';

  @override
  String get achieveFirst => '最初の実績を達成しましょう！';

  @override
  String exerciseUnit(Object count) {
    return '$count個';
  }

  @override
  String get exercise => 'エクササイズ';

  @override
  String get totalSets => '総セット';

  @override
  String setsUnit(Object count) {
    return '$countセット';
  }

  @override
  String get startWorkoutNow => '今すぐワークアウト開始';

  @override
  String get noRecentWorkout => '最近の運動記録がありません';

  @override
  String level(Object level) {
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
  String get basicInfo => '基本情報';

  @override
  String get bodyPart => '部位';

  @override
  String get equipment => '器具';

  @override
  String get exerciseType => 'タイプ';

  @override
  String get customExercise => 'カスタム運動';

  @override
  String get exerciseInstructions => '運動方法';

  @override
  String get primaryMuscles => '主要ターゲット筋肉';

  @override
  String get secondaryMuscles => '補助筋肉';

  @override
  String get addToWorkoutPlan => 'ワークアウト計画に追加';

  @override
  String get achievementStreak3Title => '始まりが半分';

  @override
  String get achievementStreak3Desc => '3日連続運動';

  @override
  String get achievementStreak7Title => '一週間戦士';

  @override
  String get achievementStreak7Desc => '7日連続運動';

  @override
  String get achievementStreak30Title => '一ヶ月の奇跡';

  @override
  String get achievementStreak30Desc => '30日連続運動';

  @override
  String get achievementWorkout1Title => '最初の一歩';

  @override
  String get achievementWorkout1Desc => '初回運動完了';

  @override
  String get achievementWorkout10Title => '習慣形成';

  @override
  String get achievementWorkout10Desc => '10回運動完了';

  @override
  String get achievementWorkout50Title => '運動マニア';

  @override
  String get achievementWorkout50Desc => '50回運動完了';

  @override
  String get achievementWorkout100Title => '百戦百勝';

  @override
  String get achievementWorkout100Desc => '100回運動完了';

  @override
  String get achievementVolume10kTitle => '1万キログラム';

  @override
  String get achievementVolume10kDesc => '総ボリューム10,000kg達成';

  @override
  String get achievementVolume100kTitle => '10万クラブ';

  @override
  String get achievementVolume100kDesc => '総ボリューム100,000kg達成';

  @override
  String get achievementVolume1mTitle => 'ミリオンリフター';

  @override
  String get achievementVolume1mDesc => '総ボリューム1,000,000kg達成';

  @override
  String get achievementWeekendTitle => '週末戦士';

  @override
  String get achievementWeekendDesc => '週末に運動';

  @override
  String get set => 'セット';

  @override
  String get done => '完了';

  @override
  String get collapseAll => 'すべて閉じる';

  @override
  String get expandAll => 'すべて開く';

  @override
  String get reorder => '並び替え';

  @override
  String get reorderExercises => '運動の順序変更';

  @override
  String get dragToReorder => 'ドラッグして順序を変更';

  @override
  String get exerciseList => '運動リスト';

  @override
  String get birthDateFormat => 'yyyy年MM月dd日';

  @override
  String exerciseSelected(String name) {
    return '$name 運動が選択されました。';
  }

  @override
  String get nextGoal => '次の目標';

  @override
  String get insufficientPower => 'パワーが不足しています💪';

  @override
  String get lightningBadge => 'ライトニングバッジ';

  @override
  String get specialBadgeDesc => 'プロフィールに表示される特別バッジ';

  @override
  String get streakFreeze => 'ストリークフリーズ';

  @override
  String get streakFreezeSuccess => 'ストリークフリーズを購入しました！❄️';

  @override
  String get weeklyReportTitle => '📊 週間レポート';

  @override
  String get allRecords => 'すべての記録';

  @override
  String get items => 'アイテム';

  @override
  String get purplePointTheme => 'パープルポイントテーマ';

  @override
  String get startMonthly => '月額¥990で開始';

  @override
  String get advancedAnalytics => '高度な分析';

  @override
  String get thisWeekPerformance => '今週のパフォーマンス';

  @override
  String get cloudBackup => 'クラウドバックアップ';

  @override
  String get upgradeTitle => 'プレミアムにアップグレード';

  @override
  String get unlockAllFeatures => 'すべての機能をアンロック';

  @override
  String get removeAds => '広告を削除';

  @override
  String get powerShop => 'パワーショップ';

  @override
  String get weeklyReportDesc => '今週のワークアウト分析レポート';

  @override
  String get removeAdsDesc => '邪魔されずにワークアウトに集中してください。';

  @override
  String get weeklyReport => '週間ワークアウトレポート';

  @override
  String get customization => 'カスタマイゼーション';

  @override
  String get cloudBackupDesc => '複数のデバイス間でデータを安全に同期します。';

  @override
  String get encouragingMessage => 'よくやっています！';

  @override
  String get cancelAnytime => 'いつでもサブスクリプションをキャンセルできます。';

  @override
  String leaguePromotion(String league) {
    return '$leagueリーグ';
  }

  @override
  String get encouragingDesc => '継続的なワークアウトで目標を達成できます';

  @override
  String get advancedAnalyticsDesc => '週間、月間、年間のワークアウトデータの深い分析。';

  @override
  String get streakFreezeDesc => '1日休んでもストリークを維持';

  @override
  String get darkPurpleTheme => 'ダークパープルテーマ';

  @override
  String get fireTheme => 'ファイアテーマ';

  @override
  String get comingSoon => '準備中';

  @override
  String levelAchievement(int level) {
    return 'レベル$level達成';
  }

  @override
  String get specialBadges => '特別バッジ';

  @override
  String get orangeTheme => 'バーニングオレンジテーマ';

  @override
  String get workoutPlanEmpty => 'ワークアウト計画がありません';

  @override
  String get restingDay => '休息日';

  @override
  String get restingDayDesc => '今日は休息日です。\n「休息日を解除」ボタンで変更できます';

  @override
  String get planWorkoutDesc => '下の「ワークアウトを計画」ボタンをタップして\n運動を追加してください';

  @override
  String get cancelRestDay => '休息日を解除';

  @override
  String get editWorkout => 'ワークアウトを編集';

  @override
  String get addWorkout => 'ワークアウトを追加';

  @override
  String get editComplete => '編集完了';

  @override
  String get minOneSetRequired => '最低1セット必要です';

  @override
  String get deleteExerciseTitle => '運動削除';

  @override
  String deleteExerciseMessage(String exerciseName) {
    return '最後のセットを削除すると「$exerciseName」の運動が完全に削除されます。\n本当に削除しますか？';
  }

  @override
  String get delete => '削除';

  @override
  String addExercises(int count) {
    return '$count個の運動を追加';
  }

  @override
  String get comingSoonMessage => '準備中です！';

  @override
  String owned(int count) {
    return '所有: $count';
  }

  @override
  String get xpEarned => 'XP獲得';

  @override
  String get powerEarned => 'パワー獲得';

  @override
  String get totalRecords => '総記録';

  @override
  String get totalXp => '総XP';

  @override
  String get currentLevel => '現在のレベル';

  @override
  String get currentPower => '現在のパワー';

  @override
  String get todayWorkoutPlan => '今日のワークアウト計画';

  @override
  String get thisWeekWorkout => '今週のワークアウト';

  @override
  String get thisMonthGoal => '今月の目標';

  @override
  String streakDays(int days) {
    return '$days日連続';
  }

  @override
  String get workoutTimeLabel => 'ワークアウト時間';

  @override
  String thisWeekCompleted(int count) {
    return '今週 $count/7日完了';
  }

  @override
  String get workoutConsistency => 'トレーニング一貫性';

  @override
  String activityPastMonths(int months) {
    return '過去$monthsヶ月間のアクティビティ';
  }

  @override
  String get heatmapLess => '少';

  @override
  String get heatmapMore => '多';

  @override
  String get restDay => '休息日';

  @override
  String dayStreak(int days) {
    return '$days日ストリーク';
  }

  @override
  String daysCompleted(int completed, int total) {
    return '$completed/$total日完了';
  }

  @override
  String daysRemaining(int days) {
    return '残り$days日';
  }

  @override
  String get addExerciseToPlan => '運動を追加して今日の計画を立てましょう';

  @override
  String get restDayMessage => '今日は休息日です';

  @override
  String get workoutCompleteTitle => 'ワークアウト完了！';

  @override
  String get todayWorkoutTitle => '今日のワークアウト';

  @override
  String exercisesCompleted(int completed, int total) {
    return '$completed/$total 運動完了';
  }

  @override
  String minutesUnit(int minutes) {
    return '$minutes分';
  }

  @override
  String get saveRoutine => 'ルーティン保存';

  @override
  String get loadRoutine => 'ルーティン読み込み';

  @override
  String get routines => 'ルーティン';

  @override
  String get routineName => 'ルーティン名';

  @override
  String get enterRoutineName => '名前を入力 (例: プッシュA)';

  @override
  String get routineSaved => 'ルーティンが保存されました';

  @override
  String get routineLoaded => 'ルーティンを読み込みました';

  @override
  String get routineDeleted => 'ルーティンが削除されました';

  @override
  String get deleteRoutine => 'ルーティン削除';

  @override
  String deleteRoutineConfirm(Object name) {
    return '\'$name\'ルーティンを削除しますか？';
  }

  @override
  String get noRoutines => '保存されたルーティンがありません';

  @override
  String get loadThisRoutine => 'このルーティンで始めますか？';

  @override
  String get archiveRoutine => 'ルーティンをアーカイブ';

  @override
  String get createRoutine => '新しいルーティンを作成';

  @override
  String get editRoutine => 'ルーティン編集';

  @override
  String get createRoutineHint => '上のボタンを押して最初のルーティンを作成してください';

  @override
  String get routineLimitReached => 'ルーティン制限に達しました';

  @override
  String routineLimitMessage(int limit) {
    return '無料ユーザーは最大$limit個のルーティンのみ保存できます。\nPROにアップグレードすると無制限に保存できます。';
  }

  @override
  String get upgradeToPro => 'PROにアップグレード';

  @override
  String get upgradeToProShort => 'アップグレード';

  @override
  String get skip => 'スキップ';

  @override
  String get onboardingTitle1 => 'ワークアウトを記録';

  @override
  String get onboardingSubtitle1 => 'セット、重量、回数を簡単に記録\n自動でボリュームを計算します';

  @override
  String get onboardingTitle2 => 'テンポガイド';

  @override
  String get onboardingSubtitle2 => '正確なテンポでトレーニング\n音声、ビープ音、振動でガイド';

  @override
  String get onboardingTitle3 => 'ストリークを積み上げる';

  @override
  String get onboardingSubtitle3 => '毎日ワークアウトして記録を作ろう\n継続が最高の結果を生みます';

  @override
  String get onboardingTitle4 => '成長を確認';

  @override
  String get onboardingSubtitle4 => '週間・月間統計で進歩を確認\n目標に向かって進みましょう';

  @override
  String get exerciseAddedSuccessfully => 'エクササイズが正常に追加されました。';
}

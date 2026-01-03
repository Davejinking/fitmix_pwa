// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lifto';

  @override
  String greetingWithName(Object name) {
    return 'Hello, $name';
  }

  @override
  String get defaultUser => 'User';

  @override
  String get burnFit => 'BURN FIT';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get updateNote => 'September 22 Update Note';

  @override
  String get myGoal => 'My Goal';

  @override
  String get createNow => 'Create Now';

  @override
  String workoutDaysGoal(Object days, Object goal) {
    return 'Workout Days: $days / $goal days';
  }

  @override
  String workoutVolumeGoal(Object goal, Object volume) {
    return 'Workout Volume: $volume / $goal kg';
  }

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get activityTrend => 'Activity Trend';

  @override
  String get time => 'Time';

  @override
  String get volume => 'Volume';

  @override
  String get density => 'Density';

  @override
  String weeklyAverageVolume(Object volume) {
    return 'This week\'s average workout volume is ${volume}kg.';
  }

  @override
  String weeklyComparison(Object diff) {
    return 'Compared to last week: ${diff}kg';
  }

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get library => 'Library';

  @override
  String get analysis => 'Analysis';

  @override
  String get unknownPage => 'Unknown Page';

  @override
  String get fitMix => 'Lifto';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get selectDate => 'Select Date';

  @override
  String get planWorkout => 'Plan Workout';

  @override
  String get markRest => 'Mark as Rest Day';

  @override
  String get cancelRest => 'Cancel Rest Day';

  @override
  String get noWorkoutRecords => 'No workout records';

  @override
  String get workoutRecord => 'Workout Record';

  @override
  String totalVolume(Object volume) {
    return 'Total Volume: ${volume}kg';
  }

  @override
  String totalVolumeShort(Object volume) {
    return 'Total Volume ${volume}kg';
  }

  @override
  String andMore(Object count) {
    return 'and $count more';
  }

  @override
  String get todayWorkout => 'Today\'s Workout';

  @override
  String get restTimeSetting => 'Rest Time Setting';

  @override
  String get endWorkout => 'End Workout';

  @override
  String get endWorkoutConfirm => 'End workout and save the record?';

  @override
  String get endAndSaveWorkout => 'End & Save Workout';

  @override
  String get noWorkoutPlan =>
      'No workout plan for today.\nPlease create a plan in the calendar first.';

  @override
  String get noWorkoutPlanDesc =>
      'Tap \"Add Exercise\" button below\nto add exercises';

  @override
  String get skipRest => 'Skip Rest';

  @override
  String get restTimer => 'Rest Timer';

  @override
  String get adjustRestTime => 'Adjust Rest Time';

  @override
  String get workoutDuration => 'Workout Duration';

  @override
  String get restTimeRemaining => 'Rest Time Remaining';

  @override
  String seconds(Object count) {
    return '${count}s';
  }

  @override
  String get secondsUnit => 'sec';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get continueWorkout => 'Continue';

  @override
  String get quit => 'Quit';

  @override
  String get volumeByBodyPart => 'Volume by Body Part';

  @override
  String get monthlyWorkoutTime => 'Monthly Workout Time';

  @override
  String get noAnalysisData => 'No workout data to analyze.';

  @override
  String errorOccurred(Object error) {
    return 'Error: $error';
  }

  @override
  String hours(Object count) {
    return '$count hours';
  }

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get editExercise => 'Edit Exercise';

  @override
  String get exerciseName => 'Exercise Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved.';

  @override
  String get restDaySet => 'Set as rest day.';

  @override
  String get restDayUnset => 'Rest day setting has been removed.';

  @override
  String get saveFailed => 'Failed to save.';

  @override
  String loadFailed(Object error) {
    return 'Load failed: $error';
  }

  @override
  String get deleteExercise => 'Delete Exercise';

  @override
  String deleteExerciseConfirm(Object name) {
    return 'Delete \'$name\' exercise?';
  }

  @override
  String get deleteFailed => 'Delete failed.';

  @override
  String get libraryEmpty => 'Exercise library is empty.';

  @override
  String get profile => 'Profile';

  @override
  String get bodyInfo => 'Body Info';

  @override
  String get edit => 'Edit';

  @override
  String height(Object value) {
    return 'Height: $value cm';
  }

  @override
  String weight(Object value) {
    return 'Weight: $value kg';
  }

  @override
  String get workoutGoal => 'Workout Goal';

  @override
  String get monthlyWorkoutDays => 'Monthly Workout Days';

  @override
  String get monthlyTotalVolume => 'Monthly Total Volume';

  @override
  String get saveGoal => 'Save Goal';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get guest => 'Guest';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get systemSetting => 'System Setting';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get account => 'Account';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Do you want to logout?';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get allInOnePlace => 'All your workouts in one place';

  @override
  String get enterWeight => 'Please enter your weight.';

  @override
  String get enterHeight => 'Please enter your height.';

  @override
  String get requiredInfo =>
      'Please provide required information\nto start your workout.';

  @override
  String get weightLabel => 'Weight *';

  @override
  String get heightLabel => 'Height *';

  @override
  String get saveInfoFailed => 'Failed to save information.';

  @override
  String get import => 'Import';

  @override
  String added(Object text) {
    return 'Added: $text';
  }

  @override
  String get exerciseAdded => 'Exercise added.';

  @override
  String get reorderSaveFailed => 'Failed to save reorder.';

  @override
  String deleted(Object name) {
    return '$name deleted';
  }

  @override
  String get undo => 'Undo';

  @override
  String get addSet => 'Add Set';

  @override
  String get deleteSet => 'Delete Set';

  @override
  String get planYourWorkout => 'Plan your workout!';

  @override
  String setNumber(Object number) {
    return 'Set $number';
  }

  @override
  String get setLabel => 'Set';

  @override
  String get weightKg => 'Weight(kg)';

  @override
  String get reps => 'Reps';

  @override
  String get repsUnit => 'reps';

  @override
  String get completed => 'Done';

  @override
  String get notCompleted => 'Not Done';

  @override
  String get minOneSet => 'At least 1 set required.';

  @override
  String get enterRepsFirst => 'Enter target reps first';

  @override
  String get favorites => 'Favorites';

  @override
  String get chest => 'Chest';

  @override
  String get back => 'Back';

  @override
  String get legs => 'Legs';

  @override
  String get shoulders => 'Shoulders';

  @override
  String get arms => 'Arms';

  @override
  String get abs => 'Abs';

  @override
  String get cardio => 'Cardio';

  @override
  String get stretching => 'Stretching';

  @override
  String get fullBody => 'Full Body';

  @override
  String get all => 'All';

  @override
  String get bodyweight => 'Bodyweight';

  @override
  String get machine => 'Machine';

  @override
  String get barbell => 'Barbell';

  @override
  String get dumbbell => 'Dumbbell';

  @override
  String get cable => 'Cable';

  @override
  String get band => 'Band';

  @override
  String get searchExercise => 'Search for exercises';

  @override
  String get noExercises => 'No exercises found.';

  @override
  String get retry => 'Retry';

  @override
  String get addCustomExercise => 'Add Custom Exercise';

  @override
  String get customExerciseName => 'Exercise Name';

  @override
  String get selectBodyPart => 'Select Body Part';

  @override
  String get selectEquipment => 'Select Equipment';

  @override
  String get add => 'Add';

  @override
  String get pleaseEnterExerciseName => 'Please enter exercise name.';

  @override
  String get workoutPlan => 'Workout Plan';

  @override
  String get selectExercise => 'Select Exercise';

  @override
  String workoutInProgress(Object day, Object month, Object weekday) {
    return '$month/$day ($weekday) Working Out';
  }

  @override
  String exerciseCount(Object count) {
    return '$count exercises';
  }

  @override
  String get cannotChangeDateDuringWorkout =>
      'Cannot change date during workout';

  @override
  String get workoutCompleted => 'Workout completed! 🎉';

  @override
  String get editCompleted => 'Edit completed.';

  @override
  String get workoutCompletedTitle => 'Workout Complete';

  @override
  String get incompleteSetWarning =>
      'Some sets are not completed.\nDo you still want to complete the workout?';

  @override
  String get cancelTimer => 'Cancel Timer';

  @override
  String get rest => 'Rest';

  @override
  String get waiting => 'Wait';

  @override
  String get tempo => 'Tempo';

  @override
  String tempoStart(Object concentric, Object eccentric) {
    return 'Start Tempo ($eccentric/${concentric}s)';
  }

  @override
  String get memo => 'Memo';

  @override
  String get recentRecord => 'Recent Record';

  @override
  String get dayUnit => 'days';

  @override
  String get timesUnit => 'times';

  @override
  String get validWorkoutDaysGoal => 'Please enter a valid workout days goal.';

  @override
  String get validVolumeGoal => 'Please enter a valid volume goal.';

  @override
  String get goalSaved => 'Goal saved.';

  @override
  String get profilePhotoChanged => 'Profile photo changed.';

  @override
  String get profilePhotoDeleted => 'Profile photo deleted.';

  @override
  String get birthDate => 'Birth Date *';

  @override
  String get enterBirthDate => 'Please enter your birth date.';

  @override
  String get gender => 'Gender *';

  @override
  String get enterGender => 'Please select your gender.';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get next => 'Next';

  @override
  String get infoUsageNotice =>
      'This information is only used for workout recommendations.';

  @override
  String get analysisTitle => 'Analysis';

  @override
  String get totalVolumeLabel => 'Total Volume';

  @override
  String get bodyBalanceAnalysis => 'Body Balance Analysis';

  @override
  String get last30DaysSets => 'Sets by body part (last 30 days)';

  @override
  String get analysisResult => 'Analysis Result';

  @override
  String bodyPartAnalysisResult(
    Object strongest,
    Object strongestSets,
    Object weakest,
    Object weakestSets,
  ) {
    return 'You have high $strongest workout ratio ($strongestSets sets), and need more $weakest workouts ($weakestSets sets).';
  }

  @override
  String get focusNeeded => 'Focus Needed';

  @override
  String lowBodyPartWarning(Object parts) {
    return 'Your $parts workout ratio is low. Pay more attention for balance!';
  }

  @override
  String get goToSupplementExercise => 'Go to Supplement Exercise';

  @override
  String totalXpWeekly(Object total, Object weekly) {
    return 'Total $total XP · This week $weekly XP';
  }

  @override
  String streakMessage(Object days) {
    return '$days day streak! 🔥';
  }

  @override
  String get startWorkoutToday => 'Start your workout today!';

  @override
  String longestRecord(Object days) {
    return 'Longest: $days days';
  }

  @override
  String get createFirstStreak => 'Create your first streak';

  @override
  String get oneMinute => '1 min';

  @override
  String get oneMinute30Sec => '1 min 30 sec';

  @override
  String get twoMinutes => '2 min';

  @override
  String get threeMinutes => '3 min';

  @override
  String xpRemaining(int xp) {
    return '$xp XP left';
  }

  @override
  String get achievement => 'Achievements';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String get achievementUnlocked => '✅ Unlocked!';

  @override
  String get achievementLocked => '🔒 Locked';

  @override
  String get achieveFirst => 'Achieve your first badge!';

  @override
  String exerciseUnit(Object count) {
    return '$count';
  }

  @override
  String get exercise => 'Exercises';

  @override
  String get totalSets => 'Total Sets';

  @override
  String setsUnit(Object count) {
    return '$count sets';
  }

  @override
  String get startWorkoutNow => 'Start workout now';

  @override
  String get noRecentWorkout => 'No recent workout records';

  @override
  String level(Object level) {
    return 'Level $level';
  }

  @override
  String get leagueBronze => 'Bronze';

  @override
  String get leagueSilver => 'Silver';

  @override
  String get leagueGold => 'Gold';

  @override
  String get leaguePlatinum => 'Platinum';

  @override
  String get leagueDiamond => 'Diamond';

  @override
  String get leagueMaster => 'Master';

  @override
  String get completeLabel => 'Done';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get bodyPart => 'Body Part';

  @override
  String get equipment => 'Equipment';

  @override
  String get exerciseType => 'Type';

  @override
  String get customExercise => 'Custom Exercise';

  @override
  String get exerciseInstructions => 'Instructions';

  @override
  String get primaryMuscles => 'Primary Target Muscles';

  @override
  String get secondaryMuscles => 'Secondary Muscles';

  @override
  String get addToWorkoutPlan => 'Add to Workout Plan';

  @override
  String get achievementStreak3Title => 'Getting Started';

  @override
  String get achievementStreak3Desc => '3 days workout streak';

  @override
  String get achievementStreak7Title => 'Week Warrior';

  @override
  String get achievementStreak7Desc => '7 days workout streak';

  @override
  String get achievementStreak30Title => 'Monthly Miracle';

  @override
  String get achievementStreak30Desc => '30 days workout streak';

  @override
  String get achievementWorkout1Title => 'First Step';

  @override
  String get achievementWorkout1Desc => 'Complete first workout';

  @override
  String get achievementWorkout10Title => 'Habit Builder';

  @override
  String get achievementWorkout10Desc => 'Complete 10 workouts';

  @override
  String get achievementWorkout50Title => 'Fitness Enthusiast';

  @override
  String get achievementWorkout50Desc => 'Complete 50 workouts';

  @override
  String get achievementWorkout100Title => 'Hundred Club';

  @override
  String get achievementWorkout100Desc => 'Complete 100 workouts';

  @override
  String get achievementVolume10kTitle => 'Ten Thousand';

  @override
  String get achievementVolume10kDesc => 'Reach 10,000kg total volume';

  @override
  String get achievementVolume100kTitle => 'Hundred K Club';

  @override
  String get achievementVolume100kDesc => 'Reach 100,000kg total volume';

  @override
  String get achievementVolume1mTitle => 'Million Lifter';

  @override
  String get achievementVolume1mDesc => 'Reach 1,000,000kg total volume';

  @override
  String get achievementWeekendTitle => 'Weekend Warrior';

  @override
  String get achievementWeekendDesc => 'Workout on weekend';

  @override
  String exerciseSelected(String name) {
    return '$name exercise has been selected.';
  }

  @override
  String get upgradeTitle => 'Upgrade to Premium';

  @override
  String get unlockAllFeatures => 'Unlock all features';

  @override
  String get advancedAnalytics => 'Advanced Analytics';

  @override
  String get advancedAnalyticsDesc =>
      'Deep analysis of weekly, monthly, and yearly workout data.';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get removeAdsDesc => 'Focus on your workout without distractions.';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get cloudBackupDesc => 'Safely sync data across multiple devices.';

  @override
  String get startMonthly => 'Start with ₩9,900/month';

  @override
  String get cancelAnytime => 'You can cancel your subscription anytime.';

  @override
  String get powerShop => 'Power Shop';

  @override
  String get items => 'Items';

  @override
  String get streakFreeze => 'Streak Freeze';

  @override
  String get streakFreezeDesc => 'Keep your streak even if you take a day off';

  @override
  String get weeklyReport => 'Weekly Workout Report';

  @override
  String get weeklyReportDesc => 'This week workout analysis report';

  @override
  String get customization => 'Customization';

  @override
  String get darkPurpleTheme => 'Dark Purple Theme';

  @override
  String get purplePointTheme => 'Purple Point Theme';

  @override
  String get fireTheme => 'Fire Theme';

  @override
  String get orangeTheme => 'Burning Orange Theme';

  @override
  String get specialBadges => 'Special Badges';

  @override
  String get lightningBadge => 'Lightning Badge';

  @override
  String get specialBadgeDesc => 'Special badge displayed on profile';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get streakFreezeSuccess => 'Streak Freeze purchased! ❄️';

  @override
  String get insufficientPower => 'Insufficient Power 💪';

  @override
  String get weeklyReportTitle => '📊 Weekly Report';

  @override
  String get thisWeekPerformance => 'This Week Performance';

  @override
  String get allRecords => 'All Records';

  @override
  String get nextGoal => 'Next Goal';

  @override
  String levelAchievement(int level) {
    return 'Level $level Achievement';
  }

  @override
  String leaguePromotion(String league) {
    return '$league League';
  }

  @override
  String get encouragingMessage => 'You\'re doing great!';

  @override
  String get encouragingDesc =>
      'You can achieve your goals with consistent workouts';

  @override
  String get set => 'Set';

  @override
  String get done => 'Done';

  @override
  String get birthDateFormat => 'yyyy/MM/dd';

  @override
  String get workoutPlanEmpty => 'No workout plan';

  @override
  String get restingDay => 'Rest day';

  @override
  String get restingDayDesc =>
      'Today is a rest day.\nYou can change it with the \"Cancel Rest Day\" button';

  @override
  String get planWorkoutDesc =>
      'Tap the \"Plan Workout\" button below\nto add exercises';

  @override
  String get cancelRestDay => 'Cancel Rest Day';

  @override
  String get editWorkout => 'Edit Workout';

  @override
  String get addWorkout => 'Add Workout';

  @override
  String get editComplete => 'Edit Complete';

  @override
  String get minOneSetRequired => 'At least 1 set required';

  @override
  String addExercises(int count) {
    return 'Add $count exercises';
  }

  @override
  String get comingSoonMessage => 'Coming soon!';

  @override
  String owned(int count) {
    return 'Owned: $count';
  }

  @override
  String get xpEarned => 'XP Earned';

  @override
  String get powerEarned => 'Power Earned';

  @override
  String get totalRecords => 'Total Records';

  @override
  String get totalXp => 'Total XP';

  @override
  String get currentLevel => 'Current Level';

  @override
  String get currentPower => 'Current Power';
}

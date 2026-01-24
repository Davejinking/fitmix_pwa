// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Iron Log';

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
  String get volume => 'VOLUME';

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
  String get weekdayMonShort => 'M';

  @override
  String get weekdayTueShort => 'T';

  @override
  String get weekdayWedShort => 'W';

  @override
  String get weekdayThuShort => 'T';

  @override
  String get weekdayFriShort => 'F';

  @override
  String get weekdaySatShort => 'S';

  @override
  String get weekdaySunShort => 'S';

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
  String get operationalStatus => 'OPERATIONAL STATUS';

  @override
  String get weekLabel => 'WEEK';

  @override
  String get totalLoad => 'TOTAL LOAD';

  @override
  String get vsLast => 'VS PREV';

  @override
  String get sessionAvg => 'SESSION AVG';

  @override
  String get heartRate => 'HR';

  @override
  String get duration => 'DURATION';

  @override
  String get restTime => 'REST TIME';

  @override
  String get latestLogs => 'LATEST LOGS';

  @override
  String get noRecentWorkouts => 'NO RECENT WORKOUTS';

  @override
  String get startSession => 'Start Session';

  @override
  String get systemReady => 'SYSTEM READY';

  @override
  String get buildVersion => 'BUILD';

  @override
  String get calendarTitle => 'NEURAL CALENDAR';

  @override
  String get weekdayMonAbbr => 'MON';

  @override
  String get weekdayTueAbbr => 'TUE';

  @override
  String get weekdayWedAbbr => 'WED';

  @override
  String get weekdayThuAbbr => 'THU';

  @override
  String get weekdayFriAbbr => 'FRI';

  @override
  String get weekdaySatAbbr => 'SAT';

  @override
  String get weekdaySunAbbr => 'SUN';

  @override
  String get quickActionRoutine => 'ROUTINE';

  @override
  String get quickActionProgram => 'PROGRAM';

  @override
  String get quickActionPlan => 'PLAN';

  @override
  String get quickActionRest => 'REST';

  @override
  String get quickActionLog => 'LOG';

  @override
  String get fitMix => 'Iron Log';

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
  String get finishWorkoutTitle => 'Finish your workout?';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get continueWorkout => 'Continue';

  @override
  String get workoutWillBeSaved => 'All your progress will be saved';

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
  String get enterWeightAndReps => 'Please enter weight and reps';

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
  String get push => 'Push';

  @override
  String get pull => 'Pull';

  @override
  String get upper => 'Upper';

  @override
  String get lower => 'Lower';

  @override
  String get exercises => 'Exercises';

  @override
  String get weeklyStatus => 'Weekly Status';

  @override
  String get monthlyGoal => 'Monthly Goal';

  @override
  String get initiateWorkout => 'Start Workout';

  @override
  String get editSession => 'Edit Session';

  @override
  String get workouts => 'Workouts';

  @override
  String get totalVol => 'Total Vol';

  @override
  String get avgVol => 'Avg Vol';

  @override
  String get consistency => 'Consistency';

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
  String get kettlebell => 'Kettlebell';

  @override
  String get searchExercise => 'Search for exercises';

  @override
  String get exerciseSelect => 'EXERCISE SELECT';

  @override
  String get searchDatabase => 'SEARCH WORKOUT...';

  @override
  String get selectWorkout => 'SELECT WORKOUT';

  @override
  String get filterParameters => 'FILTER PARAMETERS';

  @override
  String get applyFilters => 'APPLY FILTERS';

  @override
  String get reset => 'RESET';

  @override
  String get targetMuscle => 'TARGET MUSCLE';

  @override
  String get equipmentType => 'EQUIPMENT TYPE';

  @override
  String get indexStatus => 'INDEX STATUS';

  @override
  String get statusReady => 'READY';

  @override
  String get availableUnits => 'AVAIL';

  @override
  String get searchRoutine => 'Search Routine';

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
  String exerciseCount(int count) {
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
  String get noRecentRecords => 'No recent records';

  @override
  String get workingOut => 'Working Out';

  @override
  String get setsCompleted => 'Sets Done';

  @override
  String get restTimeSettings => 'Rest Time Settings';

  @override
  String get showOnScreen => 'Show on Screen';

  @override
  String get showOnScreenDescription =>
      'Display rest timer prominently on screen';

  @override
  String get tapToAdjustTime => 'Tap to adjust time';

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
  String get set => 'Set';

  @override
  String get done => 'Done';

  @override
  String get collapseAll => 'Collapse';

  @override
  String get expandAll => 'Expand';

  @override
  String get reorder => 'Reorder';

  @override
  String get reorderExercises => 'Reorder Exercises';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get exerciseList => 'Exercises';

  @override
  String get birthDateFormat => 'yyyy/MM/dd';

  @override
  String exerciseSelected(String name) {
    return '$name exercise has been selected.';
  }

  @override
  String get nextGoal => 'Next Goal';

  @override
  String get insufficientPower => 'Insufficient Power 💪';

  @override
  String get lightningBadge => 'Lightning Badge';

  @override
  String get specialBadgeDesc => 'Special badge displayed on profile';

  @override
  String get streakFreeze => 'Streak Freeze';

  @override
  String get streakFreezeSuccess => 'Streak Freeze purchased! ❄️';

  @override
  String get weeklyReportTitle => '📊 Weekly Report';

  @override
  String get allRecords => 'All Records';

  @override
  String get items => 'Items';

  @override
  String get purplePointTheme => 'Purple Point Theme';

  @override
  String get startMonthly => 'Start with ₩9,900/month';

  @override
  String get advancedAnalytics => 'Advanced Analytics';

  @override
  String get thisWeekPerformance => 'This Week Performance';

  @override
  String get cloudBackup => 'Cloud Backup';

  @override
  String get upgradeTitle => 'Upgrade to Premium';

  @override
  String get unlockAllFeatures => 'Unlock all features';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get powerShop => 'Power Shop';

  @override
  String get weeklyReportDesc => 'This week workout analysis report';

  @override
  String get removeAdsDesc => 'Focus on your workout without distractions.';

  @override
  String get weeklyReport => 'Weekly Workout Report';

  @override
  String get customization => 'Customization';

  @override
  String get cloudBackupDesc => 'Safely sync data across multiple devices.';

  @override
  String get encouragingMessage => 'You\'re doing great!';

  @override
  String get cancelAnytime => 'You can cancel your subscription anytime.';

  @override
  String leaguePromotion(String league) {
    return '$league League';
  }

  @override
  String get encouragingDesc =>
      'You can achieve your goals with consistent workouts';

  @override
  String get advancedAnalyticsDesc =>
      'Deep analysis of weekly, monthly, and yearly workout data.';

  @override
  String get streakFreezeDesc => 'Keep your streak even if you take a day off';

  @override
  String get darkPurpleTheme => 'Dark Purple Theme';

  @override
  String get fireTheme => 'Fire Theme';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String levelAchievement(int level) {
    return 'Level $level Achievement';
  }

  @override
  String get specialBadges => 'Special Badges';

  @override
  String get orangeTheme => 'Burning Orange Theme';

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
  String get deleteExerciseTitle => 'Delete Exercise';

  @override
  String deleteExerciseMessage(String exerciseName) {
    return 'Deleting the last set will completely remove the \'$exerciseName\' exercise.\nAre you sure you want to delete it?';
  }

  @override
  String get delete => 'Delete';

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

  @override
  String get todayWorkoutPlan => 'Today\'s Workout Plan';

  @override
  String get thisWeekWorkout => 'This Week\'s Workout';

  @override
  String get thisMonthGoal => 'This Month\'s Goal';

  @override
  String streakDays(int days) {
    return '$days day streak';
  }

  @override
  String get workoutTimeLabel => 'Workout Time';

  @override
  String thisWeekCompleted(int count) {
    return 'This week $count/7 days completed';
  }

  @override
  String get workoutConsistency => 'Workout Consistency';

  @override
  String activityPastMonths(int months) {
    return 'Your activity over the past $months months';
  }

  @override
  String get heatmapLess => 'Less';

  @override
  String get heatmapMore => 'More';

  @override
  String get restDay => 'Rest Day';

  @override
  String dayStreak(int days) {
    return '$days Day Streak';
  }

  @override
  String daysCompleted(int completed, int total) {
    return '$completed/$total days completed';
  }

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String get addExerciseToPlan => 'Add exercises to plan your workout today';

  @override
  String get restDayMessage => 'Today is a rest day';

  @override
  String get workoutCompleteTitle => 'Workout Complete!';

  @override
  String get todayWorkoutTitle => 'Today\'s Workout';

  @override
  String exercisesCompleted(int completed, int total) {
    return '$completed/$total exercises completed';
  }

  @override
  String minutesUnit(int minutes) {
    return '$minutes min';
  }

  @override
  String get saveRoutine => 'Save Routine';

  @override
  String get loadRoutine => 'Load Routine';

  @override
  String get routines => 'Routines';

  @override
  String get routineName => 'Routine Name';

  @override
  String get enterRoutineName => 'Enter Name (e.g. Push A)';

  @override
  String get routineSaved => 'Routine Saved';

  @override
  String get routineLoaded => 'Routine Loaded';

  @override
  String get routineDeleted => 'Routine Deleted';

  @override
  String get deleteRoutine => 'Delete Routine';

  @override
  String deleteRoutineConfirm(Object name) {
    return 'Delete \'$name\' routine?';
  }

  @override
  String get noRoutines => 'No saved routines';

  @override
  String get loadThisRoutine => 'Start with this routine?';

  @override
  String get archiveRoutine => 'Archive Routine';

  @override
  String get createRoutine => 'Create New Routine';

  @override
  String get editRoutine => 'Edit Routine';

  @override
  String get createRoutineHint =>
      'Tap the button above to create your first routine';

  @override
  String get routineLimitReached => 'Routine Limit Reached';

  @override
  String routineLimitMessage(int limit) {
    return 'Free users can only store $limit routines.\nUpgrade to PRO for unlimited storage.';
  }

  @override
  String get upgradeToPro => 'Upgrade to PRO';

  @override
  String get upgradeToProShort => 'Upgrade';

  @override
  String get skip => 'Skip';

  @override
  String get onboardingTitle1 => 'Track Your Workouts';

  @override
  String get onboardingSubtitle1 =>
      'Easily record sets, weight, and reps\nAutomatic volume calculation';

  @override
  String get onboardingTitle2 => 'Tempo Guide';

  @override
  String get onboardingSubtitle2 =>
      'Train with precise tempo\nVoice, beep, and haptic guidance';

  @override
  String get onboardingTitle3 => 'Build Your Streak';

  @override
  String get onboardingSubtitle3 =>
      'Work out daily and build your record\nConsistency creates the best results';

  @override
  String get onboardingTitle4 => 'Track Your Progress';

  @override
  String get onboardingSubtitle4 =>
      'Check your growth with weekly and monthly stats\nMove towards your goals';

  @override
  String get exerciseAddedSuccessfully => 'Exercise added successfully';
}

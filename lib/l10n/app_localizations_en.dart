// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FitMix PS0';

  @override
  String greetingWithName(String name) {
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
  String workoutDaysGoal(int days, int goal) {
    return 'Workout Days: $days / $goal days';
  }

  @override
  String workoutVolumeGoal(String volume, String goal) {
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
  String weeklyAverageVolume(String volume) {
    return 'This week\'s average workout volume is ${volume}kg.';
  }

  @override
  String weeklyComparison(String diff) {
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
  String get fitMix => 'FitMix';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get selectDate => 'Select Date';

  @override
  String get planWorkout => 'Plan Workout';

  @override
  String get noWorkoutRecords => 'No workout records';

  @override
  String get workoutRecord => 'Workout Record';

  @override
  String totalVolume(String volume) {
    return 'Total Volume: ${volume}kg';
  }

  @override
  String andMore(int count) {
    return 'and $count more';
  }

  @override
  String get todayWorkout => 'Today\'s Workout';

  @override
  String get restTimeSetting => 'Rest Time Setting';

  @override
  String get endWorkout => 'End Workout';

  @override
  String get endWorkoutConfirm =>
      'Do you want to end the workout and save the record?';

  @override
  String get endAndSaveWorkout => 'End & Save Workout';

  @override
  String get noWorkoutPlan =>
      'No workout plan for today.\\nPlease create a plan in the calendar first.';

  @override
  String get skipRest => 'Skip Rest';

  @override
  String seconds(int count) {
    return '${count}s';
  }

  @override
  String get close => 'Close';

  @override
  String get volumeByBodyPart => 'Volume by Body Part';

  @override
  String get monthlyWorkoutTime => 'Monthly Workout Time';

  @override
  String get noAnalysisData => 'No workout data to analyze.';

  @override
  String errorOccurred(String error) {
    return 'Error: $error';
  }

  @override
  String hours(String count) {
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
  String get deleteExercise => 'Delete Exercise';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Delete \'$name\' exercise?';
  }

  @override
  String get saveFailed => 'Failed to save.';

  @override
  String get deleteFailed => 'Failed to delete.';

  @override
  String get libraryEmpty => 'Exercise library is empty.';

  @override
  String get profile => 'Profile';

  @override
  String get bodyInfo => 'Body Info';

  @override
  String get edit => 'Edit';

  @override
  String height(String value) {
    return 'Height: $value cm';
  }

  @override
  String weight(String value) {
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
}

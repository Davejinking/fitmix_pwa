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
}

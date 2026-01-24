import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Iron Log'**
  String get appName;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greetingWithName(Object name);

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @burnFit.
  ///
  /// In en, this message translates to:
  /// **'BURN FIT'**
  String get burnFit;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @updateNote.
  ///
  /// In en, this message translates to:
  /// **'September 22 Update Note'**
  String get updateNote;

  /// No description provided for @myGoal.
  ///
  /// In en, this message translates to:
  /// **'My Goal'**
  String get myGoal;

  /// No description provided for @createNow.
  ///
  /// In en, this message translates to:
  /// **'Create Now'**
  String get createNow;

  /// No description provided for @workoutDaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Workout Days: {days} / {goal} days'**
  String workoutDaysGoal(Object days, Object goal);

  /// No description provided for @workoutVolumeGoal.
  ///
  /// In en, this message translates to:
  /// **'Workout Volume: {volume} / {goal} kg'**
  String workoutVolumeGoal(Object goal, Object volume);

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @activityTrend.
  ///
  /// In en, this message translates to:
  /// **'Activity Trend'**
  String get activityTrend;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get volume;

  /// No description provided for @density.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get density;

  /// No description provided for @weeklyAverageVolume.
  ///
  /// In en, this message translates to:
  /// **'This week\'s average workout volume is {volume}kg.'**
  String weeklyAverageVolume(Object volume);

  /// No description provided for @weeklyComparison.
  ///
  /// In en, this message translates to:
  /// **'Compared to last week: {diff}kg'**
  String weeklyComparison(Object diff);

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @weekdayMonShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySunShort;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @unknownPage.
  ///
  /// In en, this message translates to:
  /// **'Unknown Page'**
  String get unknownPage;

  /// No description provided for @operationalStatus.
  ///
  /// In en, this message translates to:
  /// **'OPERATIONAL STATUS'**
  String get operationalStatus;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'WEEK'**
  String get weekLabel;

  /// No description provided for @totalLoad.
  ///
  /// In en, this message translates to:
  /// **'TOTAL LOAD'**
  String get totalLoad;

  /// No description provided for @vsLast.
  ///
  /// In en, this message translates to:
  /// **'VS PREV'**
  String get vsLast;

  /// No description provided for @sessionAvg.
  ///
  /// In en, this message translates to:
  /// **'SESSION AVG'**
  String get sessionAvg;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get heartRate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get duration;

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'REST TIME'**
  String get restTime;

  /// No description provided for @latestLogs.
  ///
  /// In en, this message translates to:
  /// **'LATEST LOGS'**
  String get latestLogs;

  /// No description provided for @noRecentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'NO RECENT WORKOUTS'**
  String get noRecentWorkouts;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @systemReady.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM READY'**
  String get systemReady;

  /// No description provided for @buildVersion.
  ///
  /// In en, this message translates to:
  /// **'BUILD'**
  String get buildVersion;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'NEURAL CALENDAR'**
  String get calendarTitle;

  /// No description provided for @weekdayMonAbbr.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get weekdayMonAbbr;

  /// No description provided for @weekdayTueAbbr.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get weekdayTueAbbr;

  /// No description provided for @weekdayWedAbbr.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get weekdayWedAbbr;

  /// No description provided for @weekdayThuAbbr.
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get weekdayThuAbbr;

  /// No description provided for @weekdayFriAbbr.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get weekdayFriAbbr;

  /// No description provided for @weekdaySatAbbr.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get weekdaySatAbbr;

  /// No description provided for @weekdaySunAbbr.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get weekdaySunAbbr;

  /// No description provided for @quickActionRoutine.
  ///
  /// In en, this message translates to:
  /// **'ROUTINE'**
  String get quickActionRoutine;

  /// No description provided for @quickActionProgram.
  ///
  /// In en, this message translates to:
  /// **'PROGRAM'**
  String get quickActionProgram;

  /// No description provided for @quickActionPlan.
  ///
  /// In en, this message translates to:
  /// **'PLAN'**
  String get quickActionPlan;

  /// No description provided for @quickActionRest.
  ///
  /// In en, this message translates to:
  /// **'REST'**
  String get quickActionRest;

  /// No description provided for @quickActionLog.
  ///
  /// In en, this message translates to:
  /// **'LOG'**
  String get quickActionLog;

  /// No description provided for @fitMix.
  ///
  /// In en, this message translates to:
  /// **'Iron Log'**
  String get fitMix;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @planWorkout.
  ///
  /// In en, this message translates to:
  /// **'Plan Workout'**
  String get planWorkout;

  /// No description provided for @markRest.
  ///
  /// In en, this message translates to:
  /// **'Mark as Rest Day'**
  String get markRest;

  /// No description provided for @cancelRest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Rest Day'**
  String get cancelRest;

  /// No description provided for @noWorkoutRecords.
  ///
  /// In en, this message translates to:
  /// **'No workout records'**
  String get noWorkoutRecords;

  /// No description provided for @workoutRecord.
  ///
  /// In en, this message translates to:
  /// **'Workout Record'**
  String get workoutRecord;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume: {volume}kg'**
  String totalVolume(Object volume);

  /// No description provided for @totalVolumeShort.
  ///
  /// In en, this message translates to:
  /// **'Total Volume {volume}kg'**
  String totalVolumeShort(Object volume);

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andMore(Object count);

  /// No description provided for @todayWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todayWorkout;

  /// No description provided for @restTimeSetting.
  ///
  /// In en, this message translates to:
  /// **'Rest Time Setting'**
  String get restTimeSetting;

  /// No description provided for @endWorkout.
  ///
  /// In en, this message translates to:
  /// **'End Workout'**
  String get endWorkout;

  /// No description provided for @endWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'End workout and save the record?'**
  String get endWorkoutConfirm;

  /// No description provided for @finishWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your workout?'**
  String get finishWorkoutTitle;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// No description provided for @continueWorkout.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWorkout;

  /// No description provided for @workoutWillBeSaved.
  ///
  /// In en, this message translates to:
  /// **'All your progress will be saved'**
  String get workoutWillBeSaved;

  /// No description provided for @endAndSaveWorkout.
  ///
  /// In en, this message translates to:
  /// **'End & Save Workout'**
  String get endAndSaveWorkout;

  /// No description provided for @noWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'No workout plan for today.\nPlease create a plan in the calendar first.'**
  String get noWorkoutPlan;

  /// No description provided for @noWorkoutPlanDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Exercise\" button below\nto add exercises'**
  String get noWorkoutPlanDesc;

  /// No description provided for @skipRest.
  ///
  /// In en, this message translates to:
  /// **'Skip Rest'**
  String get skipRest;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimer;

  /// No description provided for @adjustRestTime.
  ///
  /// In en, this message translates to:
  /// **'Adjust Rest Time'**
  String get adjustRestTime;

  /// No description provided for @workoutDuration.
  ///
  /// In en, this message translates to:
  /// **'Workout Duration'**
  String get workoutDuration;

  /// No description provided for @restTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Rest Time Remaining'**
  String get restTimeRemaining;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String seconds(Object count);

  /// No description provided for @secondsUnit.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondsUnit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @volumeByBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Volume by Body Part'**
  String get volumeByBodyPart;

  /// No description provided for @monthlyWorkoutTime.
  ///
  /// In en, this message translates to:
  /// **'Monthly Workout Time'**
  String get monthlyWorkoutTime;

  /// No description provided for @noAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'No workout data to analyze.'**
  String get noAnalysisData;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hours(Object count);

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saved;

  /// No description provided for @restDaySet.
  ///
  /// In en, this message translates to:
  /// **'Set as rest day.'**
  String get restDaySet;

  /// No description provided for @restDayUnset.
  ///
  /// In en, this message translates to:
  /// **'Rest day setting has been removed.'**
  String get restDayUnset;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save.'**
  String get saveFailed;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String loadFailed(Object error);

  /// No description provided for @deleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get deleteExercise;

  /// No description provided for @deleteExerciseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \'{name}\' exercise?'**
  String deleteExerciseConfirm(Object name);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed.'**
  String get deleteFailed;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Exercise library is empty.'**
  String get libraryEmpty;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @bodyInfo.
  ///
  /// In en, this message translates to:
  /// **'Body Info'**
  String get bodyInfo;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height: {value} cm'**
  String height(Object value);

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {value} kg'**
  String weight(Object value);

  /// No description provided for @workoutGoal.
  ///
  /// In en, this message translates to:
  /// **'Workout Goal'**
  String get workoutGoal;

  /// No description provided for @monthlyWorkoutDays.
  ///
  /// In en, this message translates to:
  /// **'Monthly Workout Days'**
  String get monthlyWorkoutDays;

  /// No description provided for @monthlyTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Monthly Total Volume'**
  String get monthlyTotalVolume;

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get saveGoal;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemSetting.
  ///
  /// In en, this message translates to:
  /// **'System Setting'**
  String get systemSetting;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @allInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'All your workouts in one place'**
  String get allInOnePlace;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight.'**
  String get enterWeight;

  /// No description provided for @enterHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height.'**
  String get enterHeight;

  /// No description provided for @requiredInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide required information\nto start your workout.'**
  String get requiredInfo;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight *'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height *'**
  String get heightLabel;

  /// No description provided for @saveInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save information.'**
  String get saveInfoFailed;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added: {text}'**
  String added(Object text);

  /// No description provided for @exerciseAdded.
  ///
  /// In en, this message translates to:
  /// **'Exercise added.'**
  String get exerciseAdded;

  /// No description provided for @reorderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save reorder.'**
  String get reorderSaveFailed;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String deleted(Object name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// No description provided for @deleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete Set'**
  String get deleteSet;

  /// No description provided for @planYourWorkout.
  ///
  /// In en, this message translates to:
  /// **'Plan your workout!'**
  String get planYourWorkout;

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String setNumber(Object number);

  /// No description provided for @setLabel.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setLabel;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight(kg)'**
  String get weightKg;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @repsUnit.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get repsUnit;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get completed;

  /// No description provided for @notCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not Done'**
  String get notCompleted;

  /// No description provided for @minOneSet.
  ///
  /// In en, this message translates to:
  /// **'At least 1 set required.'**
  String get minOneSet;

  /// No description provided for @enterRepsFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter target reps first'**
  String get enterRepsFirst;

  /// No description provided for @enterWeightAndReps.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight and reps'**
  String get enterWeightAndReps;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @abs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get abs;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @stretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get stretching;

  /// No description provided for @fullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get fullBody;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @pull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get pull;

  /// No description provided for @upper.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get upper;

  /// No description provided for @lower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lower;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @weeklyStatus.
  ///
  /// In en, this message translates to:
  /// **'Weekly Status'**
  String get weeklyStatus;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Goal'**
  String get monthlyGoal;

  /// No description provided for @initiateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get initiateWorkout;

  /// No description provided for @editSession.
  ///
  /// In en, this message translates to:
  /// **'Edit Session'**
  String get editSession;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @totalVol.
  ///
  /// In en, this message translates to:
  /// **'Total Vol'**
  String get totalVol;

  /// No description provided for @avgVol.
  ///
  /// In en, this message translates to:
  /// **'Avg Vol'**
  String get avgVol;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get bodyweight;

  /// No description provided for @machine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get machine;

  /// No description provided for @barbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get barbell;

  /// No description provided for @dumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get dumbbell;

  /// No description provided for @cable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get cable;

  /// No description provided for @band.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get band;

  /// No description provided for @kettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get kettlebell;

  /// No description provided for @searchExercise.
  ///
  /// In en, this message translates to:
  /// **'Search for exercises'**
  String get searchExercise;

  /// No description provided for @exerciseSelect.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE SELECT'**
  String get exerciseSelect;

  /// No description provided for @searchDatabase.
  ///
  /// In en, this message translates to:
  /// **'SEARCH WORKOUT...'**
  String get searchDatabase;

  /// No description provided for @selectWorkout.
  ///
  /// In en, this message translates to:
  /// **'SELECT WORKOUT'**
  String get selectWorkout;

  /// No description provided for @filterParameters.
  ///
  /// In en, this message translates to:
  /// **'FILTER PARAMETERS'**
  String get filterParameters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'APPLY FILTERS'**
  String get applyFilters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @targetMuscle.
  ///
  /// In en, this message translates to:
  /// **'TARGET MUSCLE'**
  String get targetMuscle;

  /// No description provided for @equipmentType.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT TYPE'**
  String get equipmentType;

  /// No description provided for @indexStatus.
  ///
  /// In en, this message translates to:
  /// **'INDEX STATUS'**
  String get indexStatus;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get statusReady;

  /// No description provided for @availableUnits.
  ///
  /// In en, this message translates to:
  /// **'AVAIL'**
  String get availableUnits;

  /// No description provided for @searchRoutine.
  ///
  /// In en, this message translates to:
  /// **'Search Routine'**
  String get searchRoutine;

  /// No description provided for @noExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises found.'**
  String get noExercises;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @addCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Exercise'**
  String get addCustomExercise;

  /// No description provided for @customExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get customExerciseName;

  /// No description provided for @selectBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Select Body Part'**
  String get selectBodyPart;

  /// No description provided for @selectEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select Equipment'**
  String get selectEquipment;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @pleaseEnterExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter exercise name.'**
  String get pleaseEnterExerciseName;

  /// No description provided for @workoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Workout Plan'**
  String get workoutPlan;

  /// No description provided for @selectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get selectExercise;

  /// No description provided for @workoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} ({weekday}) Working Out'**
  String workoutInProgress(Object day, Object month, Object weekday);

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exerciseCount(int count);

  /// No description provided for @cannotChangeDateDuringWorkout.
  ///
  /// In en, this message translates to:
  /// **'Cannot change date during workout'**
  String get cannotChangeDateDuringWorkout;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout completed! 🎉'**
  String get workoutCompleted;

  /// No description provided for @editCompleted.
  ///
  /// In en, this message translates to:
  /// **'Edit completed.'**
  String get editCompleted;

  /// No description provided for @workoutCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete'**
  String get workoutCompletedTitle;

  /// No description provided for @incompleteSetWarning.
  ///
  /// In en, this message translates to:
  /// **'Some sets are not completed.\nDo you still want to complete the workout?'**
  String get incompleteSetWarning;

  /// No description provided for @cancelTimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel Timer'**
  String get cancelTimer;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get waiting;

  /// No description provided for @tempo.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get tempo;

  /// No description provided for @tempoStart.
  ///
  /// In en, this message translates to:
  /// **'Start Tempo ({eccentric}/{concentric}s)'**
  String tempoStart(Object concentric, Object eccentric);

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @recentRecord.
  ///
  /// In en, this message translates to:
  /// **'Recent Record'**
  String get recentRecord;

  /// No description provided for @noRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'No recent records'**
  String get noRecentRecords;

  /// No description provided for @workingOut.
  ///
  /// In en, this message translates to:
  /// **'Working Out'**
  String get workingOut;

  /// No description provided for @setsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sets Done'**
  String get setsCompleted;

  /// No description provided for @restTimeSettings.
  ///
  /// In en, this message translates to:
  /// **'Rest Time Settings'**
  String get restTimeSettings;

  /// No description provided for @showOnScreen.
  ///
  /// In en, this message translates to:
  /// **'Show on Screen'**
  String get showOnScreen;

  /// No description provided for @showOnScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Display rest timer prominently on screen'**
  String get showOnScreenDescription;

  /// No description provided for @tapToAdjustTime.
  ///
  /// In en, this message translates to:
  /// **'Tap to adjust time'**
  String get tapToAdjustTime;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get dayUnit;

  /// No description provided for @timesUnit.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get timesUnit;

  /// No description provided for @validWorkoutDaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid workout days goal.'**
  String get validWorkoutDaysGoal;

  /// No description provided for @validVolumeGoal.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid volume goal.'**
  String get validVolumeGoal;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved.'**
  String get goalSaved;

  /// No description provided for @profilePhotoChanged.
  ///
  /// In en, this message translates to:
  /// **'Profile photo changed.'**
  String get profilePhotoChanged;

  /// No description provided for @profilePhotoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Profile photo deleted.'**
  String get profilePhotoDeleted;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date *'**
  String get birthDate;

  /// No description provided for @enterBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter your birth date.'**
  String get enterBirthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender *'**
  String get gender;

  /// No description provided for @enterGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender.'**
  String get enterGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @infoUsageNotice.
  ///
  /// In en, this message translates to:
  /// **'This information is only used for workout recommendations.'**
  String get infoUsageNotice;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTitle;

  /// No description provided for @totalVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolumeLabel;

  /// No description provided for @bodyBalanceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Body Balance Analysis'**
  String get bodyBalanceAnalysis;

  /// No description provided for @last30DaysSets.
  ///
  /// In en, this message translates to:
  /// **'Sets by body part (last 30 days)'**
  String get last30DaysSets;

  /// No description provided for @analysisResult.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get analysisResult;

  /// No description provided for @bodyPartAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'You have high {strongest} workout ratio ({strongestSets} sets), and need more {weakest} workouts ({weakestSets} sets).'**
  String bodyPartAnalysisResult(
    Object strongest,
    Object strongestSets,
    Object weakest,
    Object weakestSets,
  );

  /// No description provided for @focusNeeded.
  ///
  /// In en, this message translates to:
  /// **'Focus Needed'**
  String get focusNeeded;

  /// No description provided for @lowBodyPartWarning.
  ///
  /// In en, this message translates to:
  /// **'Your {parts} workout ratio is low. Pay more attention for balance!'**
  String lowBodyPartWarning(Object parts);

  /// No description provided for @goToSupplementExercise.
  ///
  /// In en, this message translates to:
  /// **'Go to Supplement Exercise'**
  String get goToSupplementExercise;

  /// No description provided for @totalXpWeekly.
  ///
  /// In en, this message translates to:
  /// **'Total {total} XP · This week {weekly} XP'**
  String totalXpWeekly(Object total, Object weekly);

  /// No description provided for @streakMessage.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak! 🔥'**
  String streakMessage(Object days);

  /// No description provided for @startWorkoutToday.
  ///
  /// In en, this message translates to:
  /// **'Start your workout today!'**
  String get startWorkoutToday;

  /// No description provided for @longestRecord.
  ///
  /// In en, this message translates to:
  /// **'Longest: {days} days'**
  String longestRecord(Object days);

  /// No description provided for @createFirstStreak.
  ///
  /// In en, this message translates to:
  /// **'Create your first streak'**
  String get createFirstStreak;

  /// No description provided for @oneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get oneMinute;

  /// No description provided for @oneMinute30Sec.
  ///
  /// In en, this message translates to:
  /// **'1 min 30 sec'**
  String get oneMinute30Sec;

  /// No description provided for @twoMinutes.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get twoMinutes;

  /// No description provided for @threeMinutes.
  ///
  /// In en, this message translates to:
  /// **'3 min'**
  String get threeMinutes;

  /// No description provided for @xpRemaining.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP left'**
  String xpRemaining(int xp);

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievement;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'✅ Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @achievementLocked.
  ///
  /// In en, this message translates to:
  /// **'🔒 Locked'**
  String get achievementLocked;

  /// No description provided for @achieveFirst.
  ///
  /// In en, this message translates to:
  /// **'Achieve your first badge!'**
  String get achieveFirst;

  /// No description provided for @exerciseUnit.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String exerciseUnit(Object count);

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercise;

  /// No description provided for @totalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get totalSets;

  /// No description provided for @setsUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsUnit(Object count);

  /// No description provided for @startWorkoutNow.
  ///
  /// In en, this message translates to:
  /// **'Start workout now'**
  String get startWorkoutNow;

  /// No description provided for @noRecentWorkout.
  ///
  /// In en, this message translates to:
  /// **'No recent workout records'**
  String get noRecentWorkout;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(Object level);

  /// No description provided for @leagueBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get leagueBronze;

  /// No description provided for @leagueSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get leagueSilver;

  /// No description provided for @leagueGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get leagueGold;

  /// No description provided for @leaguePlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get leaguePlatinum;

  /// No description provided for @leagueDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get leagueDiamond;

  /// No description provided for @leagueMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get leagueMaster;

  /// No description provided for @completeLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get completeLabel;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @bodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get bodyPart;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @exerciseType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exerciseType;

  /// No description provided for @customExercise.
  ///
  /// In en, this message translates to:
  /// **'Custom Exercise'**
  String get customExercise;

  /// No description provided for @exerciseInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get exerciseInstructions;

  /// No description provided for @primaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Primary Target Muscles'**
  String get primaryMuscles;

  /// No description provided for @secondaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get secondaryMuscles;

  /// No description provided for @addToWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to Workout Plan'**
  String get addToWorkoutPlan;

  /// No description provided for @achievementStreak3Title.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achievementStreak3Title;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'3 days workout streak'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak7Title.
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get achievementStreak7Title;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'7 days workout streak'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak30Title.
  ///
  /// In en, this message translates to:
  /// **'Monthly Miracle'**
  String get achievementStreak30Title;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In en, this message translates to:
  /// **'30 days workout streak'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementWorkout1Title.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achievementWorkout1Title;

  /// No description provided for @achievementWorkout1Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete first workout'**
  String get achievementWorkout1Desc;

  /// No description provided for @achievementWorkout10Title.
  ///
  /// In en, this message translates to:
  /// **'Habit Builder'**
  String get achievementWorkout10Title;

  /// No description provided for @achievementWorkout10Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 workouts'**
  String get achievementWorkout10Desc;

  /// No description provided for @achievementWorkout50Title.
  ///
  /// In en, this message translates to:
  /// **'Fitness Enthusiast'**
  String get achievementWorkout50Title;

  /// No description provided for @achievementWorkout50Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 workouts'**
  String get achievementWorkout50Desc;

  /// No description provided for @achievementWorkout100Title.
  ///
  /// In en, this message translates to:
  /// **'Hundred Club'**
  String get achievementWorkout100Title;

  /// No description provided for @achievementWorkout100Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 workouts'**
  String get achievementWorkout100Desc;

  /// No description provided for @achievementVolume10kTitle.
  ///
  /// In en, this message translates to:
  /// **'Ten Thousand'**
  String get achievementVolume10kTitle;

  /// No description provided for @achievementVolume10kDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 10,000kg total volume'**
  String get achievementVolume10kDesc;

  /// No description provided for @achievementVolume100kTitle.
  ///
  /// In en, this message translates to:
  /// **'Hundred K Club'**
  String get achievementVolume100kTitle;

  /// No description provided for @achievementVolume100kDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 100,000kg total volume'**
  String get achievementVolume100kDesc;

  /// No description provided for @achievementVolume1mTitle.
  ///
  /// In en, this message translates to:
  /// **'Million Lifter'**
  String get achievementVolume1mTitle;

  /// No description provided for @achievementVolume1mDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 1,000,000kg total volume'**
  String get achievementVolume1mDesc;

  /// No description provided for @achievementWeekendTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get achievementWeekendTitle;

  /// No description provided for @achievementWeekendDesc.
  ///
  /// In en, this message translates to:
  /// **'Workout on weekend'**
  String get achievementWeekendDesc;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @collapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapseAll;

  /// No description provided for @expandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandAll;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @reorderExercises.
  ///
  /// In en, this message translates to:
  /// **'Reorder Exercises'**
  String get reorderExercises;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @exerciseList.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exerciseList;

  /// No description provided for @birthDateFormat.
  ///
  /// In en, this message translates to:
  /// **'yyyy/MM/dd'**
  String get birthDateFormat;

  /// No description provided for @exerciseSelected.
  ///
  /// In en, this message translates to:
  /// **'{name} exercise has been selected.'**
  String exerciseSelected(String name);

  /// No description provided for @nextGoal.
  ///
  /// In en, this message translates to:
  /// **'Next Goal'**
  String get nextGoal;

  /// No description provided for @insufficientPower.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Power 💪'**
  String get insufficientPower;

  /// No description provided for @lightningBadge.
  ///
  /// In en, this message translates to:
  /// **'Lightning Badge'**
  String get lightningBadge;

  /// No description provided for @specialBadgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Special badge displayed on profile'**
  String get specialBadgeDesc;

  /// No description provided for @streakFreeze.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze'**
  String get streakFreeze;

  /// No description provided for @streakFreezeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze purchased! ❄️'**
  String get streakFreezeSuccess;

  /// No description provided for @weeklyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'📊 Weekly Report'**
  String get weeklyReportTitle;

  /// No description provided for @allRecords.
  ///
  /// In en, this message translates to:
  /// **'All Records'**
  String get allRecords;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @purplePointTheme.
  ///
  /// In en, this message translates to:
  /// **'Purple Point Theme'**
  String get purplePointTheme;

  /// No description provided for @startMonthly.
  ///
  /// In en, this message translates to:
  /// **'Start with ₩9,900/month'**
  String get startMonthly;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analytics'**
  String get advancedAnalytics;

  /// No description provided for @thisWeekPerformance.
  ///
  /// In en, this message translates to:
  /// **'This Week Performance'**
  String get thisWeekPerformance;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @upgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeTitle;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get unlockAllFeatures;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// No description provided for @powerShop.
  ///
  /// In en, this message translates to:
  /// **'Power Shop'**
  String get powerShop;

  /// No description provided for @weeklyReportDesc.
  ///
  /// In en, this message translates to:
  /// **'This week workout analysis report'**
  String get weeklyReportDesc;

  /// No description provided for @removeAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on your workout without distractions.'**
  String get removeAdsDesc;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Workout Report'**
  String get weeklyReport;

  /// No description provided for @customization.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customization;

  /// No description provided for @cloudBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Safely sync data across multiple devices.'**
  String get cloudBackupDesc;

  /// No description provided for @encouragingMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get encouragingMessage;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can cancel your subscription anytime.'**
  String get cancelAnytime;

  /// No description provided for @leaguePromotion.
  ///
  /// In en, this message translates to:
  /// **'{league} League'**
  String leaguePromotion(String league);

  /// No description provided for @encouragingDesc.
  ///
  /// In en, this message translates to:
  /// **'You can achieve your goals with consistent workouts'**
  String get encouragingDesc;

  /// No description provided for @advancedAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep analysis of weekly, monthly, and yearly workout data.'**
  String get advancedAnalyticsDesc;

  /// No description provided for @streakFreezeDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak even if you take a day off'**
  String get streakFreezeDesc;

  /// No description provided for @darkPurpleTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Purple Theme'**
  String get darkPurpleTheme;

  /// No description provided for @fireTheme.
  ///
  /// In en, this message translates to:
  /// **'Fire Theme'**
  String get fireTheme;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @levelAchievement.
  ///
  /// In en, this message translates to:
  /// **'Level {level} Achievement'**
  String levelAchievement(int level);

  /// No description provided for @specialBadges.
  ///
  /// In en, this message translates to:
  /// **'Special Badges'**
  String get specialBadges;

  /// No description provided for @orangeTheme.
  ///
  /// In en, this message translates to:
  /// **'Burning Orange Theme'**
  String get orangeTheme;

  /// No description provided for @workoutPlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No workout plan'**
  String get workoutPlanEmpty;

  /// No description provided for @restingDay.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get restingDay;

  /// No description provided for @restingDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Today is a rest day.\nYou can change it with the \"Cancel Rest Day\" button'**
  String get restingDayDesc;

  /// No description provided for @planWorkoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"Plan Workout\" button below\nto add exercises'**
  String get planWorkoutDesc;

  /// No description provided for @cancelRestDay.
  ///
  /// In en, this message translates to:
  /// **'Cancel Rest Day'**
  String get cancelRestDay;

  /// No description provided for @editWorkout.
  ///
  /// In en, this message translates to:
  /// **'Edit Workout'**
  String get editWorkout;

  /// No description provided for @addWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add Workout'**
  String get addWorkout;

  /// No description provided for @editComplete.
  ///
  /// In en, this message translates to:
  /// **'Edit Complete'**
  String get editComplete;

  /// No description provided for @minOneSetRequired.
  ///
  /// In en, this message translates to:
  /// **'At least 1 set required'**
  String get minOneSetRequired;

  /// No description provided for @deleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get deleteExerciseTitle;

  /// No description provided for @deleteExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleting the last set will completely remove the \'{exerciseName}\' exercise.\nAre you sure you want to delete it?'**
  String deleteExerciseMessage(String exerciseName);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addExercises.
  ///
  /// In en, this message translates to:
  /// **'Add {count} exercises'**
  String addExercises(int count);

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoonMessage;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned: {count}'**
  String owned(int count);

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'XP Earned'**
  String get xpEarned;

  /// No description provided for @powerEarned.
  ///
  /// In en, this message translates to:
  /// **'Power Earned'**
  String get powerEarned;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalRecords;

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// No description provided for @currentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get currentLevel;

  /// No description provided for @currentPower.
  ///
  /// In en, this message translates to:
  /// **'Current Power'**
  String get currentPower;

  /// No description provided for @todayWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout Plan'**
  String get todayWorkoutPlan;

  /// No description provided for @thisWeekWorkout.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Workout'**
  String get thisWeekWorkout;

  /// No description provided for @thisMonthGoal.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Goal'**
  String get thisMonthGoal;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String streakDays(int days);

  /// No description provided for @workoutTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout Time'**
  String get workoutTimeLabel;

  /// No description provided for @thisWeekCompleted.
  ///
  /// In en, this message translates to:
  /// **'This week {count}/7 days completed'**
  String thisWeekCompleted(int count);

  /// No description provided for @workoutConsistency.
  ///
  /// In en, this message translates to:
  /// **'Workout Consistency'**
  String get workoutConsistency;

  /// No description provided for @activityPastMonths.
  ///
  /// In en, this message translates to:
  /// **'Your activity over the past {months} months'**
  String activityPastMonths(int months);

  /// No description provided for @heatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// No description provided for @heatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get restDay;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{days} Day Streak'**
  String dayStreak(int days);

  /// No description provided for @daysCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} days completed'**
  String daysCompleted(int completed, int total);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// No description provided for @addExerciseToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add exercises to plan your workout today'**
  String get addExerciseToPlan;

  /// No description provided for @restDayMessage.
  ///
  /// In en, this message translates to:
  /// **'Today is a rest day'**
  String get restDayMessage;

  /// No description provided for @workoutCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete!'**
  String get workoutCompleteTitle;

  /// No description provided for @todayWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todayWorkoutTitle;

  /// No description provided for @exercisesCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} exercises completed'**
  String exercisesCompleted(int completed, int total);

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesUnit(int minutes);

  /// No description provided for @saveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save Routine'**
  String get saveRoutine;

  /// No description provided for @loadRoutine.
  ///
  /// In en, this message translates to:
  /// **'Load Routine'**
  String get loadRoutine;

  /// No description provided for @routines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routines;

  /// No description provided for @routineName.
  ///
  /// In en, this message translates to:
  /// **'Routine Name'**
  String get routineName;

  /// No description provided for @enterRoutineName.
  ///
  /// In en, this message translates to:
  /// **'Enter Name (e.g. Push A)'**
  String get enterRoutineName;

  /// No description provided for @routineSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine Saved'**
  String get routineSaved;

  /// No description provided for @routineLoaded.
  ///
  /// In en, this message translates to:
  /// **'Routine Loaded'**
  String get routineLoaded;

  /// No description provided for @routineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Routine Deleted'**
  String get routineDeleted;

  /// No description provided for @deleteRoutine.
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get deleteRoutine;

  /// No description provided for @deleteRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \'{name}\' routine?'**
  String deleteRoutineConfirm(Object name);

  /// No description provided for @noRoutines.
  ///
  /// In en, this message translates to:
  /// **'No saved routines'**
  String get noRoutines;

  /// No description provided for @loadThisRoutine.
  ///
  /// In en, this message translates to:
  /// **'Start with this routine?'**
  String get loadThisRoutine;

  /// No description provided for @archiveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Archive Routine'**
  String get archiveRoutine;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create New Routine'**
  String get createRoutine;

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get editRoutine;

  /// No description provided for @createRoutineHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to create your first routine'**
  String get createRoutineHint;

  /// No description provided for @routineLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Routine Limit Reached'**
  String get routineLimitReached;

  /// No description provided for @routineLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Free users can only store {limit} routines.\nUpgrade to PRO for unlimited storage.'**
  String routineLimitMessage(int limit);

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PRO'**
  String get upgradeToPro;

  /// No description provided for @upgradeToProShort.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeToProShort;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Workouts'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Easily record sets, weight, and reps\nAutomatic volume calculation'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Tempo Guide'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Train with precise tempo\nVoice, beep, and haptic guidance'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Build Your Streak'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Work out daily and build your record\nConsistency creates the best results'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Check your growth with weekly and monthly stats\nMove towards your goals'**
  String get onboardingSubtitle4;

  /// No description provided for @exerciseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Exercise added successfully'**
  String get exerciseAddedSuccessfully;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

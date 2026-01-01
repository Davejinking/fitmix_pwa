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
  /// In ko, this message translates to:
  /// **'Lifto'**
  String get appName;

  /// No description provided for @greetingWithName.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, {name}님'**
  String greetingWithName(Object name);

  /// No description provided for @defaultUser.
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get defaultUser;

  /// No description provided for @burnFit.
  ///
  /// In ko, this message translates to:
  /// **'BURN FIT'**
  String get burnFit;

  /// No description provided for @upgrade.
  ///
  /// In ko, this message translates to:
  /// **'업그레이드'**
  String get upgrade;

  /// No description provided for @updateNote.
  ///
  /// In ko, this message translates to:
  /// **'9월 22일 업데이트 노트'**
  String get updateNote;

  /// No description provided for @myGoal.
  ///
  /// In ko, this message translates to:
  /// **'내 목표'**
  String get myGoal;

  /// No description provided for @createNow.
  ///
  /// In ko, this message translates to:
  /// **'바로 만들기'**
  String get createNow;

  /// No description provided for @workoutDaysGoal.
  ///
  /// In ko, this message translates to:
  /// **'운동 일수: {days} / {goal} 일'**
  String workoutDaysGoal(Object days, Object goal);

  /// No description provided for @workoutVolumeGoal.
  ///
  /// In ko, this message translates to:
  /// **'운동 볼륨: {volume} / {goal} kg'**
  String workoutVolumeGoal(Object goal, Object volume);

  /// No description provided for @startWorkout.
  ///
  /// In ko, this message translates to:
  /// **'운동 시작하기'**
  String get startWorkout;

  /// No description provided for @activityTrend.
  ///
  /// In ko, this message translates to:
  /// **'운동량 변화'**
  String get activityTrend;

  /// No description provided for @time.
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get time;

  /// No description provided for @volume.
  ///
  /// In ko, this message translates to:
  /// **'볼륨'**
  String get volume;

  /// No description provided for @density.
  ///
  /// In ko, this message translates to:
  /// **'밀도'**
  String get density;

  /// No description provided for @weeklyAverageVolume.
  ///
  /// In ko, this message translates to:
  /// **'이번 주 평균 운동 볼륨은 {volume}kg 입니다.'**
  String weeklyAverageVolume(Object volume);

  /// No description provided for @weeklyComparison.
  ///
  /// In ko, this message translates to:
  /// **'저번 주 대비 {diff}kg'**
  String weeklyComparison(Object diff);

  /// No description provided for @weekdayMon.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get weekdaySun;

  /// No description provided for @home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In ko, this message translates to:
  /// **'캘린더'**
  String get calendar;

  /// No description provided for @library.
  ///
  /// In ko, this message translates to:
  /// **'라이브러리'**
  String get library;

  /// No description provided for @analysis.
  ///
  /// In ko, this message translates to:
  /// **'분석'**
  String get analysis;

  /// No description provided for @unknownPage.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 페이지'**
  String get unknownPage;

  /// No description provided for @fitMix.
  ///
  /// In ko, this message translates to:
  /// **'Lifto'**
  String get fitMix;

  /// No description provided for @editGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표 수정'**
  String get editGoal;

  /// No description provided for @selectDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜 선택'**
  String get selectDate;

  /// No description provided for @planWorkout.
  ///
  /// In ko, this message translates to:
  /// **'운동 계획하기'**
  String get planWorkout;

  /// No description provided for @markRest.
  ///
  /// In ko, this message translates to:
  /// **'운동 휴식하기'**
  String get markRest;

  /// No description provided for @cancelRest.
  ///
  /// In ko, this message translates to:
  /// **'운동 휴식 해제'**
  String get cancelRest;

  /// No description provided for @noWorkoutRecords.
  ///
  /// In ko, this message translates to:
  /// **'운동 기록이 없습니다'**
  String get noWorkoutRecords;

  /// No description provided for @workoutRecord.
  ///
  /// In ko, this message translates to:
  /// **'운동 기록'**
  String get workoutRecord;

  /// No description provided for @totalVolume.
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨: {volume}kg'**
  String totalVolume(Object volume);

  /// No description provided for @totalVolumeShort.
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨 {volume}kg'**
  String totalVolumeShort(Object volume);

  /// No description provided for @andMore.
  ///
  /// In ko, this message translates to:
  /// **'외 {count}개'**
  String andMore(Object count);

  /// No description provided for @todayWorkout.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운동'**
  String get todayWorkout;

  /// No description provided for @restTimeSetting.
  ///
  /// In ko, this message translates to:
  /// **'휴식 시간 설정'**
  String get restTimeSetting;

  /// No description provided for @endWorkout.
  ///
  /// In ko, this message translates to:
  /// **'운동 종료'**
  String get endWorkout;

  /// No description provided for @endWorkoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'운동을 종료하고 기록을 저장하시겠습니까?'**
  String get endWorkoutConfirm;

  /// No description provided for @endAndSaveWorkout.
  ///
  /// In ko, this message translates to:
  /// **'운동 종료 및 저장'**
  String get endAndSaveWorkout;

  /// No description provided for @noWorkoutPlan.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운동 계획이 없습니다.\n캘린더에서 먼저 계획을 세워주세요.'**
  String get noWorkoutPlan;

  /// No description provided for @noWorkoutPlanDesc.
  ///
  /// In ko, this message translates to:
  /// **'하단의 \"운동 추가\" 버튼을 눌러\n운동을 추가해보세요'**
  String get noWorkoutPlanDesc;

  /// No description provided for @skipRest.
  ///
  /// In ko, this message translates to:
  /// **'휴식 건너뛰기'**
  String get skipRest;

  /// No description provided for @restTimer.
  ///
  /// In ko, this message translates to:
  /// **'휴식 타이머'**
  String get restTimer;

  /// No description provided for @adjustRestTime.
  ///
  /// In ko, this message translates to:
  /// **'휴식 시간 조절'**
  String get adjustRestTime;

  /// No description provided for @workoutDuration.
  ///
  /// In ko, this message translates to:
  /// **'운동 시간'**
  String get workoutDuration;

  /// No description provided for @restTimeRemaining.
  ///
  /// In ko, this message translates to:
  /// **'휴식 시간 남음'**
  String get restTimeRemaining;

  /// No description provided for @seconds.
  ///
  /// In ko, this message translates to:
  /// **'{count}초'**
  String seconds(Object count);

  /// No description provided for @secondsUnit.
  ///
  /// In ko, this message translates to:
  /// **'초'**
  String get secondsUnit;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @continueWorkout.
  ///
  /// In ko, this message translates to:
  /// **'계속하기'**
  String get continueWorkout;

  /// No description provided for @quit.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get quit;

  /// No description provided for @volumeByBodyPart.
  ///
  /// In ko, this message translates to:
  /// **'부위별 총 볼륨'**
  String get volumeByBodyPart;

  /// No description provided for @monthlyWorkoutTime.
  ///
  /// In ko, this message translates to:
  /// **'월별 총 운동 시간'**
  String get monthlyWorkoutTime;

  /// No description provided for @noAnalysisData.
  ///
  /// In ko, this message translates to:
  /// **'분석할 운동 기록이 없습니다.'**
  String get noAnalysisData;

  /// No description provided for @errorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'오류 발생: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @hours.
  ///
  /// In ko, this message translates to:
  /// **'{count} 시간'**
  String hours(Object count);

  /// No description provided for @addExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 추가'**
  String get addExercise;

  /// No description provided for @editExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 수정'**
  String get editExercise;

  /// No description provided for @exerciseName.
  ///
  /// In ko, this message translates to:
  /// **'운동 이름'**
  String get exerciseName;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In ko, this message translates to:
  /// **'저장되었습니다.'**
  String get saved;

  /// No description provided for @saveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다.'**
  String get saveFailed;

  /// No description provided for @loadFailed.
  ///
  /// In ko, this message translates to:
  /// **'로드 실패: {error}'**
  String loadFailed(Object error);

  /// No description provided for @deleteExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 삭제'**
  String get deleteExercise;

  /// No description provided for @deleteExerciseConfirm.
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 운동을 삭제하시겠습니까?'**
  String deleteExerciseConfirm(Object name);

  /// No description provided for @deleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'삭제에 실패했습니다.'**
  String get deleteFailed;

  /// No description provided for @libraryEmpty.
  ///
  /// In ko, this message translates to:
  /// **'운동 라이브러리가 비어있습니다.'**
  String get libraryEmpty;

  /// No description provided for @profile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profile;

  /// No description provided for @bodyInfo.
  ///
  /// In ko, this message translates to:
  /// **'신체 정보'**
  String get bodyInfo;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @height.
  ///
  /// In ko, this message translates to:
  /// **'키: {value} cm'**
  String height(Object value);

  /// No description provided for @weight.
  ///
  /// In ko, this message translates to:
  /// **'몸무게: {value} kg'**
  String weight(Object value);

  /// No description provided for @workoutGoal.
  ///
  /// In ko, this message translates to:
  /// **'운동 목표'**
  String get workoutGoal;

  /// No description provided for @monthlyWorkoutDays.
  ///
  /// In ko, this message translates to:
  /// **'월별 운동 일수'**
  String get monthlyWorkoutDays;

  /// No description provided for @monthlyTotalVolume.
  ///
  /// In ko, this message translates to:
  /// **'월별 총 볼륨'**
  String get monthlyTotalVolume;

  /// No description provided for @saveGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표 저장'**
  String get saveGoal;

  /// No description provided for @selectFromGallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리에서 사진 선택'**
  String get selectFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 삭제'**
  String get deletePhoto;

  /// No description provided for @guest.
  ///
  /// In ko, this message translates to:
  /// **'게스트'**
  String get guest;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In ko, this message translates to:
  /// **'외관'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @systemSetting.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정'**
  String get systemSetting;

  /// No description provided for @light.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get dark;

  /// No description provided for @account.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account;

  /// No description provided for @appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 하시겠습니까?'**
  String get logoutConfirm;

  /// No description provided for @loginWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 로그인'**
  String get loginWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In ko, this message translates to:
  /// **'게스트로 계속하기'**
  String get continueAsGuest;

  /// No description provided for @allInOnePlace.
  ///
  /// In ko, this message translates to:
  /// **'운동의 모든 것을 한 곳에서'**
  String get allInOnePlace;

  /// No description provided for @enterWeight.
  ///
  /// In ko, this message translates to:
  /// **'몸무게를 입력해 주세요.'**
  String get enterWeight;

  /// No description provided for @enterHeight.
  ///
  /// In ko, this message translates to:
  /// **'키를 입력해 주세요.'**
  String get enterHeight;

  /// No description provided for @requiredInfo.
  ///
  /// In ko, this message translates to:
  /// **'운동을 시작하기 위해\n필수 정보를 알려주세요.'**
  String get requiredInfo;

  /// No description provided for @weightLabel.
  ///
  /// In ko, this message translates to:
  /// **'몸무게 *'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In ko, this message translates to:
  /// **'키 *'**
  String get heightLabel;

  /// No description provided for @saveInfoFailed.
  ///
  /// In ko, this message translates to:
  /// **'정보 저장에 실패했습니다.'**
  String get saveInfoFailed;

  /// No description provided for @import.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get import;

  /// No description provided for @added.
  ///
  /// In ko, this message translates to:
  /// **'추가됨: {text}'**
  String added(Object text);

  /// No description provided for @exerciseAdded.
  ///
  /// In ko, this message translates to:
  /// **'운동이 추가되었습니다.'**
  String get exerciseAdded;

  /// No description provided for @reorderSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'순서 변경 저장에 실패했습니다.'**
  String get reorderSaveFailed;

  /// No description provided for @deleted.
  ///
  /// In ko, this message translates to:
  /// **'{name} 삭제됨'**
  String deleted(Object name);

  /// No description provided for @undo.
  ///
  /// In ko, this message translates to:
  /// **'실행 취소'**
  String get undo;

  /// No description provided for @addSet.
  ///
  /// In ko, this message translates to:
  /// **'세트 추가'**
  String get addSet;

  /// No description provided for @deleteSet.
  ///
  /// In ko, this message translates to:
  /// **'세트 삭제'**
  String get deleteSet;

  /// No description provided for @planYourWorkout.
  ///
  /// In ko, this message translates to:
  /// **'운동을 직접 계획해보세요!'**
  String get planYourWorkout;

  /// No description provided for @setNumber.
  ///
  /// In ko, this message translates to:
  /// **'{number}세트'**
  String setNumber(Object number);

  /// No description provided for @setLabel.
  ///
  /// In ko, this message translates to:
  /// **'세트'**
  String get setLabel;

  /// No description provided for @weightKg.
  ///
  /// In ko, this message translates to:
  /// **'무게(kg)'**
  String get weightKg;

  /// No description provided for @reps.
  ///
  /// In ko, this message translates to:
  /// **'횟수'**
  String get reps;

  /// No description provided for @repsUnit.
  ///
  /// In ko, this message translates to:
  /// **'회'**
  String get repsUnit;

  /// No description provided for @completed.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get completed;

  /// No description provided for @notCompleted.
  ///
  /// In ko, this message translates to:
  /// **'미완료'**
  String get notCompleted;

  /// No description provided for @minOneSet.
  ///
  /// In ko, this message translates to:
  /// **'최소 1개의 세트가 필요합니다.'**
  String get minOneSet;

  /// No description provided for @enterRepsFirst.
  ///
  /// In ko, this message translates to:
  /// **'먼저 목표 횟수를 입력하세요'**
  String get enterRepsFirst;

  /// No description provided for @favorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favorites;

  /// No description provided for @chest.
  ///
  /// In ko, this message translates to:
  /// **'가슴'**
  String get chest;

  /// No description provided for @back.
  ///
  /// In ko, this message translates to:
  /// **'등'**
  String get back;

  /// No description provided for @legs.
  ///
  /// In ko, this message translates to:
  /// **'하체'**
  String get legs;

  /// No description provided for @shoulders.
  ///
  /// In ko, this message translates to:
  /// **'어깨'**
  String get shoulders;

  /// No description provided for @arms.
  ///
  /// In ko, this message translates to:
  /// **'팔'**
  String get arms;

  /// No description provided for @abs.
  ///
  /// In ko, this message translates to:
  /// **'복근'**
  String get abs;

  /// No description provided for @cardio.
  ///
  /// In ko, this message translates to:
  /// **'유산소'**
  String get cardio;

  /// No description provided for @stretching.
  ///
  /// In ko, this message translates to:
  /// **'스트레칭'**
  String get stretching;

  /// No description provided for @fullBody.
  ///
  /// In ko, this message translates to:
  /// **'전신'**
  String get fullBody;

  /// No description provided for @all.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get all;

  /// No description provided for @bodyweight.
  ///
  /// In ko, this message translates to:
  /// **'맨몸'**
  String get bodyweight;

  /// No description provided for @machine.
  ///
  /// In ko, this message translates to:
  /// **'머신'**
  String get machine;

  /// No description provided for @barbell.
  ///
  /// In ko, this message translates to:
  /// **'바벨'**
  String get barbell;

  /// No description provided for @dumbbell.
  ///
  /// In ko, this message translates to:
  /// **'덤벨'**
  String get dumbbell;

  /// No description provided for @cable.
  ///
  /// In ko, this message translates to:
  /// **'케이블'**
  String get cable;

  /// No description provided for @band.
  ///
  /// In ko, this message translates to:
  /// **'밴드'**
  String get band;

  /// No description provided for @searchExercise.
  ///
  /// In ko, this message translates to:
  /// **'찾으시는 운동을 검색해보세요.'**
  String get searchExercise;

  /// No description provided for @noExercises.
  ///
  /// In ko, this message translates to:
  /// **'운동이 없습니다.'**
  String get noExercises;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @addCustomExercise.
  ///
  /// In ko, this message translates to:
  /// **'커스텀 운동 추가'**
  String get addCustomExercise;

  /// No description provided for @customExerciseName.
  ///
  /// In ko, this message translates to:
  /// **'운동 이름'**
  String get customExerciseName;

  /// No description provided for @selectBodyPart.
  ///
  /// In ko, this message translates to:
  /// **'부위 선택'**
  String get selectBodyPart;

  /// No description provided for @selectEquipment.
  ///
  /// In ko, this message translates to:
  /// **'장비 선택'**
  String get selectEquipment;

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @pleaseEnterExerciseName.
  ///
  /// In ko, this message translates to:
  /// **'운동 이름을 입력해주세요.'**
  String get pleaseEnterExerciseName;

  /// No description provided for @workoutPlan.
  ///
  /// In ko, this message translates to:
  /// **'운동 계획'**
  String get workoutPlan;

  /// No description provided for @selectExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 선택'**
  String get selectExercise;

  /// No description provided for @workoutInProgress.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일 ({weekday}) 운동 중'**
  String workoutInProgress(Object day, Object month, Object weekday);

  /// No description provided for @exerciseCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 운동'**
  String exerciseCount(Object count);

  /// No description provided for @cannotChangeDateDuringWorkout.
  ///
  /// In ko, this message translates to:
  /// **'운동 중에는 날짜를 변경할 수 없습니다'**
  String get cannotChangeDateDuringWorkout;

  /// No description provided for @workoutCompleted.
  ///
  /// In ko, this message translates to:
  /// **'운동이 완료되었습니다! 🎉'**
  String get workoutCompleted;

  /// No description provided for @cancelTimer.
  ///
  /// In ko, this message translates to:
  /// **'타이머 취소'**
  String get cancelTimer;

  /// No description provided for @rest.
  ///
  /// In ko, this message translates to:
  /// **'휴식'**
  String get rest;

  /// No description provided for @waiting.
  ///
  /// In ko, this message translates to:
  /// **'대기'**
  String get waiting;

  /// No description provided for @tempo.
  ///
  /// In ko, this message translates to:
  /// **'템포'**
  String get tempo;

  /// No description provided for @tempoStart.
  ///
  /// In ko, this message translates to:
  /// **'템포 시작 ({eccentric}/{concentric}s)'**
  String tempoStart(Object concentric, Object eccentric);

  /// No description provided for @memo.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get memo;

  /// No description provided for @dayUnit.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get dayUnit;

  /// No description provided for @timesUnit.
  ///
  /// In ko, this message translates to:
  /// **'회'**
  String get timesUnit;

  /// No description provided for @validWorkoutDaysGoal.
  ///
  /// In ko, this message translates to:
  /// **'올바른 운동일수 목표를 입력하세요.'**
  String get validWorkoutDaysGoal;

  /// No description provided for @validVolumeGoal.
  ///
  /// In ko, this message translates to:
  /// **'올바른 볼륨 목표를 입력하세요.'**
  String get validVolumeGoal;

  /// No description provided for @goalSaved.
  ///
  /// In ko, this message translates to:
  /// **'목표가 저장되었습니다.'**
  String get goalSaved;

  /// No description provided for @profilePhotoChanged.
  ///
  /// In ko, this message translates to:
  /// **'프로필 사진이 변경되었습니다.'**
  String get profilePhotoChanged;

  /// No description provided for @profilePhotoDeleted.
  ///
  /// In ko, this message translates to:
  /// **'프로필 사진이 삭제되었습니다.'**
  String get profilePhotoDeleted;

  /// No description provided for @birthDate.
  ///
  /// In ko, this message translates to:
  /// **'생년월일 *'**
  String get birthDate;

  /// No description provided for @enterBirthDate.
  ///
  /// In ko, this message translates to:
  /// **'생년월일을 입력해 주세요.'**
  String get enterBirthDate;

  /// No description provided for @gender.
  ///
  /// In ko, this message translates to:
  /// **'성별 *'**
  String get gender;

  /// No description provided for @enterGender.
  ///
  /// In ko, this message translates to:
  /// **'성별을 알려주세요.'**
  String get enterGender;

  /// No description provided for @male.
  ///
  /// In ko, this message translates to:
  /// **'남성'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ko, this message translates to:
  /// **'여성'**
  String get female;

  /// No description provided for @next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get next;

  /// No description provided for @infoUsageNotice.
  ///
  /// In ko, this message translates to:
  /// **'입력 정보는 운동 추천 용도로만 사용합니다.'**
  String get infoUsageNotice;

  /// No description provided for @analysisTitle.
  ///
  /// In ko, this message translates to:
  /// **'분석'**
  String get analysisTitle;

  /// No description provided for @totalVolumeLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨'**
  String get totalVolumeLabel;

  /// No description provided for @bodyBalanceAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'신체 밸런스 분석'**
  String get bodyBalanceAnalysis;

  /// No description provided for @last30DaysSets.
  ///
  /// In ko, this message translates to:
  /// **'최근 30일 부위별 운동 세트 수'**
  String get last30DaysSets;

  /// No description provided for @analysisResult.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과'**
  String get analysisResult;

  /// No description provided for @bodyPartAnalysisResult.
  ///
  /// In ko, this message translates to:
  /// **'회원님은 현재 {strongest} 운동 비중이 높고({strongestSets}세트), {weakest} 운동이 부족합니다({weakestSets}세트).'**
  String bodyPartAnalysisResult(
    Object strongest,
    Object strongestSets,
    Object weakest,
    Object weakestSets,
  );

  /// No description provided for @focusNeeded.
  ///
  /// In ko, this message translates to:
  /// **'집중 공략 필요'**
  String get focusNeeded;

  /// No description provided for @lowBodyPartWarning.
  ///
  /// In ko, this message translates to:
  /// **'현재 {parts} 운동 비중이 낮습니다. 밸런스를 위해 조금 더 신경 써주세요!'**
  String lowBodyPartWarning(Object parts);

  /// No description provided for @goToSupplementExercise.
  ///
  /// In ko, this message translates to:
  /// **'보완 운동 하러 가기'**
  String get goToSupplementExercise;

  /// No description provided for @totalXpWeekly.
  ///
  /// In ko, this message translates to:
  /// **'총 {total} XP · 이번 주 {weekly} XP'**
  String totalXpWeekly(Object total, Object weekly);

  /// No description provided for @streakMessage.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 연속 운동 중! 🔥'**
  String streakMessage(Object days);

  /// No description provided for @startWorkoutToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘 운동을 시작해보세요!'**
  String get startWorkoutToday;

  /// No description provided for @longestRecord.
  ///
  /// In ko, this message translates to:
  /// **'최장 기록: {days}일'**
  String longestRecord(Object days);

  /// No description provided for @createFirstStreak.
  ///
  /// In ko, this message translates to:
  /// **'첫 스트릭을 만들어보세요'**
  String get createFirstStreak;

  /// No description provided for @oneMinute.
  ///
  /// In ko, this message translates to:
  /// **'1분'**
  String get oneMinute;

  /// No description provided for @oneMinute30Sec.
  ///
  /// In ko, this message translates to:
  /// **'1분30초'**
  String get oneMinute30Sec;

  /// No description provided for @twoMinutes.
  ///
  /// In ko, this message translates to:
  /// **'2분'**
  String get twoMinutes;

  /// No description provided for @threeMinutes.
  ///
  /// In ko, this message translates to:
  /// **'3분'**
  String get threeMinutes;

  /// No description provided for @xpRemaining.
  ///
  /// In ko, this message translates to:
  /// **'{xp} XP 남음'**
  String xpRemaining(Object xp);

  /// No description provided for @achievement.
  ///
  /// In ko, this message translates to:
  /// **'업적'**
  String get achievement;

  /// No description provided for @currentStreak.
  ///
  /// In ko, this message translates to:
  /// **'현재 스트릭'**
  String get currentStreak;

  /// No description provided for @totalWorkouts.
  ///
  /// In ko, this message translates to:
  /// **'총 운동'**
  String get totalWorkouts;

  /// No description provided for @achievementUnlocked.
  ///
  /// In ko, this message translates to:
  /// **'✅ 달성 완료!'**
  String get achievementUnlocked;

  /// No description provided for @achievementLocked.
  ///
  /// In ko, this message translates to:
  /// **'🔒 미달성'**
  String get achievementLocked;

  /// No description provided for @achieveFirst.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 업적을 달성해보세요!'**
  String get achieveFirst;

  /// No description provided for @exerciseUnit.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String exerciseUnit(Object count);

  /// No description provided for @exercise.
  ///
  /// In ko, this message translates to:
  /// **'운동'**
  String get exercise;

  /// No description provided for @totalSets.
  ///
  /// In ko, this message translates to:
  /// **'총 세트'**
  String get totalSets;

  /// No description provided for @setsUnit.
  ///
  /// In ko, this message translates to:
  /// **'{count}세트'**
  String setsUnit(Object count);

  /// No description provided for @startWorkoutNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 운동 시작하기'**
  String get startWorkoutNow;

  /// No description provided for @noRecentWorkout.
  ///
  /// In ko, this message translates to:
  /// **'최근 운동 기록이 없습니다'**
  String get noRecentWorkout;

  /// No description provided for @level.
  ///
  /// In ko, this message translates to:
  /// **'Level {level}'**
  String level(Object level);

  /// No description provided for @leagueBronze.
  ///
  /// In ko, this message translates to:
  /// **'브론즈'**
  String get leagueBronze;

  /// No description provided for @leagueSilver.
  ///
  /// In ko, this message translates to:
  /// **'실버'**
  String get leagueSilver;

  /// No description provided for @leagueGold.
  ///
  /// In ko, this message translates to:
  /// **'골드'**
  String get leagueGold;

  /// No description provided for @leaguePlatinum.
  ///
  /// In ko, this message translates to:
  /// **'플래티넘'**
  String get leaguePlatinum;

  /// No description provided for @leagueDiamond.
  ///
  /// In ko, this message translates to:
  /// **'다이아몬드'**
  String get leagueDiamond;

  /// No description provided for @leagueMaster.
  ///
  /// In ko, this message translates to:
  /// **'마스터'**
  String get leagueMaster;

  /// No description provided for @completeLabel.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get completeLabel;

  /// No description provided for @basicInfo.
  ///
  /// In ko, this message translates to:
  /// **'기본 정보'**
  String get basicInfo;

  /// No description provided for @bodyPart.
  ///
  /// In ko, this message translates to:
  /// **'부위'**
  String get bodyPart;

  /// No description provided for @equipment.
  ///
  /// In ko, this message translates to:
  /// **'장비'**
  String get equipment;

  /// No description provided for @exerciseType.
  ///
  /// In ko, this message translates to:
  /// **'타입'**
  String get exerciseType;

  /// No description provided for @customExercise.
  ///
  /// In ko, this message translates to:
  /// **'커스텀 운동'**
  String get customExercise;

  /// No description provided for @exerciseInstructions.
  ///
  /// In ko, this message translates to:
  /// **'운동 방법'**
  String get exerciseInstructions;

  /// No description provided for @primaryMuscles.
  ///
  /// In ko, this message translates to:
  /// **'주요 타겟 근육'**
  String get primaryMuscles;

  /// No description provided for @secondaryMuscles.
  ///
  /// In ko, this message translates to:
  /// **'보조 근육'**
  String get secondaryMuscles;

  /// No description provided for @addToWorkoutPlan.
  ///
  /// In ko, this message translates to:
  /// **'운동 계획에 추가'**
  String get addToWorkoutPlan;

  /// No description provided for @achievementStreak3Title.
  ///
  /// In ko, this message translates to:
  /// **'시작이 반이다'**
  String get achievementStreak3Title;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In ko, this message translates to:
  /// **'3일 연속 운동'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak7Title.
  ///
  /// In ko, this message translates to:
  /// **'일주일 전사'**
  String get achievementStreak7Title;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In ko, this message translates to:
  /// **'7일 연속 운동'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak30Title.
  ///
  /// In ko, this message translates to:
  /// **'한 달의 기적'**
  String get achievementStreak30Title;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In ko, this message translates to:
  /// **'30일 연속 운동'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementWorkout1Title.
  ///
  /// In ko, this message translates to:
  /// **'첫 발걸음'**
  String get achievementWorkout1Title;

  /// No description provided for @achievementWorkout1Desc.
  ///
  /// In ko, this message translates to:
  /// **'첫 운동 완료'**
  String get achievementWorkout1Desc;

  /// No description provided for @achievementWorkout10Title.
  ///
  /// In ko, this message translates to:
  /// **'습관 형성'**
  String get achievementWorkout10Title;

  /// No description provided for @achievementWorkout10Desc.
  ///
  /// In ko, this message translates to:
  /// **'10회 운동 완료'**
  String get achievementWorkout10Desc;

  /// No description provided for @achievementWorkout50Title.
  ///
  /// In ko, this message translates to:
  /// **'운동 마니아'**
  String get achievementWorkout50Title;

  /// No description provided for @achievementWorkout50Desc.
  ///
  /// In ko, this message translates to:
  /// **'50회 운동 완료'**
  String get achievementWorkout50Desc;

  /// No description provided for @achievementWorkout100Title.
  ///
  /// In ko, this message translates to:
  /// **'백전백승'**
  String get achievementWorkout100Title;

  /// No description provided for @achievementWorkout100Desc.
  ///
  /// In ko, this message translates to:
  /// **'100회 운동 완료'**
  String get achievementWorkout100Desc;

  /// No description provided for @achievementVolume10kTitle.
  ///
  /// In ko, this message translates to:
  /// **'만 킬로그램'**
  String get achievementVolume10kTitle;

  /// No description provided for @achievementVolume10kDesc.
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨 10,000kg 달성'**
  String get achievementVolume10kDesc;

  /// No description provided for @achievementVolume100kTitle.
  ///
  /// In ko, this message translates to:
  /// **'10만 클럽'**
  String get achievementVolume100kTitle;

  /// No description provided for @achievementVolume100kDesc.
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨 100,000kg 달성'**
  String get achievementVolume100kDesc;

  /// No description provided for @achievementVolume1mTitle.
  ///
  /// In ko, this message translates to:
  /// **'밀리언 리프터'**
  String get achievementVolume1mTitle;

  /// No description provided for @achievementVolume1mDesc.
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨 1,000,000kg 달성'**
  String get achievementVolume1mDesc;

  /// No description provided for @achievementWeekendTitle.
  ///
  /// In ko, this message translates to:
  /// **'주말 전사'**
  String get achievementWeekendTitle;

  /// No description provided for @achievementWeekendDesc.
  ///
  /// In ko, this message translates to:
  /// **'주말에 운동하기'**
  String get achievementWeekendDesc;

  /// No description provided for @exerciseSelected.
  ///
  /// In ko, this message translates to:
  /// **'{name} 운동이 선택되었습니다.'**
  String exerciseSelected(String name);

  /// No description provided for @upgradeTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄으로 업그레이드'**
  String get upgradeTitle;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In ko, this message translates to:
  /// **'모든 기능을 잠금 해제하세요'**
  String get unlockAllFeatures;

  /// No description provided for @advancedAnalytics.
  ///
  /// In ko, this message translates to:
  /// **'고급 분석'**
  String get advancedAnalytics;

  /// No description provided for @advancedAnalyticsDesc.
  ///
  /// In ko, this message translates to:
  /// **'주간, 월간, 연간 운동 데이터를 심층 분석하세요.'**
  String get advancedAnalyticsDesc;

  /// No description provided for @removeAds.
  ///
  /// In ko, this message translates to:
  /// **'광고 제거'**
  String get removeAds;

  /// No description provided for @removeAdsDesc.
  ///
  /// In ko, this message translates to:
  /// **'방해 없이 운동에만 집중하세요.'**
  String get removeAdsDesc;

  /// No description provided for @cloudBackup.
  ///
  /// In ko, this message translates to:
  /// **'클라우드 백업'**
  String get cloudBackup;

  /// No description provided for @cloudBackupDesc.
  ///
  /// In ko, this message translates to:
  /// **'여러 기기에서 데이터를 안전하게 동기화하세요.'**
  String get cloudBackupDesc;

  /// No description provided for @startMonthly.
  ///
  /// In ko, this message translates to:
  /// **'월 9,900원으로 시작하기'**
  String get startMonthly;

  /// No description provided for @cancelAnytime.
  ///
  /// In ko, this message translates to:
  /// **'언제든지 구독을 취소할 수 있습니다.'**
  String get cancelAnytime;

  /// No description provided for @powerShop.
  ///
  /// In ko, this message translates to:
  /// **'파워 상점'**
  String get powerShop;

  /// No description provided for @items.
  ///
  /// In ko, this message translates to:
  /// **'🛉 아이템'**
  String get items;

  /// No description provided for @streakFreeze.
  ///
  /// In ko, this message translates to:
  /// **'스트릭 프리즈'**
  String get streakFreeze;

  /// No description provided for @streakFreezeDesc.
  ///
  /// In ko, this message translates to:
  /// **'하루 쉬어도 스트릭 유지'**
  String get streakFreezeDesc;

  /// No description provided for @weeklyReport.
  ///
  /// In ko, this message translates to:
  /// **'�� 주간 운동 리포트'**
  String get weeklyReport;

  /// No description provided for @weeklyReportDesc.
  ///
  /// In ko, this message translates to:
  /// **'이번 주 운동 분석 리포트'**
  String get weeklyReportDesc;

  /// No description provided for @customization.
  ///
  /// In ko, this message translates to:
  /// **'🎨 커스터마이징 (준비 중)'**
  String get customization;

  /// No description provided for @darkPurpleTheme.
  ///
  /// In ko, this message translates to:
  /// **'다크 퍼플 테마'**
  String get darkPurpleTheme;

  /// No description provided for @purplePointTheme.
  ///
  /// In ko, this message translates to:
  /// **'보라색 포인트 테마'**
  String get purplePointTheme;

  /// No description provided for @fireTheme.
  ///
  /// In ko, this message translates to:
  /// **'파이어 테마'**
  String get fireTheme;

  /// No description provided for @orangeTheme.
  ///
  /// In ko, this message translates to:
  /// **'불타는 오렌지 테마'**
  String get orangeTheme;

  /// No description provided for @specialBadges.
  ///
  /// In ko, this message translates to:
  /// **'🏅 특별 뱃지 (준비 중)'**
  String get specialBadges;

  /// No description provided for @lightningBadge.
  ///
  /// In ko, this message translates to:
  /// **'번개 뱃지'**
  String get lightningBadge;

  /// No description provided for @specialBadgeDesc.
  ///
  /// In ko, this message translates to:
  /// **'프로필에 표시되는 특별 뱃지'**
  String get specialBadgeDesc;

  /// No description provided for @comingSoon.
  ///
  /// In ko, this message translates to:
  /// **'준비 중이에요!'**
  String get comingSoon;

  /// No description provided for @streakFreezeSuccess.
  ///
  /// In ko, this message translates to:
  /// **'스트릭 프리즈 구매 완료! ❄️'**
  String get streakFreezeSuccess;

  /// No description provided for @insufficientPower.
  ///
  /// In ko, this message translates to:
  /// **'파워가 부족해요 💪'**
  String get insufficientPower;

  /// No description provided for @weeklyReportTitle.
  ///
  /// In ko, this message translates to:
  /// **'📊 주간 리포트'**
  String get weeklyReportTitle;

  /// No description provided for @thisWeekPerformance.
  ///
  /// In ko, this message translates to:
  /// **'이번 주 성과'**
  String get thisWeekPerformance;

  /// No description provided for @allRecords.
  ///
  /// In ko, this message translates to:
  /// **'전체 기록'**
  String get allRecords;

  /// No description provided for @nextGoal.
  ///
  /// In ko, this message translates to:
  /// **'다음 목표'**
  String get nextGoal;

  /// No description provided for @levelAchievement.
  ///
  /// In ko, this message translates to:
  /// **'Level {level} 달성'**
  String levelAchievement(Object level);

  /// No description provided for @leaguePromotion.
  ///
  /// In ko, this message translates to:
  /// **'{league} 리그 승급'**
  String leaguePromotion(Object league);

  /// No description provided for @encouragingMessage.
  ///
  /// In ko, this message translates to:
  /// **'잘하고 있어요!'**
  String get encouragingMessage;

  /// No description provided for @encouragingDesc.
  ///
  /// In ko, this message translates to:
  /// **'꾸준히 운동하면 목표를 달성할 수 있어요'**
  String get encouragingDesc;
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

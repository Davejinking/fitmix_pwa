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

  /// 앱 이름
  ///
  /// In ko, this message translates to:
  /// **'FitMix PS0'**
  String get appName;

  /// 사용자 인사말
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, {name}님'**
  String greetingWithName(String name);

  /// 기본 사용자명
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get defaultUser;

  /// 브랜드명
  ///
  /// In ko, this message translates to:
  /// **'BURN FIT'**
  String get burnFit;

  /// 업그레이드 버튼
  ///
  /// In ko, this message translates to:
  /// **'업그레이드'**
  String get upgrade;

  /// 업데이트 배너 텍스트
  ///
  /// In ko, this message translates to:
  /// **'9월 22일 업데이트 노트'**
  String get updateNote;

  /// 목표 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'내 목표'**
  String get myGoal;

  /// 목표 생성 버튼
  ///
  /// In ko, this message translates to:
  /// **'바로 만들기'**
  String get createNow;

  /// 운동 일수 목표 표시
  ///
  /// In ko, this message translates to:
  /// **'운동 일수: {days} / {goal} 일'**
  String workoutDaysGoal(int days, int goal);

  /// 운동 볼륨 목표 표시
  ///
  /// In ko, this message translates to:
  /// **'운동 볼륨: {volume} / {goal} kg'**
  String workoutVolumeGoal(String volume, String goal);

  /// 운동 시작 버튼
  ///
  /// In ko, this message translates to:
  /// **'운동 시작하기'**
  String get startWorkout;

  /// 활동 추세 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'운동량 변화'**
  String get activityTrend;

  /// 시간 필터 탭
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get time;

  /// 볼륨 필터 탭
  ///
  /// In ko, this message translates to:
  /// **'볼륨'**
  String get volume;

  /// 밀도 필터 탭
  ///
  /// In ko, this message translates to:
  /// **'밀도'**
  String get density;

  /// 주간 평균 볼륨 텍스트
  ///
  /// In ko, this message translates to:
  /// **'이번 주 평균 운동 볼륨은 {volume}kg 입니다.'**
  String weeklyAverageVolume(String volume);

  /// 주간 비교 텍스트
  ///
  /// In ko, this message translates to:
  /// **'저번 주 대비 {diff}kg'**
  String weeklyComparison(String diff);

  /// 요일: 월요일
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get weekdayMon;

  /// 요일: 화요일
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get weekdayTue;

  /// 요일: 수요일
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get weekdayWed;

  /// 요일: 목요일
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get weekdayThu;

  /// 요일: 금요일
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get weekdayFri;

  /// 요일: 토요일
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get weekdaySat;

  /// 요일: 일요일
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get weekdaySun;

  /// 홈 탭
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// 캘린더 탭
  ///
  /// In ko, this message translates to:
  /// **'캘린더'**
  String get calendar;

  /// 라이브러리 탭
  ///
  /// In ko, this message translates to:
  /// **'라이브러리'**
  String get library;

  /// 분석 탭
  ///
  /// In ko, this message translates to:
  /// **'분석'**
  String get analysis;

  /// 알 수 없는 페이지 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 페이지'**
  String get unknownPage;

  /// 앱 이름 (짧은 버전)
  ///
  /// In ko, this message translates to:
  /// **'FitMix'**
  String get fitMix;

  /// 목표 수정 버튼
  ///
  /// In ko, this message translates to:
  /// **'목표 수정'**
  String get editGoal;

  /// 날짜 선택 모달 제목
  ///
  /// In ko, this message translates to:
  /// **'가는 날'**
  String get selectDate;

  /// 운동 계획하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'운동 계획하기'**
  String get planWorkout;

  /// 운동 기록 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동 기록이 없습니다'**
  String get noWorkoutRecords;

  /// 운동 기록 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 기록'**
  String get workoutRecord;

  /// 총 볼륨 표시
  ///
  /// In ko, this message translates to:
  /// **'총 볼륨: {volume}kg'**
  String totalVolume(String volume);

  /// 추가 항목 개수
  ///
  /// In ko, this message translates to:
  /// **'외 {count}개'**
  String andMore(int count);

  /// 오늘의 운동 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운동'**
  String get todayWorkout;

  /// 휴식 시간 설정 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'휴식 시간 설정'**
  String get restTimeSetting;

  /// 운동 종료 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 종료'**
  String get endWorkout;

  /// 운동 종료 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동을 종료하고 기록을 저장하시겠습니까?'**
  String get endWorkoutConfirm;

  /// 운동 종료 버튼
  ///
  /// In ko, this message translates to:
  /// **'운동 종료 및 저장'**
  String get endAndSaveWorkout;

  /// 운동 계획 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'오늘의 운동 계획이 없습니다.\\n캘린더에서 먼저 계획을 세워주세요.'**
  String get noWorkoutPlan;

  /// 휴식 건너뛰기 버튼
  ///
  /// In ko, this message translates to:
  /// **'휴식 건너뛰기'**
  String get skipRest;

  /// 초 단위
  ///
  /// In ko, this message translates to:
  /// **'{count}초'**
  String seconds(int count);

  /// 닫기 버튼
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// 부위별 볼륨 차트 제목
  ///
  /// In ko, this message translates to:
  /// **'부위별 총 볼륨'**
  String get volumeByBodyPart;

  /// 월별 운동 시간 차트 제목
  ///
  /// In ko, this message translates to:
  /// **'월별 총 운동 시간'**
  String get monthlyWorkoutTime;

  /// 분석 데이터 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'분석할 운동 기록이 없습니다.'**
  String get noAnalysisData;

  /// 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'오류 발생: {error}'**
  String errorOccurred(String error);

  /// 시간 단위
  ///
  /// In ko, this message translates to:
  /// **'{count} 시간'**
  String hours(String count);

  /// 운동 추가 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 추가'**
  String get addExercise;

  /// 운동 수정 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 수정'**
  String get editExercise;

  /// 운동 이름 입력 필드
  ///
  /// In ko, this message translates to:
  /// **'운동 이름'**
  String get exerciseName;

  /// 취소 버튼
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// 저장 버튼
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// 운동 삭제 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 삭제'**
  String get deleteExercise;

  /// 운동 삭제 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 운동을 삭제하시겠습니까?'**
  String deleteExerciseConfirm(String name);

  /// 저장 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다.'**
  String get saveFailed;

  /// 삭제 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'삭제에 실패했습니다.'**
  String get deleteFailed;

  /// 라이브러리 비어있음 메시지
  ///
  /// In ko, this message translates to:
  /// **'운동 라이브러리가 비어있습니다.'**
  String get libraryEmpty;

  /// 프로필 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profile;

  /// 신체 정보 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'신체 정보'**
  String get bodyInfo;

  /// 수정 버튼
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// 키 표시
  ///
  /// In ko, this message translates to:
  /// **'키: {value} cm'**
  String height(String value);

  /// 몸무게 표시
  ///
  /// In ko, this message translates to:
  /// **'몸무게: {value} kg'**
  String weight(String value);

  /// 운동 목표 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'운동 목표'**
  String get workoutGoal;

  /// 월별 운동 일수 레이블
  ///
  /// In ko, this message translates to:
  /// **'월별 운동 일수'**
  String get monthlyWorkoutDays;

  /// 월별 총 볼륨 레이블
  ///
  /// In ko, this message translates to:
  /// **'월별 총 볼륨'**
  String get monthlyTotalVolume;

  /// 목표 저장 버튼
  ///
  /// In ko, this message translates to:
  /// **'목표 저장'**
  String get saveGoal;

  /// 갤러리 선택 옵션
  ///
  /// In ko, this message translates to:
  /// **'갤러리에서 사진 선택'**
  String get selectFromGallery;

  /// 사진 삭제 옵션
  ///
  /// In ko, this message translates to:
  /// **'사진 삭제'**
  String get deletePhoto;

  /// 게스트 사용자
  ///
  /// In ko, this message translates to:
  /// **'게스트'**
  String get guest;

  /// 설정 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// 외관 섹션
  ///
  /// In ko, this message translates to:
  /// **'외관'**
  String get appearance;

  /// 테마 설정
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// 시스템 설정 옵션
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정'**
  String get systemSetting;

  /// 라이트 테마
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get light;

  /// 다크 테마
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get dark;

  /// 계정 섹션
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account;

  /// 앱 정보 섹션
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// 버전 레이블
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// 로그아웃 버튼
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// 로그아웃 확인 메시지
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 하시겠습니까?'**
  String get logoutConfirm;
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

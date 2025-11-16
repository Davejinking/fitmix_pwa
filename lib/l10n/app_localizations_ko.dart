// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'FitMix PS0';

  @override
  String greetingWithName(String name) {
    return '안녕하세요, $name님';
  }

  @override
  String get defaultUser => '사용자';

  @override
  String get burnFit => 'BURN FIT';

  @override
  String get upgrade => '업그레이드';

  @override
  String get updateNote => '9월 22일 업데이트 노트';

  @override
  String get myGoal => '내 목표';

  @override
  String get createNow => '바로 만들기';

  @override
  String workoutDaysGoal(int days, int goal) {
    return '운동 일수: $days / $goal 일';
  }

  @override
  String workoutVolumeGoal(String volume, String goal) {
    return '운동 볼륨: $volume / $goal kg';
  }

  @override
  String get startWorkout => '운동 시작하기';

  @override
  String get activityTrend => '운동량 변화';

  @override
  String get time => '시간';

  @override
  String get volume => '볼륨';

  @override
  String get density => '밀도';

  @override
  String weeklyAverageVolume(String volume) {
    return '이번 주 평균 운동 볼륨은 ${volume}kg 입니다.';
  }

  @override
  String weeklyComparison(String diff) {
    return '저번 주 대비 ${diff}kg';
  }

  @override
  String get weekdayMon => '월';

  @override
  String get weekdayTue => '화';

  @override
  String get weekdayWed => '수';

  @override
  String get weekdayThu => '목';

  @override
  String get weekdayFri => '금';

  @override
  String get weekdaySat => '토';

  @override
  String get weekdaySun => '일';

  @override
  String get home => '홈';

  @override
  String get calendar => '캘린더';

  @override
  String get library => '라이브러리';

  @override
  String get analysis => '분석';

  @override
  String get unknownPage => '알 수 없는 페이지';

  @override
  String get fitMix => 'FitMix';

  @override
  String get editGoal => '목표 수정';
}

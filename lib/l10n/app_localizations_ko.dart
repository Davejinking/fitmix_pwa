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

  @override
  String get selectDate => '가는 날';

  @override
  String get planWorkout => '운동 계획하기';

  @override
  String get noWorkoutRecords => '운동 기록이 없습니다';

  @override
  String get workoutRecord => '운동 기록';

  @override
  String totalVolume(String volume) {
    return '총 볼륨: ${volume}kg';
  }

  @override
  String andMore(int count) {
    return '외 $count개';
  }

  @override
  String get todayWorkout => '오늘의 운동';

  @override
  String get restTimeSetting => '휴식 시간 설정';

  @override
  String get endWorkout => '운동 종료';

  @override
  String get endWorkoutConfirm => '운동을 종료하고 기록을 저장하시겠습니까?';

  @override
  String get endAndSaveWorkout => '운동 종료 및 저장';

  @override
  String get noWorkoutPlan => '오늘의 운동 계획이 없습니다.\\n캘린더에서 먼저 계획을 세워주세요.';

  @override
  String get skipRest => '휴식 건너뛰기';

  @override
  String get restTimer => '휴식 타이머';

  @override
  String get adjustRestTime => '휴식 시간 조절';

  @override
  String get workoutDuration => '운동 시간';

  @override
  String get restTimeRemaining => '휴식 시간 남음';

  @override
  String seconds(int count) {
    return '$count초';
  }

  @override
  String get close => '닫기';

  @override
  String get volumeByBodyPart => '부위별 총 볼륨';

  @override
  String get monthlyWorkoutTime => '월별 총 운동 시간';

  @override
  String get noAnalysisData => '분석할 운동 기록이 없습니다.';

  @override
  String errorOccurred(String error) {
    return '오류 발생: $error';
  }

  @override
  String hours(String count) {
    return '$count 시간';
  }

  @override
  String get addExercise => '운동 추가';

  @override
  String get editExercise => '운동 수정';

  @override
  String get exerciseName => '운동 이름';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get deleteExercise => '운동 삭제';

  @override
  String deleteExerciseConfirm(String name) {
    return '\'$name\' 운동을 삭제하시겠습니까?';
  }

  @override
  String get saveFailed => '저장에 실패했습니다.';

  @override
  String get deleteFailed => '삭제에 실패했습니다.';

  @override
  String get libraryEmpty => '운동 라이브러리가 비어있습니다.';

  @override
  String get profile => '프로필';

  @override
  String get bodyInfo => '신체 정보';

  @override
  String get edit => '수정';

  @override
  String height(String value) {
    return '키: $value cm';
  }

  @override
  String weight(String value) {
    return '몸무게: $value kg';
  }

  @override
  String get workoutGoal => '운동 목표';

  @override
  String get monthlyWorkoutDays => '월별 운동 일수';

  @override
  String get monthlyTotalVolume => '월별 총 볼륨';

  @override
  String get saveGoal => '목표 저장';

  @override
  String get selectFromGallery => '갤러리에서 사진 선택';

  @override
  String get deletePhoto => '사진 삭제';

  @override
  String get guest => '게스트';

  @override
  String get settings => '설정';

  @override
  String get appearance => '외관';

  @override
  String get theme => '테마';

  @override
  String get systemSetting => '시스템 설정';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get account => '계정';

  @override
  String get appInfo => '앱 정보';

  @override
  String get version => '버전';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirm => '로그아웃 하시겠습니까?';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get enterWeight => '몸무게를 입력해 주세요.';

  @override
  String get enterHeight => '키를 입력해 주세요.';

  @override
  String get requiredInfo => '운동을 시작하기 위해\\n필수 정보를 알려주세요.';

  @override
  String get weightLabel => '몸무게 *';

  @override
  String get heightLabel => '키 *';

  @override
  String get saveInfoFailed => '정보 저장에 실패했습니다.';

  @override
  String get import => '가져오기';

  @override
  String added(String text) {
    return '추가됨: $text';
  }

  @override
  String get exerciseAdded => '운동이 추가되었습니다.';

  @override
  String get reorderSaveFailed => '순서 변경 저장에 실패했습니다.';

  @override
  String deleted(String name) {
    return '$name 삭제됨';
  }

  @override
  String get undo => '실행 취소';

  @override
  String get addSet => '세트 추가';

  @override
  String get planYourWorkout => '운동을 직접 계획해보세요!';

  @override
  String setNumber(int number) {
    return '$number세트';
  }

  @override
  String get weightKg => '무게(kg)';

  @override
  String get reps => '횟수';

  @override
  String get minOneSet => '최소 1개의 세트가 필요합니다.';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get chest => '가슴';

  @override
  String get back => '등';

  @override
  String get legs => '하체';

  @override
  String get shoulders => '어깨';

  @override
  String get arms => '팔';

  @override
  String get abs => '복근';

  @override
  String get cardio => '유산소';

  @override
  String get stretching => '스트레칭';

  @override
  String get fullBody => '전신';

  @override
  String get all => '전체';

  @override
  String get bodyweight => '맨몸';

  @override
  String get machine => '머신';

  @override
  String get barbell => '바벨';

  @override
  String get dumbbell => '덤벨';

  @override
  String get cable => '케이블';

  @override
  String get band => '밴드';

  @override
  String get searchExercise => '찾으시는 운동을 검색해보세요.';

  @override
  String get noExercises => '운동이 없습니다.';

  @override
  String get retry => '다시 시도';

  @override
  String get addCustomExercise => '커스텀 운동 추가';

  @override
  String get customExerciseName => '운동 이름';

  @override
  String get selectBodyPart => '부위 선택';

  @override
  String get selectEquipment => '장비 선택';

  @override
  String get add => '추가';

  @override
  String get pleaseEnterExerciseName => '운동 이름을 입력해주세요.';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Lifto';

  @override
  String greetingWithName(Object name) {
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
  String workoutDaysGoal(Object days, Object goal) {
    return '운동 일수: $days / $goal 일';
  }

  @override
  String workoutVolumeGoal(Object goal, Object volume) {
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
  String weeklyAverageVolume(Object volume) {
    return '이번 주 평균 운동 볼륨은 ${volume}kg 입니다.';
  }

  @override
  String weeklyComparison(Object diff) {
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
  String get fitMix => 'Lifto';

  @override
  String get editGoal => '목표 수정';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get planWorkout => '운동 계획하기';

  @override
  String get markRest => '운동 휴식하기';

  @override
  String get cancelRest => '운동 휴식 해제';

  @override
  String get noWorkoutRecords => '운동 기록이 없습니다';

  @override
  String get workoutRecord => '운동 기록';

  @override
  String totalVolume(Object volume) {
    return '총 볼륨: ${volume}kg';
  }

  @override
  String totalVolumeShort(Object volume) {
    return '총 볼륨 ${volume}kg';
  }

  @override
  String andMore(Object count) {
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
  String get noWorkoutPlan => '오늘의 운동 계획이 없습니다.\n캘린더에서 먼저 계획을 세워주세요.';

  @override
  String get noWorkoutPlanDesc => '하단의 \"운동 추가\" 버튼을 눌러\n운동을 추가해보세요';

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
  String seconds(Object count) {
    return '$count초';
  }

  @override
  String get secondsUnit => '초';

  @override
  String get close => '닫기';

  @override
  String get confirm => '확인';

  @override
  String get continueWorkout => '계속하기';

  @override
  String get quit => '종료';

  @override
  String get volumeByBodyPart => '부위별 총 볼륨';

  @override
  String get monthlyWorkoutTime => '월별 총 운동 시간';

  @override
  String get noAnalysisData => '분석할 운동 기록이 없습니다.';

  @override
  String errorOccurred(Object error) {
    return '오류 발생: $error';
  }

  @override
  String hours(Object count) {
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
  String get saved => '저장되었습니다.';

  @override
  String get saveFailed => '저장에 실패했습니다.';

  @override
  String loadFailed(Object error) {
    return '로드 실패: $error';
  }

  @override
  String get deleteExercise => '운동 삭제';

  @override
  String deleteExerciseConfirm(Object name) {
    return '\'$name\' 운동을 삭제하시겠습니까?';
  }

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
  String height(Object value) {
    return '키: $value cm';
  }

  @override
  String weight(Object value) {
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
  String get continueAsGuest => '게스트로 계속하기';

  @override
  String get allInOnePlace => '운동의 모든 것을 한 곳에서';

  @override
  String get enterWeight => '몸무게를 입력해 주세요.';

  @override
  String get enterHeight => '키를 입력해 주세요.';

  @override
  String get requiredInfo => '운동을 시작하기 위해\n필수 정보를 알려주세요.';

  @override
  String get weightLabel => '몸무게 *';

  @override
  String get heightLabel => '키 *';

  @override
  String get saveInfoFailed => '정보 저장에 실패했습니다.';

  @override
  String get import => '가져오기';

  @override
  String added(Object text) {
    return '추가됨: $text';
  }

  @override
  String get exerciseAdded => '운동이 추가되었습니다.';

  @override
  String get reorderSaveFailed => '순서 변경 저장에 실패했습니다.';

  @override
  String deleted(Object name) {
    return '$name 삭제됨';
  }

  @override
  String get undo => '실행 취소';

  @override
  String get addSet => '세트 추가';

  @override
  String get deleteSet => '세트 삭제';

  @override
  String get planYourWorkout => '운동을 직접 계획해보세요!';

  @override
  String setNumber(Object number) {
    return '$number세트';
  }

  @override
  String get setLabel => '세트';

  @override
  String get weightKg => '무게(kg)';

  @override
  String get reps => '횟수';

  @override
  String get repsUnit => '회';

  @override
  String get completed => '완료';

  @override
  String get notCompleted => '미완료';

  @override
  String get minOneSet => '최소 1개의 세트가 필요합니다.';

  @override
  String get enterRepsFirst => '먼저 목표 횟수를 입력하세요';

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

  @override
  String get workoutPlan => '운동 계획';

  @override
  String get selectExercise => '운동 선택';

  @override
  String workoutInProgress(Object day, Object month, Object weekday) {
    return '$month월 $day일 ($weekday) 운동 중';
  }

  @override
  String exerciseCount(Object count) {
    return '$count개 운동';
  }

  @override
  String get cannotChangeDateDuringWorkout => '운동 중에는 날짜를 변경할 수 없습니다';

  @override
  String get workoutCompleted => '운동이 완료되었습니다! 🎉';

  @override
  String get cancelTimer => '타이머 취소';

  @override
  String get rest => '휴식';

  @override
  String get waiting => '대기';

  @override
  String get tempo => '템포';

  @override
  String tempoStart(Object concentric, Object eccentric) {
    return '템포 시작 ($eccentric/${concentric}s)';
  }

  @override
  String get memo => '메모';

  @override
  String get dayUnit => '일';

  @override
  String get timesUnit => '회';

  @override
  String get validWorkoutDaysGoal => '올바른 운동일수 목표를 입력하세요.';

  @override
  String get validVolumeGoal => '올바른 볼륨 목표를 입력하세요.';

  @override
  String get goalSaved => '목표가 저장되었습니다.';

  @override
  String get profilePhotoChanged => '프로필 사진이 변경되었습니다.';

  @override
  String get profilePhotoDeleted => '프로필 사진이 삭제되었습니다.';

  @override
  String get birthDate => '생년월일 *';

  @override
  String get enterBirthDate => '생년월일을 입력해 주세요.';

  @override
  String get gender => '성별 *';

  @override
  String get enterGender => '성별을 알려주세요.';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get next => '다음';

  @override
  String get infoUsageNotice => '입력 정보는 운동 추천 용도로만 사용합니다.';

  @override
  String get analysisTitle => '분석';

  @override
  String get totalVolumeLabel => '총 볼륨';

  @override
  String get bodyBalanceAnalysis => '신체 밸런스 분석';

  @override
  String get last30DaysSets => '최근 30일 부위별 운동 세트 수';

  @override
  String get analysisResult => '분석 결과';

  @override
  String bodyPartAnalysisResult(
    Object strongest,
    Object strongestSets,
    Object weakest,
    Object weakestSets,
  ) {
    return '회원님은 현재 $strongest 운동 비중이 높고($strongestSets세트), $weakest 운동이 부족합니다($weakestSets세트).';
  }

  @override
  String get focusNeeded => '집중 공략 필요';

  @override
  String lowBodyPartWarning(Object parts) {
    return '현재 $parts 운동 비중이 낮습니다. 밸런스를 위해 조금 더 신경 써주세요!';
  }

  @override
  String get goToSupplementExercise => '보완 운동 하러 가기';

  @override
  String totalXpWeekly(Object total, Object weekly) {
    return '총 $total XP · 이번 주 $weekly XP';
  }

  @override
  String streakMessage(Object days) {
    return '$days일 연속 운동 중! 🔥';
  }

  @override
  String get startWorkoutToday => '오늘 운동을 시작해보세요!';

  @override
  String longestRecord(Object days) {
    return '최장 기록: $days일';
  }

  @override
  String get createFirstStreak => '첫 스트릭을 만들어보세요';

  @override
  String get oneMinute => '1분';

  @override
  String get oneMinute30Sec => '1분30초';

  @override
  String get twoMinutes => '2분';

  @override
  String get threeMinutes => '3분';

  @override
  String xpRemaining(Object xp) {
    return '$xp XP 남음';
  }

  @override
  String get achievement => '업적';

  @override
  String get currentStreak => '현재 스트릭';

  @override
  String get totalWorkouts => '총 운동';

  @override
  String get achievementUnlocked => '✅ 달성 완료!';

  @override
  String get achievementLocked => '🔒 미달성';

  @override
  String get achieveFirst => '첫 번째 업적을 달성해보세요!';

  @override
  String exerciseUnit(Object count) {
    return '$count개';
  }

  @override
  String get exercise => '운동';

  @override
  String get totalSets => '총 세트';

  @override
  String setsUnit(Object count) {
    return '$count세트';
  }

  @override
  String get startWorkoutNow => '지금 운동 시작하기';

  @override
  String get noRecentWorkout => '최근 운동 기록이 없습니다';

  @override
  String level(Object level) {
    return 'Level $level';
  }

  @override
  String get leagueBronze => '브론즈';

  @override
  String get leagueSilver => '실버';

  @override
  String get leagueGold => '골드';

  @override
  String get leaguePlatinum => '플래티넘';

  @override
  String get leagueDiamond => '다이아몬드';

  @override
  String get leagueMaster => '마스터';

  @override
  String get completeLabel => '완료';

  @override
  String get basicInfo => '기본 정보';

  @override
  String get bodyPart => '부위';

  @override
  String get equipment => '장비';

  @override
  String get exerciseType => '타입';

  @override
  String get customExercise => '커스텀 운동';

  @override
  String get exerciseInstructions => '운동 방법';

  @override
  String get primaryMuscles => '주요 타겟 근육';

  @override
  String get secondaryMuscles => '보조 근육';

  @override
  String get addToWorkoutPlan => '운동 계획에 추가';

  @override
  String get achievementStreak3Title => '시작이 반이다';

  @override
  String get achievementStreak3Desc => '3일 연속 운동';

  @override
  String get achievementStreak7Title => '일주일 전사';

  @override
  String get achievementStreak7Desc => '7일 연속 운동';

  @override
  String get achievementStreak30Title => '한 달의 기적';

  @override
  String get achievementStreak30Desc => '30일 연속 운동';

  @override
  String get achievementWorkout1Title => '첫 발걸음';

  @override
  String get achievementWorkout1Desc => '첫 운동 완료';

  @override
  String get achievementWorkout10Title => '습관 형성';

  @override
  String get achievementWorkout10Desc => '10회 운동 완료';

  @override
  String get achievementWorkout50Title => '운동 마니아';

  @override
  String get achievementWorkout50Desc => '50회 운동 완료';

  @override
  String get achievementWorkout100Title => '백전백승';

  @override
  String get achievementWorkout100Desc => '100회 운동 완료';

  @override
  String get achievementVolume10kTitle => '만 킬로그램';

  @override
  String get achievementVolume10kDesc => '총 볼륨 10,000kg 달성';

  @override
  String get achievementVolume100kTitle => '10만 클럽';

  @override
  String get achievementVolume100kDesc => '총 볼륨 100,000kg 달성';

  @override
  String get achievementVolume1mTitle => '밀리언 리프터';

  @override
  String get achievementVolume1mDesc => '총 볼륨 1,000,000kg 달성';

  @override
  String get achievementWeekendTitle => '주말 전사';

  @override
  String get achievementWeekendDesc => '주말에 운동하기';

  @override
  String exerciseSelected(String name) {
    return '$name 운동이 선택되었습니다.';
  }

  @override
  String get upgradeTitle => '프리미엄으로 업그레이드';

  @override
  String get unlockAllFeatures => '모든 기능을 잠금 해제하세요';

  @override
  String get advancedAnalytics => '고급 분석';

  @override
  String get advancedAnalyticsDesc => '주간, 월간, 연간 운동 데이터를 심층 분석하세요.';

  @override
  String get removeAds => '광고 제거';

  @override
  String get removeAdsDesc => '방해 없이 운동에만 집중하세요.';

  @override
  String get cloudBackup => '클라우드 백업';

  @override
  String get cloudBackupDesc => '여러 기기에서 데이터를 안전하게 동기화하세요.';

  @override
  String get startMonthly => '월 9,900원으로 시작하기';

  @override
  String get cancelAnytime => '언제든지 구독을 취소할 수 있습니다.';

  @override
  String get powerShop => '파워 상점';

  @override
  String get items => '🛉 아이템';

  @override
  String get streakFreeze => '스트릭 프리즈';

  @override
  String get streakFreezeDesc => '하루 쉬어도 스트릭 유지';

  @override
  String get weeklyReport => '�� 주간 운동 리포트';

  @override
  String get weeklyReportDesc => '이번 주 운동 분석 리포트';

  @override
  String get customization => '🎨 커스터마이징 (준비 중)';

  @override
  String get darkPurpleTheme => '다크 퍼플 테마';

  @override
  String get purplePointTheme => '보라색 포인트 테마';

  @override
  String get fireTheme => '파이어 테마';

  @override
  String get orangeTheme => '불타는 오렌지 테마';

  @override
  String get specialBadges => '🏅 특별 뱃지 (준비 중)';

  @override
  String get lightningBadge => '번개 뱃지';

  @override
  String get specialBadgeDesc => '프로필에 표시되는 특별 뱃지';

  @override
  String get comingSoon => '준비 중이에요!';

  @override
  String get streakFreezeSuccess => '스트릭 프리즈 구매 완료! ❄️';

  @override
  String get insufficientPower => '파워가 부족해요 💪';

  @override
  String get weeklyReportTitle => '📊 주간 리포트';

  @override
  String get thisWeekPerformance => '이번 주 성과';

  @override
  String get allRecords => '전체 기록';

  @override
  String get nextGoal => '다음 목표';

  @override
  String levelAchievement(Object level) {
    return 'Level $level 달성';
  }

  @override
  String leaguePromotion(Object league) {
    return '$league 리그 승급';
  }

  @override
  String get encouragingMessage => '잘하고 있어요!';

  @override
  String get encouragingDesc => '꾸준히 운동하면 목표를 달성할 수 있어요';

  @override
  String get set => '세트';

  @override
  String get done => '완료';

  @override
  String get birthDateFormat => 'yyyy년 MM월 dd일';

  @override
  String get workoutPlanEmpty => '운동 계획이 없습니다';

  @override
  String get restingDay => '운동 휴식 중입니다';

  @override
  String get restingDayDesc => '오늘은 휴식하는 날입니다.\n\"운동 휴식 해제\" 버튼으로 변경할 수 있습니다';

  @override
  String get planWorkoutDesc => '하단의 \"운동 계획하기\" 버튼을 눌러\n운동을 추가해보세요';

  @override
  String get cancelRestDay => '운동 휴식 해제';

  @override
  String get editWorkout => '운동 편집';

  @override
  String get addWorkout => '운동 추가';

  @override
  String get minOneSetRequired => '최소 1개의 세트가 필요합니다';

  @override
  String addExercises(int count) {
    return '$count개 운동 추가';
  }
}

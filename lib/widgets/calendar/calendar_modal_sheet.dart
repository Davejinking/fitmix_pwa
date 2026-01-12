import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../data/session_repo.dart';
import '../../data/exercise_library_repo.dart';
import '../../pages/plan_page.dart';
import '../../l10n/app_localizations.dart';

// 휴식 날짜 기능 추가

class CalendarModalSheet extends StatefulWidget {
  final DateTime initialDate;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final Set<String> workoutDates; // 운동한 날짜들 (yyyy-MM-dd 형식)
  final Set<String> restDates; // 휴식 날짜들 (yyyy-MM-dd 형식)

  const CalendarModalSheet({
    super.key,
    required this.initialDate,
    required this.repo,
    required this.exerciseRepo,
    required this.workoutDates,
    required this.restDates,
  });

  @override
  State<CalendarModalSheet> createState() => _CalendarModalSheetState();
}

class _CalendarModalSheetState extends State<CalendarModalSheet> {
  late DateTime _tempSelectedDate;
  late DateTime _focusedMonth;
  late PageController _pageController;
  static const int _initialPage = 500;
  
  // 세션 상태 캐싱을 위한 변수들
  Map<String, dynamic> _sessionCache = {};
  bool _isLoadingSession = false;

  @override
  void initState() {
    super.initState();
    _tempSelectedDate = widget.initialDate;
    _focusedMonth = widget.initialDate;
    _pageController = PageController(initialPage: _initialPage);
    _loadSessionStatus(_tempSelectedDate); // 초기 세션 로드
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMonthForPage(int page) {
    final offset = page - _initialPage;
    return DateTime(
      widget.initialDate.year,
      widget.initialDate.month + offset,
    );
  }

  void _goToPreviousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getYmd(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadSessionStatus(DateTime date) async {
    final ymd = _getYmd(date);
    if (_sessionCache.containsKey(ymd)) return; // 이미 캐시된 경우 스킵
    
    setState(() => _isLoadingSession = true);
    try {
      final session = await widget.repo.get(ymd);
      _sessionCache[ymd] = session;
    } catch (e) {
      _sessionCache[ymd] = null;
    }
    if (mounted) {
      setState(() => _isLoadingSession = false);
    }
  }

  dynamic _getCachedSessionStatus(DateTime date) {
    final ymd = _getYmd(date);
    return _sessionCache[ymd];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // 다크 테마 배경색으로 변경
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600], // 다크 테마에 맞는 핸들 색상
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // 타이틀
            Text(
              AppLocalizations.of(context).selectDate,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // 다크 테마 텍스트 색상
              ),
            ),
            const SizedBox(height: 16),
            // 월 네비게이션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(_focusedMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // 다크 테마 텍스트 색상
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: Color(0xFF4A9EFF), // 테마의 primary 색상 사용
                        ),
                        onPressed: _goToPreviousMonth,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF4A9EFF), // 테마의 primary 색상 사용
                        ),
                        onPressed: _goToNextMonth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 캘린더 (PageView)
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _focusedMonth = _getMonthForPage(page);
                  });
                },
                itemBuilder: (context, index) {
                  final monthDate = _getMonthForPage(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TableCalendar(
                      locale: locale.toString(),
                      focusedDay: monthDate,
                      firstDay: DateTime.utc(2010, 1, 1),
                      lastDay: DateTime.utc(2035, 12, 31),
                      headerVisible: false,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      selectedDayPredicate: (day) =>
                          isSameDay(_tempSelectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _tempSelectedDate = selectedDay;
                        });
                        _loadSessionStatus(selectedDay); // 새로운 날짜의 세션 상태 로드
                      },
                      daysOfWeekHeight: 40,
                      rowHeight: 48,
                      calendarStyle: CalendarStyle(
                        cellMargin: const EdgeInsets.all(4),
                        // 오늘
                        todayDecoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF4A9EFF).withValues(alpha: 0.3), // 테마 primary 색상
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.white, // 다크 테마 텍스트
                          fontWeight: FontWeight.w600,
                        ),
                        // 선택된 날짜
                        selectedDecoration: BoxDecoration(
                          color: Color(0xFF4A9EFF), // 테마 primary 색상
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        // 기본
                        defaultTextStyle: TextStyle(
                          color: Colors.white, // 다크 테마 텍스트
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        // 주말
                        weekendTextStyle: TextStyle(
                          color: Colors.white, // 다크 테마 텍스트
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        // 다른 달
                        outsideTextStyle: TextStyle(
                          color: Colors.grey[600], // 다크 테마에 맞는 회색
                          fontSize: 15,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final l10n = AppLocalizations.of(context);
                          final weekdays = [
                            l10n.weekdaySun,
                            l10n.weekdayMon,
                            l10n.weekdayTue,
                            l10n.weekdayWed,
                            l10n.weekdayThu,
                            l10n.weekdayFri,
                            l10n.weekdaySat,
                          ];
                          final text = weekdays[day.weekday % 7];
                          return Center(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400], // 다크 테마에 맞는 회색
                              ),
                            ),
                          );
                        },
                        markerBuilder: (context, day, events) {
                          final ymd = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                          
                          // 휴식 날짜에 빨간색 동그라미 표시
                          if (widget.restDates.contains(ymd)) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          
                          // 운동 완료된 날짜에 파란색 동그라미 표시
                          if (widget.workoutDates.contains(ymd)) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4A9EFF), // 테마 primary 색상
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // 버튼 영역 (조건부 표시)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: _buildButtonArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonArea() {
    if (_isLoadingSession) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: null,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    final session = _getCachedSessionStatus(_tempSelectedDate);
    final isRest = session?.isRest ?? false;
    final hasExercises = session?.hasExercises ?? false;

    // 휴식 상태: "운동 휴식 해제" 버튼
    if (isRest) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () async {
            await widget.repo.markRest(
              _getYmd(_tempSelectedDate),
              rest: false,
            );
            // 캐시 업데이트
            _sessionCache[_getYmd(_tempSelectedDate)] = null;
            if (mounted) {
              Navigator.pop(context, true); // true를 반환하여 새로고침 신호
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A9EFF), // 테마 primary 색상
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppLocalizations.of(context).cancelRest,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 운동이 있는 경우: "운동 편집" 버튼
    if (hasExercises) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PlanPage(
                  date: _tempSelectedDate,
                  repo: widget.repo,
                  exerciseRepo: widget.exerciseRepo,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A9EFF), // 테마 primary 색상
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            AppLocalizations.of(context).editExercise,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 기본: "운동 계획하기" + "운동 휴식하기" 버튼 (2개 버튼)
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlanPage(
                      date: _tempSelectedDate,
                      repo: widget.repo,
                      exerciseRepo: widget.exerciseRepo,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A9EFF), // 테마 primary 색상
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).planWorkout,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                await widget.repo.markRest(
                  _getYmd(_tempSelectedDate),
                  rest: true,
                );
                // 캐시 업데이트
                final ymd = _getYmd(_tempSelectedDate);
                _sessionCache[ymd] = await widget.repo.get(ymd);
                if (mounted) {
                  Navigator.pop(context, true); // true를 반환하여 새로고침 신호
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF4A9EFF), // 테마 primary 색상
                side: const BorderSide(
                  color: Color(0xFF4A9EFF), // 테마 primary 색상
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).markRest,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
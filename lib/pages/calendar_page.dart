import 'package:flutter/material.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../data/settings_repo.dart';
import '../core/burn_fit_style.dart';
import '../widgets/calendar/calendar_modal_sheet.dart';
import '../widgets/calendar/day_timeline_list.dart';
import '../widgets/calendar/month_header.dart';
import 'plan_page.dart';
import '../l10n/app_localizations.dart';

/// 캘린더 페이지 - PlanPage 기능 통합
class CalendarPage extends StatefulWidget {
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  final SettingsRepo? settingsRepo;

  const CalendarPage({
    super.key,
    required this.repo,
    required this.exerciseRepo,
    this.settingsRepo,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  late PageController _pageController;

  static const int _initialPage = 500;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getMonthForPage(int page) {
    final now = DateTime.now();
    final offset = page - _initialPage;
    return DateTime(now.year, now.month + offset);
  }

  void _onPageChanged(int page) {
    setState(() {
      _focusedDate = _getMonthForPage(page);
    });
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

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalendarModalSheet(
        initialDate: _selectedDate,
        repo: widget.repo,
        exerciseRepo: widget.exerciseRepo,
        settingsRepo: widget.settingsRepo,
      ),
    ).then((selectedDate) {
      if (selectedDate != null && selectedDate is DateTime) {
        setState(() {
          _selectedDate = selectedDate;
          // 선택된 날짜가 포함된 달로 이동
          final now = DateTime.now();
          final diffMonths = (selectedDate.year - now.year) * 12 +
              (selectedDate.month - now.month);
          final targetPage = _initialPage + diffMonths;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(targetPage);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // App Bar
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).calendar),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _showCalendarModal,
          ),
          // 오늘로 이동 버튼
          TextButton(
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _selectedDate = now;
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(_initialPage);
                }
              });
            },
            child: Text(
              AppLocalizations.of(context).today,
              style: const TextStyle(
                color: BurnFitStyle.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Header
          MonthHeader(
            focusedDate: _focusedDate,
            onPreviousMonth: _goToPreviousMonth,
            onNextMonth: _goToNextMonth,
            onTitleTap: _showCalendarModal,
            repo: widget.repo,
            exerciseRepo: widget.exerciseRepo,
            settingsRepo: widget.settingsRepo,
          ),

          // Calendar Timeline
          SizedBox(
            height: 100, // 날짜 타임라인 높이
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final monthDate = _getMonthForPage(index);
                return DayTimelineList(
                  monthDate: monthDate,
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateSelected,
                  repo: widget.repo,
                  exerciseRepo: widget.exerciseRepo,
                  settingsRepo: widget.settingsRepo,
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFF2C2C2E)),

          // Exercise List (PlanPage에서 가져온 로직)
          Expanded(
            child: PlanPage(
              key: ValueKey(_selectedDate), // 날짜가 바뀌면 재빌드
              date: _selectedDate,
              repo: widget.repo,
              exerciseRepo: widget.exerciseRepo,
              settingsRepo: widget.settingsRepo,
            ),
          ),
        ],
      ),
    );
  }
}

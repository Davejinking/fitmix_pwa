import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/calendar_config.dart';   // ← 추가
import 'data/session_repo.dart';
import 'models/session.dart';
import 'pages/plan_page.dart';

// DateTime은 const 아님 → final 사용
final DateTime _kFirstDay = DateTime(2010, 1, 1);
final DateTime _kLastDay  = DateTime(2035, 12, 31);

DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _clampDay(DateTime d) {
  final x = _atMidnight(d);
  if (x.isBefore(_kFirstDay)) return _kFirstDay;
  if (x.isAfter(_kLastDay))  return _kLastDay;
  return x;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  Intl.defaultLocale = 'ko_KR';

  final repo = HiveSessionRepo();
  await repo.init();
  runApp(FitMixApp(repo: repo));
}

class FitMixApp extends StatelessWidget {
  final SessionRepo repo;
  const FitMixApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMix PS0',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('ja', 'JP'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: CalendarPage(repo: repo),
    );
  }
}

class CalendarPage extends StatefulWidget {
  final SessionRepo repo;
  const CalendarPage({super.key, required this.repo});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focused;
  late DateTime _selected;
  CalendarFormat _format = CalendarFormat.month; // 기본 월

  @override
  void initState() {
    super.initState();
    _focused  = _clampDay(DateTime.now());
    _selected = _focused;
  }

  Future<Session?> _session(DateTime d) => widget.repo.get(widget.repo.ymd(d));

  List<DateTime> _markersFromSessions(List<Session> sessions) {
    return sessions.map((s) {
      final p = s.ymd.split('-').map(int.parse).toList();
      return _atMidnight(DateTime(p[0], p[1], p[2]));
    }).toList();
  }

  Future<void> _openPlan(DateTime day) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlanPage(date: day, repo: widget.repo)),
    );
    if (changed == true) setState(() {});
  }

  Future<void> _copyFlow(Session s) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _clampDay(_selected.add(const Duration(days: 1))),
      firstDate: _kFirstDay,
      lastDate: _kLastDay,
      helpText: '복사할 날짜 선택',
      builder: (ctx, child) => Theme(data: Theme.of(context), child: child!),
    );
    if (picked == null) return;
    await widget.repo.copyDay(fromYmd: s.ymd, toYmd: widget.repo.ymd(picked));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('복사 완료')));
    setState(() {});
  }

  Future<void> _deleteFlow(String ymd) async {
    await widget.repo.delete(ymd);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제 완료')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final y = widget.repo.ymd(_selected);
    return Scaffold(
      appBar: AppBar(title: const Text('FitMix — Calendar')),
      body: FutureBuilder(
        future: widget.repo.listAll(),
        builder: (context, snap) {
          final sessions = (snap.data ?? <Session>[]);
          final markers = _markersFromSessions(sessions);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: _kFirstDay,
                  lastDay: _kLastDay,
                  focusedDay: _focused,
                  locale: 'ko_KR',
                  calendarFormat: _format,                 // 월 고정
                  availableCalendarFormats: availableFormats(), // 월만 노출(기본)
                  headerStyle: HeaderStyle(
                    formatButtonVisible: formatButtonVisible(), // false(기본)
                  ),
                  sixWeekMonthsEnforced: true,
                  rowHeight: 42,
                  selectedDayPredicate: (d) => isSameDay(d, _selected),
                  onDaySelected: (sel, foc) => setState(() {
                    _selected = _clampDay(sel);
                    _focused  = _clampDay(foc);
                  }),
                  onFormatChanged: (f) => setState(() => _format = f),
                  onPageChanged: (foc) => _focused = _clampDay(foc),
                  eventLoader: (day) =>
                      markers.any((m) => isSameDay(m, day)) ? const ['*'] : const [],
                ),
                const SizedBox(height: 8),
                FutureBuilder(
                  future: _session(_selected),
                  builder: (context, sSnap) {
                    final s = sSnap.data;
                    final hasWorkout = (s != null && !s.isRest && s.exercises.isNotEmpty);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          if (hasWorkout) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => _copyFlow(s!),
                                    child: const Text('복사'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _deleteFlow(y),
                                    child: const Text('삭제'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('운동 ${s!.exercises.length}개', style: const TextStyle(fontSize: 12)),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _openPlan(_selected),
                                child: const Text('운동 계획하기'),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selected),
                              style: const TextStyle(fontSize: 12)),
                          ],
                          if (s != null && s.isRest)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text('전체 휴식일', style: TextStyle(color: Colors.grey)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

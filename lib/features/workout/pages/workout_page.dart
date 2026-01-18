import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/burn_fit_style.dart';
import '../../../data/session_repo.dart';
import '../../../models/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/tempo_controller.dart';
import '../../../widgets/workout/rest_timer_panel.dart';
import '../../../widgets/workout/set_tile.dart';

class WorkoutPage extends StatefulWidget {
  final SessionRepo sessionRepo;
  final DateTime? date; // 선택적 날짜 파라미터 (null이면 오늘)
  final bool isEditing; // Edit mode flag

  const WorkoutPage({
    super.key, 
    required this.sessionRepo, 
    this.date,
    this.isEditing = false,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> with WidgetsBindingObserver {
  late Future<Session?> _sessionFuture;
  Session? _currentSession;
  
  // 1. 전체 운동 시간 타이머 (Background-Aware)
  Timer? _globalTimer;
  DateTime? _workoutStartTime;
  int _currentDurationSeconds = 0;
  
  // 2. 자동 휴식 타이머 (Background-Aware)
  Timer? _restTimer;
  DateTime? _restEndTime;
  int _restSecondsRemaining = 0;
  int _defaultRestDuration = 90; // 기본 90초
  
  // 휴식 타이머를 트리거한 세트 추적 (체크 해제 시 타이머 취소용)
  String? _activeRestSetKey;
  
  // 3. Tempo Controller
  TempoController? _tempoController;
  bool _isTempoRunning = false;
  
  // 4. Auto-save timer
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final targetDate = widget.date ?? DateTime.now();
    _sessionFuture = widget.sessionRepo.get(widget.sessionRepo.ymd(targetDate));
    _loadSession();
    _initTempoController();
  }
  
  Future<void> _loadSession() async {
    final targetDate = widget.date ?? DateTime.now();
    _currentSession = await widget.sessionRepo.get(widget.sessionRepo.ymd(targetDate));
    
    if (_currentSession != null) {
      if (widget.isEditing) {
        // Edit mode: Load saved duration, don't start timer
        _currentDurationSeconds = _currentSession!.durationInSeconds;
      } else {
        // Active workout mode: Start timer
        if (_currentSession!.durationInSeconds > 0) {
          _workoutStartTime = DateTime.now().subtract(
            Duration(seconds: _currentSession!.durationInSeconds),
          );
        } else {
          _workoutStartTime = DateTime.now();
        }
        _startGlobalTimer();
        _startAutoSaveTimer();
      }
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // Force UI update when app resumes from background
      if (mounted) {
        setState(() {
          _updateCurrentDuration();
          _updateRestTimer();
        });
      }
    }
  }

  Future<void> _initTempoController() async {
    _tempoController = TempoController();
    await _tempoController!.init();
    
    _tempoController!.onStateChange = () {
      if (mounted) setState(() {});
    };
    
    _tempoController!.onComplete = () {
      if (mounted) setState(() => _isTempoRunning = false);
    };
  }

  // 1. 전체 운동 시간 타이머 시작 (Background-Aware)
  void _startGlobalTimer() {
    _globalTimer?.cancel();
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCurrentDuration();
        });
      }
    });
  }
  
  void _updateCurrentDuration() {
    if (_workoutStartTime != null) {
      _currentDurationSeconds = DateTime.now().difference(_workoutStartTime!).inSeconds;
    }
  }
  
  // Auto-save timer (every 30 seconds)
  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveSession();
    });
  }
  
  // Save session to repository
  Future<void> _saveSession() async {
    if (_currentSession == null) return;
    
    _updateCurrentDuration();
    _currentSession!.durationInSeconds = _currentDurationSeconds;
    
    try {
      await widget.sessionRepo.put(_currentSession!);
    } catch (e) {
      debugPrint('❌ Auto-save failed: $e');
    }
  }

  // 2. 자동 휴식 타이머 시작 (Background-Aware)
  void _startRestTimer(String setKey) {
    _cancelRestTimer(); // 기존 타이머 취소
    
    setState(() {
      _restEndTime = DateTime.now().add(Duration(seconds: _defaultRestDuration));
      _activeRestSetKey = setKey;
      _restSecondsRemaining = _defaultRestDuration;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateRestTimer();
        });
      }
    });
  }
  
  void _updateRestTimer() {
    if (_restEndTime == null) return;
    
    final remaining = _restEndTime!.difference(DateTime.now()).inSeconds;
    
    if (remaining <= 0) {
      _onRestTimerComplete();
    } else {
      _restSecondsRemaining = remaining;
    }
  }

  // 휴식 타이머 취소 (체크 해제 시 호출)
  void _cancelRestTimer() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _restEndTime = null;
        _restSecondsRemaining = 0;
        _activeRestSetKey = null;
      });
    }
  }

  // 휴식 타이머 완료
  void _onRestTimerComplete() {
    _restTimer?.cancel();
    HapticFeedback.heavyImpact(); // 진동
    if (mounted) {
      setState(() {
        _restEndTime = null;
        _restSecondsRemaining = 0;
        _activeRestSetKey = null;
      });
    }
  }

  // 휴식 시간 조절 (-10초, +30초)
  void _adjustRestTime(int seconds) {
    if (_restEndTime != null) {
      setState(() {
        _restEndTime = _restEndTime!.add(Duration(seconds: seconds));
        _updateRestTimer();
        
        if (_restSecondsRemaining <= 0) {
          _onRestTimerComplete();
        }
      });
    }
  }

  // 휴식 시간 직접 입력
  Future<void> _showRestTimePicker() async {
    final currentMinutes = _restSecondsRemaining ~/ 60;
    final currentSeconds = _restSecondsRemaining % 60;
    
    int selectedMinutes = currentMinutes;
    int selectedSeconds = currentSeconds;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context).close),
                  ),
                  Text(
                    AppLocalizations.of(context).adjustRestTime,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      final totalSeconds = selectedMinutes * 60 + selectedSeconds;
                      if (_restEndTime != null) {
                        setState(() {
                          _restEndTime = DateTime.now().add(Duration(seconds: totalSeconds));
                          _updateRestTimer();
                        });
                      } else {
                        setState(() {
                          _defaultRestDuration = totalSeconds;
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context).confirm),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: currentMinutes),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        selectedMinutes = index;
                      },
                      children: List.generate(10, (index) => Center(child: Text('$index 분'))),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: currentSeconds),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        selectedSeconds = index;
                      },
                      children: List.generate(60, (index) => Center(child: Text('$index 초'))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTempoGuidance(
    int reps,
    int eccentricSec,
    int concentricSec,
  ) async {
    if (_isTempoRunning || _tempoController == null) return;

    setState(() => _isTempoRunning = true);

    await _tempoController!.start(
      reps: reps,
      downSeconds: eccentricSec,
      upSeconds: concentricSec,
    );
  }

  bool get _isResting => _restEndTime != null && _restSecondsRemaining > 0;

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _showFinishDialog(Session session) async {
    final l10n = AppLocalizations.of(context);
    
    // Update current duration before showing dialog
    if (!widget.isEditing) {
      _updateCurrentDuration();
    }
    
    // Show duration picker dialog
    Duration selectedDuration = Duration(seconds: _currentDurationSeconds);
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.close),
                  ),
                  Text(
                    widget.isEditing ? '수정 완료' : '운동 기록 확정',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Save with selected duration
                      session.durationInSeconds = selectedDuration.inSeconds;
                      await widget.sessionRepo.put(session);
                      if (mounted) {
                        Navigator.pop(context); // Close dialog
                        Navigator.of(context).pop(1); // Return to calendar
                      }
                    },
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Duration display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '운동 시간',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
            // CupertinoTimerPicker
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: selectedDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  selectedDuration = newDuration;
                },
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Legacy method - kept for compatibility but redirects to _showFinishDialog
  Future<void> _endWorkout(Session session) async {
    await _showFinishDialog(session);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _globalTimer?.cancel();
    _restTimer?.cancel();
    _autoSaveTimer?.cancel();
    _tempoController?.dispose();
    
    // Final save on dispose
    if (_currentSession != null) {
      _updateCurrentDuration();
      _currentSession!.durationInSeconds = _currentDurationSeconds;
      widget.sessionRepo.put(_currentSession!);
    }
    
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todayWorkout),
        centerTitle: true,
        // backgroundColor removed - uses theme default
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. 전체 운동 시간 (Global Timer) - 상단 고정
              Container(
                color: const Color(0xFF121212),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      l10n.workoutDuration,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_currentDurationSeconds),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              // 운동 목록
              Expanded(
                child: FutureBuilder<Session?>(
                  future: _sessionFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.isWorkoutDay) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            l10n.noWorkoutPlan,
                            textAlign: TextAlign.center,
                            style: BurnFitStyle.body,
                          ),
                        ),
                      );
                    }

                    final session = snapshot.data!;
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, _isResting ? 280 : 8),
                      itemCount: session.exercises.length + 1, // 마지막에 종료 버튼 추가
                      itemBuilder: (context, index) {
                        if (index == session.exercises.length) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                            child: OutlinedButton(
                              onPressed: () => _endWorkout(session),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: widget.isEditing ? Colors.blue : Colors.red,
                                  width: 2,
                                ),
                                foregroundColor: widget.isEditing ? Colors.blue : Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: Text(
                                widget.isEditing ? '수정 완료' : l10n.endAndSaveWorkout,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          );
                        }

                        final exercise = session.exercises[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: BurnFitStyle.lightGray,
                              child: Text('${index + 1}', style: const TextStyle(color: BurnFitStyle.darkGrayText)),
                            ),
                            title: Text(exercise.name, style: BurnFitStyle.body.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(exercise.bodyPart),
                            children: List.generate(exercise.sets.length, (setIndex) {
                              final set = exercise.sets[setIndex];
                              final setKey = 'exercise_${index}_set_$setIndex';
                              return SetTile(
                                key: ValueKey(setKey),
                                setKey: setKey,
                                setIndex: setIndex,
                                weight: set.weight,
                                reps: set.reps,
                                isCompleted: set.isCompleted,
                                isLastSet: setIndex == exercise.sets.length - 1,
                                isTempoEnabled: exercise.isTempoEnabled,
                                eccentricSeconds: exercise.eccentricSeconds,
                                concentricSeconds: exercise.concentricSeconds,
                                onSetCompleted: (isCompleted) async {
                                  // 세트 완료 상태를 Session에 저장
                                  set.isCompleted = isCompleted;
                                  
                                  // Immediate auto-save on set completion (only in active workout mode)
                                  if (!widget.isEditing) {
                                    await _saveSession();
                                  }
                                  
                                  if (isCompleted) {
                                    // 2. 체크 시 자동 휴식 타이머 시작 (only in active workout mode)
                                    if (!widget.isEditing && setIndex < exercise.sets.length - 1) {
                                      _startRestTimer(setKey);
                                    }
                                  } else {
                                    // 체크 해제 시 타이머 취소
                                    if (_activeRestSetKey == setKey) {
                                      _cancelRestTimer();
                                    }
                                  }
                                },
                                onTempoStart: (reps, eccentricSec, concentricSec) {
                                  _startTempoGuidance(reps, eccentricSec, concentricSec);
                                },
                              );
                            }),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // 3. 휴식 타이머 플로팅 패널 (하단)
          if (_isResting)
            RestTimerPanel(
              restSecondsRemaining: _restSecondsRemaining,
              defaultRestDuration: _defaultRestDuration,
              onCancel: _cancelRestTimer,
              onAdjustTime: _adjustRestTime,
              onTimePickerTap: _showRestTimePicker,
            ),
        ],
      ),
    );
  }
}
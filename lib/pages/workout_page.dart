import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../core/burn_fit_style.dart';
import '../core/error_handler.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../l10n/app_localizations.dart';

class WorkoutPage extends StatefulWidget {
  final SessionRepo sessionRepo;

  const WorkoutPage({super.key, required this.sessionRepo});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late Future<Session?> _sessionFuture;
  
  // 1. 전체 운동 시간 타이머 (Global Timer)
  Timer? _globalTimer;
  int _totalWorkoutSeconds = 0;
  
  // 2. 자동 휴식 타이머 (Auto-Rest Timer)
  Timer? _restTimer;
  int? _restSecondsRemaining;
  int _defaultRestDuration = 90; // 기본 90초
  
  // 휴식 타이머를 트리거한 세트 추적 (체크 해제 시 타이머 취소용)
  String? _activeRestSetKey;

  @override
  void initState() {
    super.initState();
    _sessionFuture = widget.sessionRepo.get(widget.sessionRepo.ymd(DateTime.now()));
    _startGlobalTimer();
  }

  // 1. 전체 운동 시간 타이머 시작
  void _startGlobalTimer() {
    _globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _totalWorkoutSeconds++;
        });
      }
    });
  }

  // 2. 자동 휴식 타이머 시작 (세트 완료 시 호출)
  void _startRestTimer(String setKey) {
    print('🚀 _startRestTimer 호출됨: $setKey');
    _cancelRestTimer(); // 기존 타이머 취소
    
    setState(() {
      _restSecondsRemaining = _defaultRestDuration;
      _activeRestSetKey = setKey;
    });
    
    print('⏰ 휴식 타이머 설정: $_restSecondsRemaining초, _isResting: $_isResting');

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining! > 0) {
        if (mounted) {
          setState(() {
            _restSecondsRemaining = _restSecondsRemaining! - 1;
          });
        }
      } else {
        _onRestTimerComplete();
      }
    });
  }

  // 휴식 타이머 취소 (체크 해제 시 호출)
  void _cancelRestTimer() {
    _restTimer?.cancel();
    if (mounted) {
      setState(() {
        _restSecondsRemaining = null;
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
        _restSecondsRemaining = null;
        _activeRestSetKey = null;
      });
    }
  }

  // 휴식 시간 조절 (-10초, +30초)
  void _adjustRestTime(int seconds) {
    if (_restSecondsRemaining != null) {
      setState(() {
        _restSecondsRemaining = (_restSecondsRemaining! + seconds).clamp(0, 999);
        if (_restSecondsRemaining == 0) {
          _onRestTimerComplete();
        }
      });
    }
  }

  // 휴식 시간 직접 입력
  Future<void> _showRestTimePicker() async {
    final currentMinutes = (_restSecondsRemaining ?? _defaultRestDuration) ~/ 60;
    final currentSeconds = (_restSecondsRemaining ?? _defaultRestDuration) % 60;
    
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
                      if (_restSecondsRemaining != null) {
                        setState(() {
                          _restSecondsRemaining = totalSeconds;
                        });
                      } else {
                        setState(() {
                          _defaultRestDuration = totalSeconds;
                        });
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('확인'),
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

  bool get _isResting => _restSecondsRemaining != null && _restSecondsRemaining! > 0;

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatRestTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '$seconds';
  }

  Future<void> _endWorkout(Session session) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      l10n.endWorkout,
      l10n.endWorkoutConfirm,
    );

    if (confirmed && mounted) {
      session.durationInSeconds = _totalWorkoutSeconds;
      await widget.sessionRepo.put(session);
      if (mounted) {
        // 캘린더 탭(1)으로 이동
        Navigator.of(context).pop(1);
      }
    }
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todayWorkout),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
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
                      _formatDuration(_totalWorkoutSeconds),
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
                      padding: const EdgeInsets.all(8),
                      itemCount: session.exercises.length + 1, // 마지막에 종료 버튼 추가
                      itemBuilder: (context, index) {
                        if (index == session.exercises.length) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                            child: OutlinedButton(
                              onPressed: () => _endWorkout(session),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                minimumSize: const Size(double.infinity, 56),
                              ),
                              child: Text(
                                l10n.endAndSaveWorkout,
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
                              return _SetTile(
                                key: ValueKey(setKey),
                                setKey: setKey,
                                setIndex: setIndex,
                                weight: set.weight,
                                reps: set.reps,
                                isCompleted: set.isCompleted,
                                isLastSet: setIndex == exercise.sets.length - 1,
                                onSetCompleted: (isCompleted) {
                                  // 세트 완료 상태를 Session에 저장
                                  set.isCompleted = isCompleted;
                                  
                                  if (isCompleted) {
                                    print('✅ 세트 완료: $setKey, 마지막 세트: ${setIndex == exercise.sets.length - 1}');
                                    // 2. 체크 시 자동 휴식 타이머 시작
                                    if (setIndex < exercise.sets.length - 1) {
                                      print('🔔 휴식 타이머 시작: $setKey');
                                      _startRestTimer(setKey);
                                    }
                                  } else {
                                    print('❌ 세트 체크 해제: $setKey');
                                    // 체크 해제 시 타이머 취소
                                    if (_activeRestSetKey == setKey) {
                                      print('⏹️ 휴식 타이머 취소');
                                      _cancelRestTimer();
                                    }
                                  }
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
          if (_isResting) _buildRestTimerPanel(),
        ],
      ),
    );
  }

  // 3. 휴식 타이머 UI - 하단 플로팅 패널 (Apple 스타일)
  Widget _buildRestTimerPanel() {
    final l10n = AppLocalizations.of(context);
    final progress = _restSecondsRemaining! / _defaultRestDuration;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // 어두운 회색 배경
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이머 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.restTimer,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFAAAAAA), size: 22),
                  onPressed: _cancelRestTimer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 타이머 디스플레이 + 컨트롤
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // -10초 버튼
                TextButton(
                  onPressed: () => _adjustRestTime(-10),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    '-10',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 타이머 숫자 (탭하면 직접 입력)
                Expanded(
                  child: GestureDetector(
                    onTap: _showRestTimePicker,
                    child: Column(
                      children: [
                        Text(
                          _formatRestTime(_restSecondsRemaining!),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900, // 아주 굵게
                            color: Colors.white,
                            fontFamily: 'monospace',
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.restTimeRemaining,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAAAAAA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // +30초 버튼
                TextButton(
                  onPressed: () => _adjustRestTime(30),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    '+30',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 진행 바 (파란색이 차오르는 느낌)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[800], // 어두운 회색 트랙
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)), // 파란색 진행
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetTile extends StatefulWidget {
  final String setKey;
  final int setIndex;
  final double weight;
  final int reps;
  final bool isCompleted;
  final bool isLastSet;
  final Function(bool isCompleted) onSetCompleted;

  const _SetTile({
    super.key,
    required this.setKey,
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.isCompleted,
    required this.isLastSet,
    required this.onSetCompleted,
  });

  @override
  State<_SetTile> createState() => _SetTileState();
}

class _SetTileState extends State<_SetTile> {
  late bool _isCompleted;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
      if (_isCompleted) {
        _confettiController.play();
        HapticFeedback.mediumImpact();
      }
      // 부모에게 완료 상태 전달
      widget.onSetCompleted(_isCompleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ListTile(
          tileColor: _isCompleted ? Theme.of(context).cardColor.withValues(alpha: 0.5) : null,
          leading: InkWell(
            onTap: _toggleCompletion,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCompleted ? const Color(0xFF007AFF) : Colors.grey,
                  width: 2,
                ),
                color: _isCompleted ? const Color(0xFF007AFF) : Colors.transparent,
              ),
              child: _isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Center(
                      child: Text(
                        '${widget.setIndex + 1}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ),
          title: Text(
            '${widget.weight} kg × ${widget.reps} 회',
            style: TextStyle(
              decoration: _isCompleted ? TextDecoration.lineThrough : null,
              color: _isCompleted ? BurnFitStyle.secondaryGrayText : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: widget.isLastSet
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '마지막',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }
}
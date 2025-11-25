import 'dart:async';
import 'package:flutter/material.dart';
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
  Timer? _timer;
  int _seconds = 0;
  // 휴식 타이머 관련 상태
  int _defaultRestDuration = 60; // 기본 휴식 시간 60초
  Timer? _restTimer;
  int? _restSecondsRemaining;

  @override
  void initState() {
    super.initState();
    _sessionFuture = widget.sessionRepo.get(widget.sessionRepo.ymd(DateTime.now()));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _startRestTimer() {
    _restTimer?.cancel(); // 기존 타이머가 있으면 취소
    setState(() {
      _restSecondsRemaining = _defaultRestDuration;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining! > 0) {
        setState(() {
          _restSecondsRemaining = _restSecondsRemaining! - 1;
        });
      } else {
        _restTimer?.cancel();
        setState(() {
          _restSecondsRemaining = null;
        });
        // TODO: 휴식 종료 시 알림 (소리, 진동 등)
      }
    });
  }

  bool get _isResting => _restSecondsRemaining != null && _restSecondsRemaining! > 0;

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _endWorkout(Session session) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ErrorHandler.showConfirmDialog(
      context,
      l10n.endWorkout,
      l10n.endWorkoutConfirm,
    );

    if (confirmed && mounted) {
      session.durationInSeconds = _seconds;
      await widget.sessionRepo.put(session);
      if (mounted) {
        // 캘린더 탭(1)으로 이동
        Navigator.of(context).pop(1);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  Future<void> _showRestSettingsDialog() async {
    final l10n = AppLocalizations.of(context);
    var selectedDuration = _defaultRestDuration;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return RadioGroup<int>(
            onChanged: (value) {
              if (value != null) setState(() => selectedDuration = value);
            },
            child: AlertDialog(
              title: Text(l10n.restTimeSetting),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [30, 60, 90, 120].map((seconds) {
                  return InkWell(
                    onTap: () {
                      setState(() => selectedDuration = seconds);
                      Navigator.of(context).pop(seconds);
                    },
                    child: RadioListTile<int>(
                      title: Text(l10n.seconds(seconds)),
                      value: seconds,
                      toggleable: selectedDuration == seconds,
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
              ],
            ),
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _defaultRestDuration = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todayWorkout),
        centerTitle: true,
        backgroundColor: BurnFitStyle.primaryBlue,
        foregroundColor: BurnFitStyle.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            onPressed: _showRestSettingsDialog,
            tooltip: l10n.restTimeSetting,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 스톱워치
              Container(
                color: BurnFitStyle.primaryBlue,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  _formatDuration(_seconds),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: BurnFitStyle.white,
                    fontFamily: 'monospace',
                  ),
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
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () => _endWorkout(session),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BurnFitStyle.warningRed,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(l10n.endAndSaveWorkout, style: const TextStyle(color: Colors.white)),
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
                              return _SetTile(
                                setIndex: setIndex,
                                weight: set.weight,
                                reps: set.reps,
                                onSetCompleted: () {
                                  // 마지막 세트가 아니면 휴식 타이머 시작
                                  if (setIndex < exercise.sets.length - 1) {
                                    _startRestTimer();
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
          // 휴식 타이머 오버레이
          if (_isResting) _buildRestTimerOverlay(),
        ],
      ),
    );
  }

  Widget _buildRestTimerOverlay() {
    final progress = _restSecondsRemaining! / _defaultRestDuration;
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(BurnFitStyle.primaryBlue),
                  ),
                  Center(
                    child: Text(
                      '$_restSecondsRemaining',
                      style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _restTimer?.cancel();
                setState(() {
                  _restSecondsRemaining = null;
                });
              },
              child: Text(AppLocalizations.of(context).skipRest),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetTile extends StatefulWidget {
  final int setIndex;
  final double weight;
  final int reps;
  final VoidCallback onSetCompleted;


  const _SetTile({
    required this.setIndex,
    required this.weight,
    required this.reps,
    required this.onSetCompleted,
  });

  @override
  State<_SetTile> createState() => _SetTileState();
}

class _SetTileState extends State<_SetTile> {
  bool _isCompleted = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ListTile(
          tileColor: _isCompleted ? Theme.of(context).cardColor.withValues(alpha: 0.5) : null,
          leading: InkWell(
            onTap: () {
              setState(() {
                _isCompleted = !_isCompleted;
                if (_isCompleted) {
                  _confettiController.play();
                  HapticFeedback.mediumImpact();
                  widget.onSetCompleted();
                }
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _isCompleted ? BurnFitStyle.primaryBlue : Colors.grey),
                color: _isCompleted ? BurnFitStyle.primaryBlue : Colors.transparent,
              ),
              child: _isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Center(child: Text('${widget.setIndex + 1}', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/session_repo.dart';
import '../data/exercise_library_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import '../core/constants.dart';
import '../core/error_handler.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';
import '../models/exercise_set.dart';

class PlanPage extends StatefulWidget {
  final DateTime date;
  final SessionRepo repo;
  final ExerciseLibraryRepo exerciseRepo;
  const PlanPage({super.key, required this.date, required this.repo, required this.exerciseRepo});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late Future<Session?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = widget.repo.get(widget.repo.ymd(widget.date));
  }

  Future<List<Session>> _loadPrev() async {
    final all = await widget.repo.listAll();
    final me = widget.repo.ymd(widget.date);
    return all.where((s) => s.ymd != me && !s.isRest && s.exercises.isNotEmpty).toList().reversed.toList();
  }

  Future<void> _copyWhole(Session s) async {
    try {
      await widget.repo.copyDay(fromYmd: s.ymd, toYmd: widget.repo.ymd(widget.date));
      if (!mounted) return;
      Navigator.pop(context, true);
      ErrorHandler.showSuccessSnackBar(context, '운동 기록이 복사되었습니다.');
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<void> _copyPick(Session s) async {
    // 간단 체크박스 다이얼로그
    final pick = await showDialog<List<int>>(
      context: context,
      builder: (ctx) {
        final selected = <int>{};
        final dialogL10n = AppLocalizations.of(ctx);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('운동 선택'),
              content: SizedBox(
                width: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: s.exercises.length,
                  itemBuilder: (_, i) {
                    final ex = s.exercises[i];
                    return CheckboxListTile(
                      value: selected.contains(i),
                      onChanged: (v) {
                        setDialogState(() {
                          if (v == true) { selected.add(i); } else { selected.remove(i); }
                        });
                      },
                      title: Text('${ex.bodyPart} - ${ex.name}'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(dialogL10n.cancel)),
                FilledButton(onPressed: () => Navigator.pop(ctx, selected.toList()), child: Text(dialogL10n.import)),
              ],
            );
          },
        );
      },
    );
    if (pick == null || pick.isEmpty) return;
    try {
      await widget.repo.copyDay(fromYmd: s.ymd, toYmd: widget.repo.ymd(widget.date), pickIndexes: pick);
      if (!mounted) return;
      Navigator.pop(context, true);
      ErrorHandler.showSuccessSnackBar(context, '선택한 운동이 복사되었습니다.');
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<void> _markRest() async {
    try {
      await widget.repo.markRest(widget.repo.ymd(widget.date), rest: true);
      if (!mounted) return;
      Navigator.pop(context, true);
      ErrorHandler.showInfoSnackBar(context, '휴식일로 설정되었습니다.');
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(context, ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<void> _fromLibrary() async {
    final l10n = AppLocalizations.of(context);
    // 저장소에서 라이브러리 가져오기
    final lib = await widget.exerciseRepo.getLibrary();

    final selected = <Exercise>[];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text('운동 선택하기', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        for (final entry in lib.entries)
                          ExpansionTile(
                            title: Text(entry.key),
                            children: [
                              for (final name in entry.value)
                                ListTile(
                                  title: Text(name),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      selected.add(Exercise(name: name, bodyPart: entry.key));
                                      ErrorHandler.showInfoSnackBar(context, l10n.added('${entry.key} - $name'));
                                    },
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
                      const Spacer(),
                      FilledButton(
                        onPressed: () async {
                          try {
                            final y = widget.repo.ymd(widget.date);
                            await widget.repo.put(Session(ymd: y, exercises: selected, isRest: false));
                            if (mounted) Navigator.pop(ctx);
                            if (mounted) Navigator.pop(context, true);
                            ErrorHandler.showSuccessSnackBar(context, l10n.exerciseAdded);
                          } catch (e) {
                            if (mounted) {
                              ErrorHandler.showErrorSnackBar(context, ErrorHandler.getUserFriendlyMessage(e));
                            }
                          }
                        },
                        child: Text(l10n.save),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.repo.ymd(widget.date))),
      body: FutureBuilder<Session?>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          final session = snapshot.data;
          // 운동 기록이 있으면 ReorderableListView 표시
          if (session != null && session.isWorkoutDay) {
            return _buildWorkoutPlanView(session);
          } else {
            // 운동 기록이 없으면 운동 만들기 UI 표시
            return _buildCreatePlanView();
          }
        },
      ),
    );
  }

  /// 운동 기록이 있을 때 표시되는 위젯 (드래그 앤 드롭 리스트)
  Widget _buildWorkoutPlanView(Session session) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      itemCount: session.exercises.length,
      itemBuilder: (context, index) {
        final exercise = session.exercises[index];
        // 각 항목을 Dismissible로 감싸 스와이프 삭제 기능을 추가합니다.
        return _buildExerciseTile(session, exercise, index);
      },
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = session.exercises.removeAt(oldIndex);
          session.exercises.insert(newIndex, item);
          HapticFeedback.mediumImpact();
        });
        try {
          await widget.repo.put(session);
          if (mounted) {
            ErrorHandler.showInfoSnackBar(context, '순서가 변경되었습니다.');
          }
        } catch (e) {
          if (mounted) {
            ErrorHandler.showErrorSnackBar(context, AppLocalizations.of(context).reorderSaveFailed);
          }
        }
      },
    );
  }

  Widget _buildExerciseTile(Session session, Exercise exercise, int index) {
    return Dismissible(
      key: ValueKey(exercise),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        final removedExercise = session.exercises.removeAt(index);
        final removedIndex = index;
        setState(() {});
        await widget.repo.put(session);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).deleted(removedExercise.name)),
              action: SnackBarAction(
                label: AppLocalizations.of(context).undo,
                onPressed: () {
                  setState(() => session.exercises.insert(removedIndex, removedExercise));
                  widget.repo.put(session);
                },
              ),
            ),
          );
        }
      },
      child: Card(
        child: ExpansionTile(
          leading: const Icon(Icons.fitness_center),
          title: Text(exercise.name),
          subtitle: Text(exercise.bodyPart),
          trailing: const Icon(Icons.drag_handle),
          children: [
            for (int setIndex = 0; setIndex < exercise.sets.length; setIndex++)
              _SetRow(
                key: ObjectKey(exercise.sets[setIndex]), // 각 세트에 고유 키 부여
                session: session,
                exercise: exercise,
                setIndex: setIndex,
                repo: widget.repo,
                onSetRemoved: () {
                  setState(() {
                    exercise.sets.removeAt(setIndex);
                  });
                  widget.repo.put(session);
                },
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).addSet),
                  onPressed: () {
                    setState(() {
                      exercise.sets.add(ExerciseSet());
                    });
                    widget.repo.put(session);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 운동 기록이 없을 때 표시되는 위젯
  Widget _buildCreatePlanView() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('운동 기록', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.smallPadding),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.repo.ymd(widget.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(AppLocalizations.of(context).planYourWorkout),
                  const SizedBox(height: AppConstants.smallPadding),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final prev = await _loadPrev();
                          if (!mounted) return;
                          await showModalBottomSheet<void>(
                            context: context,
                            builder: (ctx) => PrevListSheet(
                              prev: prev,
                              onCopyWhole: _copyWhole,
                              onCopyPick: _copyPick,
                            ),
                          );
                        },
                        child: const Text('불러오기'),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      FilledButton(onPressed: _fromLibrary, child: const Text('운동 선택하기')),
                      const Spacer(),
                      TextButton(onPressed: _markRest, child: const Text('전체 휴식')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 각 세트의 UI와 상태를 관리하는 StatefulWidget
class _SetRow extends StatefulWidget {
  final Session session;
  final Exercise exercise;
  final int setIndex;
  final SessionRepo repo;
  final VoidCallback onSetRemoved;

  const _SetRow({
    super.key,
    required this.session,
    required this.exercise,
    required this.setIndex,
    required this.repo,
    required this.onSetRemoved,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    final currentSet = widget.exercise.sets[widget.setIndex];
    _weightController = TextEditingController(text: currentSet.weight.toString());
    _repsController = TextEditingController(text: currentSet.reps.toString());

    _weightController.addListener(_onWeightChanged);
    _repsController.addListener(_onRepsChanged);
  }

  void _onWeightChanged() {
    _debouncer.run(() {
      final newWeight = double.tryParse(_weightController.text) ?? 0.0;
      if (mounted && widget.exercise.sets[widget.setIndex].weight != newWeight) {
        widget.exercise.sets[widget.setIndex].weight = newWeight;
        widget.repo.put(widget.session);
      }
    });
  }

  void _onRepsChanged() {
    _debouncer.run(() {
      final newReps = int.tryParse(_repsController.text) ?? 0;
      if (mounted && widget.exercise.sets[widget.setIndex].reps != newReps) {
        widget.exercise.sets[widget.setIndex].reps = newReps;
        widget.repo.put(widget.session);
      }
    });
  }

  @override
  void dispose() {
    _weightController.removeListener(_onWeightChanged);
    _repsController.removeListener(_onRepsChanged);
    _weightController.dispose();
    _repsController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Text(AppLocalizations.of(context).setNumber(widget.setIndex + 1), style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).weightKg, isDense: true),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).reps, isDense: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () {
              if (widget.exercise.sets.length > 1) {
                widget.onSetRemoved();
              } else {
                ErrorHandler.showInfoSnackBar(context, AppLocalizations.of(context).minOneSet);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 입력 디바운싱을 위한 헬퍼 클래스
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class PrevListSheet extends StatelessWidget {
  final List<Session> prev;
  final Future<void> Function(Session) onCopyWhole;
  final Future<void> Function(Session) onCopyPick;
  const PrevListSheet({
    super.key,
    required this.prev,
    required this.onCopyWhole,
    required this.onCopyPick,
  });

  @override
  Widget build(BuildContext context) {
    if (prev.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('불러올 이전 기록이 없습니다.'),
      );
    }
    return SafeArea(
      child: ListView.builder(
        itemCount: prev.length,
        itemBuilder: (_, i) {
          final s = prev[i];
          return ListTile(
            title: Text(s.ymd),
            subtitle: Text(s.exercises.map((e) => e.name).join(', ')),
            trailing: Wrap(
              children: [
                TextButton(onPressed: () => onCopyPick(s), child: const Text('선택 복사')),
                FilledButton(onPressed: () => onCopyWhole(s), child: const Text('전체 복사')),
              ],
            ),
          );
        },
      ),
    );
  }
}

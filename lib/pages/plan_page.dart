import 'package:flutter/material.dart';
import '../data/session_repo.dart';
import '../models/session.dart';
import '../models/exercise.dart';

class PlanPage extends StatefulWidget {
  final DateTime date;
  final SessionRepo repo;
  const PlanPage({super.key, required this.date, required this.repo});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  Future<List<Session>> _loadPrev() async {
    final all = await widget.repo.listAll();
    final me = widget.repo.ymd(widget.date);
    return all.where((s) => s.ymd != me && !s.isRest && s.exercises.isNotEmpty).toList().reversed.toList();
  }

  Future<void> _copyWhole(Session s) async {
    await widget.repo.copyDay(fromYmd: s.ymd, toYmd: widget.repo.ymd(widget.date));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _copyPick(Session s) async {
    // 간단 체크박스 다이얼로그
    final pick = await showDialog<List<int>>(
      context: context,
      builder: (ctx) {
        final selected = <int>{};
        return AlertDialog(
          title: const Text('운동 선택'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: s.exercises.length,
              itemBuilder: (_, i) {
                final ex = s.exercises[i];
                final checked = selected.contains(i);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (v) {
                    if (v == true) { selected.add(i); } else { selected.remove(i); }
                    (ctx as Element).markNeedsBuild();
                  },
                  title: Text('${ex.bodyPart} - ${ex.name}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
            FilledButton(onPressed: () => Navigator.pop(ctx, selected.toList()), child: const Text('가져오기')),
          ],
        );
      },
    );
    if (pick == null || pick.isEmpty) return;
    await widget.repo.copyDay(fromYmd: s.ymd, toYmd: widget.repo.ymd(widget.date), pickIndexes: pick);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _markRest() async {
    await widget.repo.markRest(widget.repo.ymd(widget.date), rest: true);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _fromLibrary() async {
    // 초간단 더미 라이브러리 (추가/수정 가능)
    const lib = <String, List<String>>{
      '가슴': ['벤치프레스', '인클라인 덤벨프레스', '체스트 프레스'],
      '등': ['랫풀다운', '바벨 로우', '시티드 로우'],
      '어깨': ['사이드 레터럴', '숄더 프레스', '리어 델트 플라이'],
      '팔': ['바벨 컬', '케이블 푸시다운', '해머 컬'],
      '하체': ['스쿼트', '레그 프레스', '레그 컬'],
      '복근': ['크런치', '행잉 레그레이즈', '케이블 크런치'],
      '유산소': ['싸이클', '런닝머신', '로잉'],
    };

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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('추가됨: ${entry.key} - $name')),
                                      );
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
                          final y = widget.repo.ymd(widget.date);
                          await widget.repo.put(Session(ymd: y, exercises: selected, isRest: false));
                          if (mounted) Navigator.pop(ctx);
                          if (mounted) Navigator.pop(context, true);
                        },
                        child: const Text('저장'),
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
    final ymd = (context.findAncestorWidgetOfExactType<MaterialApp>()?.title ?? '') + widget.repo.ymd(widget.date);
    // 상단 텍스트만 의미 없이 섞여서 나오는 게 싫어 다이얼로그 타이틀로만 표시
    return Scaffold(
      appBar: AppBar(title: Text('${widget.repo.ymd(widget.date)}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('운동 기록', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.repo.ymd(widget.date)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('운동을 직접 계획해보세요!'),
                    const SizedBox(height: 12),
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
                        const SizedBox(width: 12),
                        FilledButton(onPressed: _fromLibrary, child: const Text('운동 선택하기')),
                        const Spacer(),
                        TextButton(
                          onPressed: _markRest,
                          child: const Text('전체 휴식'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

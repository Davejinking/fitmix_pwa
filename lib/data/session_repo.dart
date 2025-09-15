import 'package:hive_flutter/hive_flutter.dart';
import '../models/session.dart';
import '../models/exercise.dart';
import 'package:intl/intl.dart';

abstract class SessionRepo {
  Future<void> init();
  String ymd(DateTime d);
  Future<Session?> get(String ymd);
  Future<void> put(Session s);
  Future<void> delete(String ymd);
  Future<List<Session>> listAll();
  Future<void> markRest(String ymd, {required bool rest});
  Future<void> copyDay({
    required String fromYmd,
    required String toYmd,
    List<int>? pickIndexes,
  });
}

class HiveSessionRepo implements SessionRepo {
  static const boxName = 'sessions';
  late Box<Session> _box;

  @override
  Future<void> init() async {
    // 어댑터 중복 등록 방지
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExerciseAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SessionAdapter());

    // 앱에선 initFlutter, 테스트에서 이미 Hive.init(...)된 경우 예외 무시
    try {
      await Hive.initFlutter();
    } catch (_) {
      // 이미 초기화된 환경(예: 테스트)에서는 무시
    }

    // 이미 열려 있으면 재사용, 아니면 오픈
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<Session>(boxName);
    } else {
      _box = await Hive.openBox<Session>(boxName);
    }
  }

  @override
  String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Future<Session?> get(String ymd) async => _box.get(ymd);

  @override
  Future<void> put(Session s) async => _box.put(s.ymd, s);

  @override
  Future<void> delete(String ymd) async => _box.delete(ymd);

  @override
  Future<List<Session>> listAll() async {
    final list = _box.values.toList();
    list.sort((a, b) => a.ymd.compareTo(b.ymd));
    return list;
  }

  @override
  Future<void> markRest(String ymd, {required bool rest}) async {
    final existing = await get(ymd);
    if (existing != null) {
      existing.isRest = rest;
      if (rest) existing.exercises.clear();
      await put(existing);
    } else {
      await put(Session(ymd: ymd, isRest: rest));
    }
  }

  @override
  Future<void> copyDay({
    required String fromYmd,
    required String toYmd,
    List<int>? pickIndexes,
  }) async {
    final from = await get(fromYmd);
    if (from == null || (from.exercises.isEmpty && !from.isRest)) {
      throw StateError('복사할 세션이 없습니다: $fromYmd');
    }

    final picked = pickIndexes == null
        ? from.exercises
        : [
            for (final i in pickIndexes)
              if (i >= 0 && i < from.exercises.length)
                Exercise(
                  name: from.exercises[i].name,
                  bodyPart: from.exercises[i].bodyPart,
                ),
          ];

    await put(Session(ymd: toYmd, exercises: List.of(picked), isRest: false));
  }
}

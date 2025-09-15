import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/models/session.dart';
import 'package:fitmix_pwa/models/exercise.dart';

void main() {
  late HiveSessionRepo repo;
  late Directory tmp;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // ✅ 테스트용 임시 디렉터리에서 Hive 초기화
    tmp = await Directory.systemTemp.createTemp('fitmix_hive_test_');
    await Hive.close(); // 혹시 열려있던 글로벌 Hive 정리
    Hive.init(tmp.path);

    repo = HiveSessionRepo();
    await repo.init(); // 어댑터 등록 + 박스 오픈 (repo 쪽 코드 그대로 사용)

    if (Hive.isBoxOpen(HiveSessionRepo.boxName)) {
      await Hive.box<Session>(HiveSessionRepo.boxName).clear();
    }
  });

  tearDown(() async {
    if (Hive.isBoxOpen(HiveSessionRepo.boxName)) {
      await Hive.box<Session>(HiveSessionRepo.boxName).close();
      await Hive.deleteBoxFromDisk(HiveSessionRepo.boxName);
    }
    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  });

  test('세션 저장/복사 성공', () async {
    final y1 = '2025-09-15';
    final y2 = '2025-09-16';
    await repo.put(Session(
      ymd: y1,
      exercises: [Exercise(name: '벤치프레스', bodyPart: '가슴')],
    ));
    await repo.copyDay(fromYmd: y1, toYmd: y2);
    final s2 = await repo.get(y2);
    expect(s2?.exercises.length, 1); // ✅ 성공 케이스
  });

  test('존재하지 않는 날 복사 시 에러', () async {
    final y1 = '2025-09-01';
    final y2 = '2025-09-02';
    // ✅ 비동기 에러 검증은 expectLater 사용
    await expectLater(
      repo.copyDay(fromYmd: y1, toYmd: y2),
      throwsA(isA<StateError>()),
    );
  });
}

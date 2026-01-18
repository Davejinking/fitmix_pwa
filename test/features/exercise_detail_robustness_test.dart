import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';
import 'package:fitmix_pwa/data/session_repo.dart';
import 'package:fitmix_pwa/data/exercise_library_repo.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

class MockSessionRepo extends Mock implements SessionRepo {}
class MockExerciseLibraryRepo extends Mock implements ExerciseLibraryRepo {}

void main() {
  late MockSessionRepo mockSessionRepo;
  late MockExerciseLibraryRepo mockExerciseRepo;

  setUp(() {
    mockSessionRepo = MockSessionRepo();
    mockExerciseRepo = MockExerciseLibraryRepo();
  });

  Widget createSubject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ko'),
      home: ExerciseDetailPage(
        exerciseName: 'Bench Press',
        sessionRepo: mockSessionRepo,
        exerciseRepo: mockExerciseRepo,
      ),
    );
  }

  testWidgets('T19: 과거 기록이 없을 때(빈 리스트) 크래시 없이 "기록이 없습니다" 표시', (tester) async {
    // Given
    when(() => mockSessionRepo.getRecentExerciseHistory(any()))
        .thenAnswer((_) async => []);

    // When
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle(); // 비동기 로딩 대기

    // Then
    expect(find.text('기록이 없습니다'), findsOneWidget);
  });

  testWidgets('T18: 과거 기록 조회가 오류가 나도 안전하게 처리(빈 상태 유지)', (tester) async {
    // Given: 예외 발생 시뮬레이션
    when(() => mockSessionRepo.getRecentExerciseHistory(any()))
        .thenThrow(Exception('DB Error'));

    // When
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Then
    // 현재 구현상 catch 블록에서 isLoadingHistory = false 처리만 하고, 리스트는 초기값 [] 유지
    expect(find.text('기록이 없습니다'), findsOneWidget);
  });
}

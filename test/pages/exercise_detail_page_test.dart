import 'package:fitmix_pwa/models/exercise_db.dart';
import 'package:fitmix_pwa/pages/exercise_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/l10n/app_localizations.dart';

void main() {
  testWidgets('ExerciseDetailPage renders exercise details correctly in English', (WidgetTester tester) async {
    // 1. Setup sample data
    final exercise = ExerciseDB(
      id: 'test_id',
      name: 'Push-up',
      bodyPart: 'chest',
      equipment: 'body weight',
      gifUrl: 'test_url',
      target: 'pectorals',
      secondaryMuscles: ['triceps', 'delts'],
      instructions: ['Lower your body.', 'Push back up.'],
    );

    // 2. Pump widget with localization
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ExerciseDetailPage(exercise: exercise),
      ),
    );

    await tester.pumpAndSettle();

    // 3. Verify content
    // Check Title
    expect(find.text('Push-up'), findsOneWidget);

    // Check Basic Info
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('Body Part'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);

    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Bodyweight'), findsOneWidget);

    // Check Instructions
    // In English, it falls back to the provided instructions
    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Lower your body.'), findsOneWidget);
    expect(find.text('Push back up.'), findsOneWidget);

    // Check Targets
    expect(find.text('Primary Target Muscles'), findsOneWidget);
    expect(find.text('Pectorals'), findsOneWidget);

    // Check Secondary Muscles
    expect(find.text('Secondary Muscles'), findsOneWidget);
    expect(find.text('Triceps'), findsOneWidget);
    expect(find.text('Delts'), findsOneWidget);

    // Check Add Button
    expect(find.text('Add to Workout Plan'), findsOneWidget);
  });

  testWidgets('ExerciseDetailPage renders exercise details correctly in Korean', (WidgetTester tester) async {
     // 1. Setup sample data
    final exercise = ExerciseDB(
      id: 'test_id',
      name: 'Push-up',
      bodyPart: 'chest',
      equipment: 'body weight',
      gifUrl: 'test_url',
      target: 'pectorals',
      secondaryMuscles: [],
      instructions: [],
    );

    // 2. Pump widget with localization
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        home: ExerciseDetailPage(exercise: exercise),
      ),
    );

    await tester.pumpAndSettle();

    // Check Title (Push-up -> 푸시업)
    expect(find.text('푸시업'), findsOneWidget);

    // Check Basic Info
    expect(find.text('기본 정보'), findsOneWidget);
    expect(find.text('가슴'), findsOneWidget);
    expect(find.text('맨몸'), findsOneWidget);

    // Check Instructions (Mapped in ExerciseDB)
    expect(find.text('운동 방법'), findsOneWidget);
    expect(find.text('팔굽혀펴기 자세를 취합니다.'), findsOneWidget);
    expect(find.text('가슴이 바닥에 가까워질 때까지 몸을 내립니다.'), findsOneWidget);
    expect(find.text('원래 위치까지 몸을 밀어 올립니다.'), findsOneWidget);

    // Check Targets
    expect(find.text('주요 타겟 근육'), findsOneWidget);
    expect(find.text('가슴근'), findsOneWidget);

    // Check Add Button
    expect(find.text('운동 계획에 추가'), findsOneWidget);
  });
}

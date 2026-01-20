
import 'package:fitmix_pwa/l10n/app_localizations.dart';
import 'package:fitmix_pwa/models/exercise.dart';
import 'package:fitmix_pwa/models/exercise_set.dart';
import 'package:fitmix_pwa/widgets/workout/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Session 01 - T01 & T02 Input Validation', () {
    late Exercise testExercise;

    setUp(() {
      testExercise = Exercise(
        name: 'Bench Press',
        bodyPart: 'Chest',
        sets: [
          ExerciseSet(weight: 0, reps: 0),
        ],
      );
    });

    Future<void> pumpExerciseCard(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ko'),
          ],
          locale: const Locale('ko'), // 한국어 환경 테스트
          home: Scaffold(
            body: ExerciseCard(
              exercise: testExercise,
              exerciseIndex: 0,
              onDelete: () {},
              onUpdate: () {},
              onSetCompleted: (val) {},
              isWorkoutStarted: true, // 운동 중 상태
              isEditingEnabled: true,
              forceExpanded: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('T01: 0kg 입력 시 완료 체크가 차단되고 경고가 표시되어야 함', (WidgetTester tester) async {
      // 1. 초기 상태 렌더링 (weight=0, reps=0)
      await pumpExerciseCard(tester);

      // 2. reps를 유효한 값(10)으로 설정 (weight는 0 유지)
      final repsField = find.widgetWithText(TextField, '0').at(1); // 두 번째 입력 필드가 reps
      await tester.enterText(repsField, '10');
      testExercise.sets[0].reps = 10; // 모델 동기화 (실제 앱에선 컨트롤러 리스너가 수행)
      await tester.pumpAndSettle();

      // 3. 완료 체크박스 탭 (GestureDetector 찾기)
      // _SetRowGrid의 마지막 Expanded 컬럼이 체크박스 영역임.
      // Checkbox 위젯을 찾거나, 해당 영역을 탭.
      final checkboxFinder = find.byType(Checkbox);

      // 체크박스는 ScaleTransition 등으로 감싸져 있을 수 있으므로 GestureDetector를 찾음
      // 여기서는 Checkbox 위젯이 렌더링되어 있다면 그것을 탭
      expect(checkboxFinder, findsOneWidget);
      await tester.tap(checkboxFinder);
      await tester.pump(); // 스낵바 애니메이션 시작

      // 4. 기대 결과: isCompleted가 false여야 함 (변화 없음)
      expect(testExercise.sets[0].isCompleted, isFalse);

      // 5. 기대 결과: 경고 스낵바 표시 ('무게와 횟수를 입력해주세요')
      // AppLocalizations.ko.arb의 'enterWeightAndReps' 값 확인 필요.
      // 여기서는 텍스트가 화면에 존재하는지로 확인.
      expect(find.text('무게와 횟수를 입력해주세요'), findsOneWidget);
    });

    testWidgets('T02: 0reps 입력 시 완료 체크가 차단되고 경고가 표시되어야 함', (WidgetTester tester) async {
      // 1. 초기 상태 렌더링
      await pumpExerciseCard(tester);

      // 2. weight를 유효한 값(100)으로 설정 (reps는 0 유지)
      final weightField = find.widgetWithText(TextField, '0').first; // 첫 번째가 weight
      await tester.enterText(weightField, '100');
      testExercise.sets[0].weight = 100.0;
      await tester.pumpAndSettle();

      // 3. 완료 체크박스 탭
      final checkboxFinder = find.byType(Checkbox);
      await tester.tap(checkboxFinder);
      await tester.pump();

      // 4. 기대 결과: isCompleted가 false여야 함
      expect(testExercise.sets[0].isCompleted, isFalse);

      // 5. 기대 결과: 경고 스낵바 표시
      expect(find.text('무게와 횟수를 입력해주세요'), findsOneWidget);
    });

    testWidgets('유효한 값 입력 시 완료 체크가 정상 동작해야 함', (WidgetTester tester) async {
      // 1. 초기 상태 렌더링
      await pumpExerciseCard(tester);

      // 2. weight=60, reps=12 입력
      final weightField = find.widgetWithText(TextField, '0').first;
      final repsField = find.widgetWithText(TextField, '0').at(1);

      await tester.enterText(weightField, '60');
      testExercise.sets[0].weight = 60.0;

      await tester.enterText(repsField, '12');
      testExercise.sets[0].reps = 12;

      await tester.pumpAndSettle();

      // 3. 완료 체크박스 탭
      final checkboxFinder = find.byType(Checkbox);
      await tester.tap(checkboxFinder);
      await tester.pump();

      // 4. 기대 결과: isCompleted가 true로 변경되어야 함
      // 주의: 실제 앱에서는 setState로 다시 빌드되지만, 여기서는 모델이 직접 업데이트 되는지 확인하거나
      // UI상 체크박스 상태가 변했는지 확인.
      // _SetRowGrid 내부에서 setState(() => set.isCompleted = isChecked)를 호출함.
      // 따라서 외부 모델 객체 testExercise.sets[0]의 상태도 반영되어야 함 (객체 참조이므로).
      expect(testExercise.sets[0].isCompleted, isTrue);

      // 5. 스낵바가 없어야 함
      expect(find.text('무게와 횟수를 입력해주세요'), findsNothing);
    });
  });
}

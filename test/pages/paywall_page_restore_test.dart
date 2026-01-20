import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fitmix_pwa/pages/paywall_page.dart';
import 'package:fitmix_pwa/services/pro_service.dart';

// Mock ProService
class MockProService extends Mock implements ProService {
  @override
  bool get isPro => false;

  @override
  Future<bool> restorePurchases() {
    return super.noSuchMethod(
      Invocation.method(#restorePurchases, []),
      returnValue: Future.value(true),
      returnValueForMissingStub: Future.value(true),
    );
  }
}

void main() {
  late MockProService mockProService;

  setUp(() {
    mockProService = MockProService();
    // Inject mock
    proServiceInstance = mockProService;
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: PaywallPage(),
    );
  }

  testWidgets('Restore button calls restorePurchases and shows success message',
      (WidgetTester tester) async {
    // Arrange
    when(mockProService.restorePurchases()).thenAnswer((_) async => true);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Animation

    // Find Restore button (TextButton with text '구매 복원')
    final restoreBtn = find.text('구매 복원');
    expect(restoreBtn, findsOneWidget);

    await tester.tap(restoreBtn);
    await tester.pump(); // Start loading/async
    await tester.pump(const Duration(milliseconds: 100)); // Process future

    // Assert
    verify(mockProService.restorePurchases()).called(1);

    await tester.pumpAndSettle(); // SnackBar animation
    expect(find.text('구매 내역이 복원되었습니다.'), findsOneWidget);
  });

  testWidgets('Restore button shows no purchase message when restore returns false',
      (WidgetTester tester) async {
    // Arrange
    when(mockProService.restorePurchases()).thenAnswer((_) async => false);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final restoreBtn = find.text('구매 복원');
    await tester.tap(restoreBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    verify(mockProService.restorePurchases()).called(1);

    await tester.pumpAndSettle();
    expect(find.text('복원할 구매 내역이 없습니다.'), findsOneWidget);
  });

  testWidgets('Restore button shows error message when restore throws exception',
      (WidgetTester tester) async {
    // Arrange
    when(mockProService.restorePurchases()).thenThrow(Exception('Network Error'));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final restoreBtn = find.text('구매 복원');
    await tester.tap(restoreBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    verify(mockProService.restorePurchases()).called(1);

    await tester.pumpAndSettle();
    expect(find.text('복원 중 오류가 발생했습니다.'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:fitmix_pwa/pages/paywall_page.dart';
import 'package:fitmix_pwa/services/subscription_service.dart';

@GenerateMocks([SubscriptionService])
import 'paywall_page_test.mocks.dart';

void main() {
  late MockSubscriptionService mockSubscriptionService;

  setUp(() {
    mockSubscriptionService = MockSubscriptionService();
    GetIt.I.registerSingleton<SubscriptionService>(mockSubscriptionService);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: PaywallPage(),
    );
  }

  testWidgets('PaywallPage should call purchase when button is tapped', (WidgetTester tester) async {
    // Arrange
    when(mockSubscriptionService.purchase(any)).thenAnswer((_) async => true);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    // Use pump instead of pumpAndSettle because of infinite animation in PaywallPage (Shimmer)
    await tester.pump(const Duration(milliseconds: 100));

    final purchaseButton = find.byType(ElevatedButton);
    await tester.tap(purchaseButton);

    // Allow async operation to complete and UI to update
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    verify(mockSubscriptionService.purchase('lifetime_pro')).called(1);

    // SnackBar appears
    expect(find.text('Iron Log PRO 시작을 환영합니다! 🎉'), findsOneWidget);
  });

  testWidgets('PaywallPage should call restore when restore button is tapped', (WidgetTester tester) async {
    // Arrange
    when(mockSubscriptionService.restore()).thenAnswer((_) async => true);

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    final restoreButton = find.text('구매 복원');
    await tester.tap(restoreButton);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Assert
    verify(mockSubscriptionService.restore()).called(1);
    expect(find.text('구매가 성공적으로 복원되었습니다!'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:iron_log/services/pro_service.dart';
import 'package:iron_log/services/subscription_service.dart';

// Mock 클래스 수동 정의 (build_runner 없이 실행하기 위함)
class MockSubscriptionService extends Mock implements SubscriptionService {
  @override
  Future<bool> restorePurchases() {
    return super.noSuchMethod(
      Invocation.method(#restorePurchases, []),
      returnValue: Future.value(false),
      returnValueForMissingStub: Future.value(false),
    );
  }
}

void main() {
  late ProService proService;
  late MockSubscriptionService mockSubscriptionService;

  setUp(() {
    GetIt.instance.reset();
    mockSubscriptionService = MockSubscriptionService();
    GetIt.instance.registerSingleton<SubscriptionService>(mockSubscriptionService);
    proService = ProService();
    // ProService.init()은 호출하지 않음 (Hive 의존성 회피)
    // restorePurchases 메서드는 Hive Box에 직접 접근하지 않으므로 테스트 가능
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('ProService Tests', () {
    test('restorePurchases calls SubscriptionService.restorePurchases and returns true', () async {
      // Arrange
      when(mockSubscriptionService.restorePurchases())
          .thenAnswer((_) async => true);

      // Act
      final result = await proService.restorePurchases();

      // Assert
      expect(result, isTrue);
      verify(mockSubscriptionService.restorePurchases()).called(1);
    });

    test('restorePurchases calls SubscriptionService.restorePurchases and returns false', () async {
      // Arrange
      when(mockSubscriptionService.restorePurchases())
          .thenAnswer((_) async => false);

      // Act
      final result = await proService.restorePurchases();

      // Assert
      expect(result, isFalse);
      verify(mockSubscriptionService.restorePurchases()).called(1);
    });

    test('restorePurchases handles exception and returns false', () async {
      // Arrange
      when(mockSubscriptionService.restorePurchases())
          .thenThrow(Exception('RevenueCat error'));

      // Act
      final result = await proService.restorePurchases();

      // Assert
      expect(result, isFalse);
      verify(mockSubscriptionService.restorePurchases()).called(1);
    });
  });
}

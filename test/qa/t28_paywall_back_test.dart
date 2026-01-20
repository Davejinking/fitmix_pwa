import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/paywall_page.dart';

void main() {
  testWidgets('T28: Paywall back navigation validation', (WidgetTester tester) async {
    // 앱 구조와 유사하게 설정
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallPage()),
              );
            },
            child: const Text('Open Paywall'),
          ),
        ),
      ),
    ));

    // 초기 상태
    expect(find.text('Open Paywall'), findsOneWidget);

    // Paywall 열기
    await tester.tap(find.text('Open Paywall'));
    await tester.pump(); // 애니메이션 시작
    await tester.pump(const Duration(milliseconds: 500)); // 화면 전환 대기

    // Paywall 표시 확인
    expect(find.byType(PaywallPage), findsOneWidget);
    expect(find.text('Iron Log PRO'), findsOneWidget);

    // 닫기 버튼 찾기 (아이콘으로 찾기)
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);

    // 닫기 버튼 탭
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    // 원래 화면 복귀 확인
    expect(find.text('Open Paywall'), findsOneWidget);
    expect(find.byType(PaywallPage), findsNothing);
  });
}

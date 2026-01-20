import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/upgrade_page.dart';

void main() {
  testWidgets('T27: /upgrade route validation', (WidgetTester tester) async {
    // 앱 구조와 유사하게 라우트 설정
    await tester.pumpWidget(MaterialApp(
      routes: {
        '/': (context) => Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/upgrade'),
                    child: const Text('Go Upgrade'),
                  ),
                ),
              ),
            ),
        '/upgrade': (context) => const UpgradePage(),
      },
      initialRoute: '/',
    ));

    // 초기 상태 확인
    expect(find.text('Go Upgrade'), findsOneWidget);

    // 버튼 탭하여 /upgrade로 이동
    await tester.tap(find.text('Go Upgrade'));
    await tester.pumpAndSettle();

    // UpgradePage 표시 확인
    expect(find.byType(UpgradePage), findsOneWidget);
    expect(find.text('Upgrade to PRO'), findsOneWidget);
    expect(find.text('Go Back'), findsOneWidget);

    // 뒤로가기 버튼(Go Back) 탭
    await tester.tap(find.text('Go Back'));
    await tester.pumpAndSettle();

    // 원래 화면 복귀 확인
    expect(find.text('Go Upgrade'), findsOneWidget);
    expect(find.byType(UpgradePage), findsNothing);
  });
}

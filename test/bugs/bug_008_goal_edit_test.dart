// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitmix_pwa/pages/home/home_page.dart';
import 'package:fitmix_pwa/pages/user_info_form_page.dart';

void main() {
  group('BUG-008: My Goal Edit Navigation', () {
    testWidgets('Clicking Edit on My Goal card should navigate to Goal Settings, not Profile', (WidgetTester tester) async {
      final mockObserver = NavigatorObserver();

      // Note: This test expects HomePage to be renderable.
      // If environment prevents Hive initialization, this acts as a template for the fix verification.
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          navigatorObservers: [mockObserver],
          routes: {
            '/profile': (context) => const UserInfoFormPage(),
            '/goal_settings': (context) => const Scaffold(body: Text('Goal Settings')),
          },
        ),
      );

      // Find "나의 목표" text
      expect(find.text('나의 목표'), findsOneWidget);

      // Find the edit button
      final editButton = find.widgetWithIcon(IconButton, Icons.edit);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Assertion for BUG-008
      expect(find.byType(UserInfoFormPage), findsNothing, reason: "BUG-008: Should not navigate to UserInfoFormPage");
      expect(find.text('Goal Settings'), findsOneWidget, reason: "Should navigate to Goal Settings page");
    });
  });
}

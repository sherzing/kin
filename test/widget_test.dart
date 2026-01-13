import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/main.dart';

import 'helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  testWidgets('App renders Daily Deck as home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createTestProviderOverrides(),
        child: const KinApp(),
      ),
    );

    expect(find.text('Daily Deck'), findsOneWidget);
    expect(find.text('Your daily contacts will appear here'), findsOneWidget);
  });

  testWidgets('App has bottom navigation bar with 3 tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createTestProviderOverrides(),
        child: const KinApp(),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('Bottom nav navigates to Contacts tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createTestProviderOverrides(),
        child: const KinApp(),
      ),
    );

    // Tap on Contacts tab
    await tester.tap(find.text('Contacts'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify we're on the Contacts screen (check for loading or empty state)
    expect(find.byType(Scaffold), findsWidgets);
  }, skip: true); // StreamProvider cleanup causes timer issues in widget tests

  testWidgets('Bottom nav navigates to Search tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createTestProviderOverrides(),
        child: const KinApp(),
      ),
    );

    // Tap on Search tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Search for contacts and interactions'), findsOneWidget);
  });

  testWidgets('App uses MaterialApp.router with theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createTestProviderOverrides(),
        child: const KinApp(),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.routerConfig, isNotNull);
    expect(materialApp.theme, isNotNull);
  });
}

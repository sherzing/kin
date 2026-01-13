import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/main.dart';

void main() {
  testWidgets('App renders Daily Deck as home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KinApp(),
      ),
    );

    expect(find.text('Daily Deck'), findsOneWidget);
    expect(find.text('Your daily contacts will appear here'), findsOneWidget);
  });

  testWidgets('App uses MaterialApp.router with theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KinApp(),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.routerConfig, isNotNull);
    expect(materialApp.theme, isNotNull);
  });
}

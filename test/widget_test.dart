import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/main.dart';

void main() {
  testWidgets('App renders with Daily Deck as home', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KinApp(),
      ),
    );

    // go_router shows Daily Deck as home route
    expect(find.text('Daily Deck'), findsWidgets);
  });

  testWidgets('App uses MaterialApp.router', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KinApp(),
      ),
    );

    // Verify the app is using router
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.routerConfig, isNotNull);
    expect(materialApp.theme, isNotNull);
  });
}

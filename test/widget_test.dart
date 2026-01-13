import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/main.dart';

void main() {
  testWidgets('App renders with Kin title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KinApp(),
      ),
    );

    expect(find.text('Kin'), findsOneWidget);
    expect(find.text('Welcome to Kin'), findsOneWidget);
  });

  testWidgets('App uses correct theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KinApp(),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold, isNotNull);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme, isNotNull);
  });
}

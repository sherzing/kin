import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kin/presentation/screens/screens.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('Settings screen navigation', () {
    testWidgets('has a back button in app bar', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SettingsScreen());

        // Should have a back button
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    testWidgets('back button is tappable', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        // Use a simple Navigator setup to test pop behavior
        bool didPop = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: createTestProviderOverridesWithDb(db),
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => PopScope(
                              onPopInvokedWithResult: (didPop_, result) {
                                didPop = true;
                              },
                              child: const SettingsScreen(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Go to Settings'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Navigate to settings
        await tester.tap(find.text('Go to Settings'));
        await tester.pumpAndSettle();

        // Verify we're on settings
        expect(find.text('Settings'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should have popped back
        expect(didPop, isTrue);
        expect(find.text('Go to Settings'), findsOneWidget);
      });
    });

    testWidgets('settings screen shows expected sections', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SettingsScreen());

        // Should show the main sections
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Organization'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);

        // Should show menu items
        expect(find.text('Timeline'), findsOneWidget);
        expect(find.text('Manage Circles'), findsOneWidget);
        expect(find.text('About Kin'), findsOneWidget);
      });
    });
  });
}

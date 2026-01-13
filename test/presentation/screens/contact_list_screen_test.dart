import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/presentation/screens/screens.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('ContactListScreen', () {
    testWidgets('renders with app bar and FAB', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const ContactListScreen());

        expect(find.text('Contacts'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        // FAB has add icon, empty state button also has add icon
        expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
      });
    });

    testWidgets('shows empty state when no contacts', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const ContactListScreen());

        // Updated empty state text
        expect(find.text('Start building your network'), findsOneWidget);
        expect(find.textContaining('Add the people you want'), findsOneWidget);
        expect(find.byIcon(Icons.people_outline), findsOneWidget);
      });
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: createTestProviderOverridesWithDb(db),
            child: const MaterialApp(home: ContactListScreen()),
          ),
        );

        // On first pump, should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}

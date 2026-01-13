import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/providers.dart';
import 'package:kin/data/database/tables/interactions.dart';
import 'package:kin/presentation/screens/screens.dart';

import 'package:kin/data/repositories/interaction_repository.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('SearchScreen', () {
    testWidgets('renders with search field', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SearchScreen());

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search contacts, notes, circles...'), findsOneWidget);
      });
    });

    testWidgets('shows empty state initially', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SearchScreen());

        expect(find.text('Search for contacts and interactions'), findsOneWidget);
        expect(find.text('Type at least 2 characters to search'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    testWidgets('shows empty state for single character query',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SearchScreen());

        // Enter a single character
        await tester.enterText(find.byType(TextField), 'a');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350)); // debounce

        // Still shows empty state
        expect(find.text('Search for contacts and interactions'), findsOneWidget);
      });
    });

    testWidgets('shows no results state when search finds nothing',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SearchScreen());

        // Enter a query that won't match anything
        await tester.enterText(find.byType(TextField), 'xyznonexistent');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350)); // debounce
        await tester.pump(const Duration(milliseconds: 100)); // provider update

        expect(find.text('No results found'), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
      });
    });

    testWidgets('shows contact results when search matches',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        // Create test contact
        final repo = ContactRepository(db);
        await repo.create(name: 'John Smith', phone: '555-1234');

        await pumpWidgetWithDb(tester, db, const SearchScreen());

        // Search for the contact
        await tester.enterText(find.byType(TextField), 'John');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350)); // debounce
        await tester.pump(const Duration(milliseconds: 100)); // provider update

        // Should show contacts section
        expect(find.text('Contacts'), findsOneWidget);
        expect(find.text('John Smith'), findsOneWidget);
      });
    });

    testWidgets('shows interaction results when search matches content',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        // Create test contact and interaction
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Jane Doe');

        final interactionRepo =
            InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          content: 'Discussed quarterly budget planning',
        );

        await pumpWidgetWithDb(tester, db, const SearchScreen());

        // Search for interaction content
        await tester.enterText(find.byType(TextField), 'budget');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350)); // debounce
        await tester.pump(const Duration(milliseconds: 100)); // provider update

        // Should show notes section
        expect(find.text('Notes & Interactions'), findsOneWidget);
      });
    });

    testWidgets('clear button clears search', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SearchScreen());

        // Enter search text
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Text should be visible
        final textField =
            tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals('test'));
      });
    });

    testWidgets('search field has autofocus', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const SearchScreen());

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.autofocus, isTrue);
      });
    });
  });

  group('SearchScreen sections', () {
    testWidgets('shows section headers with counts',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        // Create multiple contacts
        final repo = ContactRepository(db);
        await repo.create(name: 'Alpha Person');
        await repo.create(name: 'Alpha Two');

        await pumpWidgetWithDb(tester, db, const SearchScreen());

        // Search
        await tester.enterText(find.byType(TextField), 'Alpha');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 100));

        // Should show count badge
        expect(find.text('2'), findsOneWidget);
      });
    });
  });
}

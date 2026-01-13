import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/database_providers.dart';
import 'package:kin/data/database/tables/interactions.dart';
import 'package:kin/presentation/screens/screens.dart';

import 'package:kin/data/repositories/interaction_repository.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('TimelineScreen', () {
    testWidgets('renders with title and filter button',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        expect(find.text('Timeline'), findsOneWidget);
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });
    });

    testWidgets('shows empty state when no interactions',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        expect(find.text('No interactions yet'), findsOneWidget);
        expect(
            find.text('Interactions you log will appear here'), findsOneWidget);
        expect(find.byIcon(Icons.timeline), findsOneWidget);
      });
    });

    testWidgets('shows interactions grouped by date',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        // Create contact and interaction
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Test Person');

        final interactionRepo = InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: DateTime.now(),
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Should show Today header (since we just created it)
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Test Person'), findsOneWidget);
      });
    });

    testWidgets('shows interaction type icon', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Phone Person');

        final interactionRepo = InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: DateTime.now(),
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Should show phone icon for call type
        expect(find.byIcon(Icons.phone), findsOneWidget);
      });
    });

    testWidgets('shows interaction content preview', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Content Person');

        final interactionRepo = InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.meetup,
          content: 'Had coffee at the new place downtown',
          happenedAt: DateTime.now(),
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        expect(find.textContaining('Had coffee'), findsOneWidget);
      });
    });

    testWidgets('filter button opens popup menu', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Tap filter button
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();

        // Should show filter options
        expect(find.text('All types'), findsOneWidget);
        expect(find.text('Calls'), findsOneWidget);
        expect(find.text('Meetups'), findsOneWidget);
        expect(find.text('Messages'), findsOneWidget);
        expect(find.text('Emails'), findsOneWidget);
        expect(find.text('Gifts'), findsOneWidget);
      });
    });

    testWidgets('selecting filter shows only matching interactions',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Multi Person');

        final interactionRepo = InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: DateTime.now(),
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.meetup,
          happenedAt: DateTime.now(),
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Should show both initially
        expect(find.byIcon(Icons.phone), findsOneWidget);
        expect(find.byIcon(Icons.people), findsOneWidget);

        // Open filter and select Calls
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Calls'));
        await tester.pumpAndSettle();

        // Should show only call
        expect(find.byIcon(Icons.phone), findsOneWidget);
        expect(find.byIcon(Icons.people), findsNothing);
      });
    });

    testWidgets('filter shows empty state when no matching interactions',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Call Person');

        final interactionRepo = InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: DateTime.now(),
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Filter to Gifts (which doesn't exist)
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Gifts'));
        await tester.pumpAndSettle();

        // Should show filtered empty state
        expect(find.text('No matching interactions'), findsOneWidget);
        expect(find.byIcon(Icons.filter_list_off), findsOneWidget);
      });
    });

    testWidgets('filter icon changes when filter is active',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Initially shows filter_list
        expect(find.byIcon(Icons.filter_list), findsOneWidget);

        // Apply filter
        await tester.tap(find.byIcon(Icons.filter_list));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Calls'));
        await tester.pumpAndSettle();

        // Should show filter_list_alt (active filter indicator)
        expect(find.byIcon(Icons.filter_list_alt), findsOneWidget);
      });
    });
  });

  group('TimelineScreen date grouping', () {
    testWidgets('groups interactions by date correctly',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Date Person');

        final interactionRepo = InteractionRepository(db);
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));

        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: now,
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.meetup,
          happenedAt: yesterday,
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Should show both date headers
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Yesterday'), findsOneWidget);
      });
    });
  });

  group('TimelineScreen navigation', () {
    testWidgets('interaction tiles are tappable',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final contactRepo = ContactRepository(db);
        final contact = await contactRepo.create(name: 'Nav Person');

        final interactionRepo = InteractionRepository(db);
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: DateTime.now(),
        );

        await pumpWidgetWithDb(tester, db, const TimelineScreen());

        // Verify the list tile exists and is tappable
        expect(find.text('Nav Person'), findsOneWidget);
        expect(find.byType(ListTile), findsOneWidget);
        // Navigation requires go_router in widget tree - tested in integration tests
      });
    });
  });
}

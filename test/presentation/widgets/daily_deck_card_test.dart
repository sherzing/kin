import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/data/database/database.dart';
import 'package:kin/presentation/widgets/daily_deck_card.dart';
import 'package:kin/presentation/widgets/health_ring.dart';

void main() {
  group('DailyDeckCard', () {
    Contact createContact({
      String name = 'Test Contact',
      int? lastContactedAt,
      int cadenceDays = 30,
      String? phone,
      String? email,
    }) {
      return Contact(
        id: 'test-id',
        name: name,
        avatarLocalPath: null,
        phone: phone,
        email: email,
        birthday: null,
        jobTitle: null,
        cadenceDays: cadenceDays,
        lastContactedAt: lastContactedAt,
        snoozedUntil: null,
        createdAt: 0,
        updatedAt: 0,
        deletedAt: null,
        isDirty: false,
      );
    }

    testWidgets('displays contact name', (tester) async {
      final contact = createContact(name: 'John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays initials for single name', (tester) async {
      final contact = createContact(name: 'Alice');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('displays initials for two names', (tester) async {
      final contact = createContact(name: 'John Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('displays "Never contacted" for new contacts', (tester) async {
      final contact = createContact(lastContactedAt: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('Never contacted'), findsOneWidget);
    });

    testWidgets('displays last contacted date', (tester) async {
      // 5 days ago
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      final contact = createContact(
        lastContactedAt: fiveDaysAgo.millisecondsSinceEpoch ~/ 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.textContaining('Last contacted'), findsOneWidget);
    });

    testWidgets('displays HealthRing widget', (tester) async {
      final contact = createContact();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.byType(HealthRing), findsOneWidget);
    });

    testWidgets('displays overdue chip for never contacted', (tester) async {
      final contact = createContact(lastContactedAt: null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('Needs attention'), findsOneWidget);
    });

    testWidgets('displays overdue chip for overdue contact', (tester) async {
      // 45 days ago with 30-day cadence = 15 days overdue
      final fortyFiveDaysAgo = DateTime.now().subtract(const Duration(days: 45));
      final contact = createContact(
        lastContactedAt: fortyFiveDaysAgo.millisecondsSinceEpoch ~/ 1000,
        cadenceDays: 30,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.textContaining('overdue'), findsOneWidget);
    });

    testWidgets('shows nudge button by default', (tester) async {
      final contact = createContact(phone: '555-1234');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('Reach Out'), findsOneWidget);
    });

    testWidgets('hides nudge button when showNudgeButton is false', (tester) async {
      final contact = createContact(phone: '555-1234');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact, showNudgeButton: false),
          ),
        ),
      );

      expect(find.text('Reach Out'), findsNothing);
    });

    testWidgets('shows "Add Contact Info" when no phone/email', (tester) async {
      final contact = createContact();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.text('Add Contact Info'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final contact = createContact();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(
              contact: contact,
              showNudgeButton: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(tapped, isTrue);
    });

    testWidgets('displays card with proper styling', (tester) async {
      final contact = createContact();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyDeckCard(contact: contact),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4);
    });
  });
}

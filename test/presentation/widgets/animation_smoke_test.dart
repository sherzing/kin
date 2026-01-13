import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/database_providers.dart';
import 'package:kin/data/database/database.dart';
import 'package:kin/presentation/screens/screens.dart';
import 'package:kin/presentation/widgets/widgets.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('Animation Smoke Tests', () {
    group('Hero Transitions', () {
      testWidgets('contact avatar has Hero widget in list',
          (WidgetTester tester) async {
        await testWithDatabase(tester, (db) async {
          // Create a contact
          final repo = ContactRepository(db);
          await repo.create(name: 'Hero Test');

          await pumpWidgetWithDb(tester, db, const ContactListScreen());

          // Should have a Hero widget
          expect(find.byType(Hero), findsWidgets);
        });
      });

      testWidgets('contact avatar has Hero widget in detail screen',
          (WidgetTester tester) async {
        await testWithDatabase(tester, (db) async {
          // Create a contact
          final repo = ContactRepository(db);
          final contact = await repo.create(name: 'Detail Test');

          await pumpWidgetWithDb(
            tester,
            db,
            ContactDetailScreen(contactId: contact.id),
          );

          // Should have a Hero widget for the avatar
          expect(find.byType(Hero), findsWidgets);
        });
      });

      testWidgets('DailyDeckCard has Hero widget for avatar',
          (WidgetTester tester) async {
        final contact = Contact(
          id: 'test-1',
          name: 'Deck Test',
          cadenceDays: 30,
          createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          isDirty: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DailyDeckCard(contact: contact),
            ),
          ),
        );

        expect(find.byType(Hero), findsOneWidget);
      });
    });

    group('Staggered List Animations', () {
      testWidgets('DeckCardList uses FadeTransition for cards',
          (WidgetTester tester) async {
        await testWithDatabase(tester, (db) async {
          // Create multiple contacts
          final repo = ContactRepository(db);
          await repo.create(name: 'Contact 1', cadenceDays: 1);
          await repo.create(name: 'Contact 2', cadenceDays: 1);

          // Need to make them due by setting last contacted in the past
          final contacts = await repo.getAll();
          for (final c in contacts) {
            await repo.update(
              c.id,
              lastContactedAt:
                  DateTime.now().subtract(const Duration(days: 30)),
            );
          }

          await pumpWidgetWithDb(tester, db, const DailyDeckScreen());

          // Pump to let animations start
          await tester.pump(const Duration(milliseconds: 100));

          // Should have FadeTransition for staggered animation
          expect(find.byType(FadeTransition), findsWidgets);
        });
      });

      testWidgets('DeckCardList uses SlideTransition for cards',
          (WidgetTester tester) async {
        await testWithDatabase(tester, (db) async {
          final repo = ContactRepository(db);
          await repo.create(name: 'Slide Contact', cadenceDays: 1);

          final contacts = await repo.getAll();
          for (final c in contacts) {
            await repo.update(
              c.id,
              lastContactedAt:
                  DateTime.now().subtract(const Duration(days: 30)),
            );
          }

          await pumpWidgetWithDb(tester, db, const DailyDeckScreen());
          await tester.pump(const Duration(milliseconds: 100));

          expect(find.byType(SlideTransition), findsWidgets);
        });
      });
    });

    group('Swipeable Card Animations', () {
      testWidgets('SwipeableDeckCard uses Dismissible',
          (WidgetTester tester) async {
        await testWithDatabase(tester, (db) async {
          final contact = Contact(
            id: 'swipe-test',
            name: 'Swipe Test',
            cadenceDays: 30,
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            isDirty: false,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                databaseProvider.overrideWithValue(db),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: SwipeableDeckCard(contact: contact),
                ),
              ),
            ),
          );

          expect(find.byType(Dismissible), findsOneWidget);
        });
      });

      testWidgets('SwipeableDeckCard has animation controller',
          (WidgetTester tester) async {
        await testWithDatabase(tester, (db) async {
          final contact = Contact(
            id: 'anim-test',
            name: 'Animation Test',
            cadenceDays: 30,
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            isDirty: false,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                databaseProvider.overrideWithValue(db),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: SwipeableDeckCard(contact: contact),
                ),
              ),
            ),
          );

          // AnimatedBuilder wraps the fade animation
          expect(find.byType(AnimatedBuilder), findsWidgets);
        });
      });
    });

    group('Celebration Animation', () {
      testWidgets('celebration uses CustomPaint for confetti',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('celebration animates over time', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CelebrationOverlay(),
            ),
          ),
        );

        // Initial pump
        await tester.pump();

        // Pump several times to verify animation progresses
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        // Should still be visible
        expect(find.text('All Done!'), findsOneWidget);
      });
    });

    group('Empty State Illustrations', () {
      testWidgets('AllCaughtUpIllustration renders without animation errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AllCaughtUpIllustration(),
            ),
          ),
        );

        expect(find.byType(AllCaughtUpIllustration), findsOneWidget);
      });

      testWidgets('NoContactsIllustration renders without animation errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NoContactsIllustration(),
            ),
          ),
        );

        expect(find.byType(NoContactsIllustration), findsOneWidget);
      });

      testWidgets('NoInteractionsIllustration renders without animation errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NoInteractionsIllustration(),
            ),
          ),
        );

        expect(find.byType(NoInteractionsIllustration), findsOneWidget);
      });
    });
  });
}

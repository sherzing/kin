import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kin/core/router/app_router.dart';
import 'package:kin/presentation/screens/screens.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('Contact form routing', () {
    testWidgets('navigating to /contacts/new shows contact form, not contact detail error',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        // Create a router that starts at /contacts/new
        final router = GoRouter(
          initialLocation: '/contacts/new',
          routes: [
            GoRoute(
              path: '/contacts',
              builder: (context, state) => const ContactListScreen(),
              routes: [
                // New contact route must come BEFORE :id to match first
                GoRoute(
                  path: 'new',
                  name: 'contactNew',
                  builder: (context, state) => const ContactFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'contactDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ContactDetailScreen(contactId: id);
                  },
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: createTestProviderOverridesWithDb(db),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should show "New Contact" in app bar, not "Contact Not Found"
        expect(find.text('New Contact'), findsOneWidget);
        expect(find.text('Contact not found'), findsNothing);
        expect(find.text('Contact Not Found'), findsNothing);

        // Should show form fields
        expect(find.text('Name'), findsOneWidget);
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
      });
    });

    testWidgets('FAB on contact list navigates to new contact form',
        (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        final router = GoRouter(
          initialLocation: '/contacts',
          routes: [
            GoRoute(
              path: '/contacts',
              builder: (context, state) => const ContactListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'contactNew',
                  builder: (context, state) => const ContactFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'contactDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ContactDetailScreen(contactId: id);
                  },
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: createTestProviderOverridesWithDb(db),
            child: MaterialApp.router(
              routerConfig: router,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap the FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Should navigate to new contact form
        expect(find.text('New Contact'), findsOneWidget);
        expect(find.text('Contact not found'), findsNothing);
      });
    });
  });
}

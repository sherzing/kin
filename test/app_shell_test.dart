import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kin/main.dart';
import 'package:kin/presentation/screens/screens.dart';

import 'helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('App Shell', () {
    testWidgets('renders with bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: createTestProviderOverrides(), child: const KinApp()),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
    });

    testWidgets('Home tab is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: createTestProviderOverrides(), child: const KinApp()),
      );

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, equals(0));
    });

    testWidgets('navigation preserves tab state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: createTestProviderOverrides(), child: const KinApp()),
      );

      // Go to Search first (no StreamProvider)
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Go back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Verify we're on Home
      expect(find.text('Daily Deck'), findsOneWidget);
    });
  });

  group('Placeholder Screens', () {
    testWidgets('DailyDeckScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DailyDeckScreen()),
      );

      expect(find.text('Daily Deck'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ContactListScreen renders correctly', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(tester, db, const ContactListScreen());

        expect(find.text('Contacts'), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    testWidgets('ContactDetailScreen renders with contactId', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(
          tester,
          db,
          const ContactDetailScreen(contactId: 'test-123'),
        );

        // Contact not found since test DB is empty
        expect(find.text('Contact Not Found'), findsOneWidget);
      });
    });

    testWidgets('InteractionListScreen renders with contactId', (WidgetTester tester) async {
      await testWithDatabase(tester, (db) async {
        await pumpWidgetWithDb(
          tester,
          db,
          const InteractionListScreen(contactId: 'test-456'),
        );

        // Shows Interactions in AppBar (fallback for missing contact)
        expect(find.text('Interactions'), findsOneWidget);
        // Shows empty state since test DB has no interactions
        expect(find.text('No interactions yet'), findsOneWidget);
      });
    });

    testWidgets('SearchScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SearchScreen()),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Search for contacts and interactions'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SettingsScreen()),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage Circles'), findsOneWidget);
      expect(find.text('About Kin'), findsOneWidget);
    });
  });

  group('Router', () {
    testWidgets('navigates to settings outside shell', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: createTestProviderOverrides(), child: const KinApp()),
      );

      // Find a widget that has access to the router
      final router = tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .routerConfig as GoRouter;
      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage Circles'), findsOneWidget);
      // Settings is outside shell, so no bottom nav
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}

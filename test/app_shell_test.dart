import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kin/main.dart';
import 'package:kin/presentation/screens/screens.dart';

void main() {
  group('App Shell', () {
    testWidgets('renders with bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: KinApp()),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
    });

    testWidgets('Home tab is selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: KinApp()),
      );

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, equals(0));
    });

    testWidgets('navigation preserves tab state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: KinApp()),
      );

      // Go to Contacts
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();

      // Go to Search
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
      await tester.pumpWidget(
        const MaterialApp(home: ContactListScreen()),
      );

      expect(find.text('Contacts'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ContactDetailScreen renders with contactId', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContactDetailScreen(contactId: 'test-123'),
        ),
      );

      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Contact: test-123'), findsOneWidget);
    });

    testWidgets('InteractionListScreen renders with contactId', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InteractionListScreen(contactId: 'test-456'),
        ),
      );

      expect(find.text('Interactions'), findsOneWidget);
      expect(find.text('Interactions for contact: test-456'), findsOneWidget);
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
      expect(find.text('App settings will appear here'), findsOneWidget);
    });
  });

  group('Router', () {
    testWidgets('navigates to settings outside shell', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: KinApp()),
      );

      // Find a widget that has access to the router
      final router = tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .routerConfig as GoRouter;
      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App settings will appear here'), findsOneWidget);
      // Settings is outside shell, so no bottom nav
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}

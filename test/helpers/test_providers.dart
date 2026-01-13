import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/providers/database_providers.dart';
import 'package:kin/data/database/database.dart';

// Re-export for convenience in tests
export 'package:kin/data/repositories/contact_repository.dart';

/// Set up test environment - call this at the start of tests.
void setUpTestEnvironment() {
  // Disable Drift's warning about multiple database instances in tests
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}

/// Creates an in-memory test database.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Creates provider overrides for testing with an in-memory database.
///
/// Usage:
/// ```dart
/// setUpTestEnvironment(); // Call once in setUpAll or main
/// ProviderScope(
///   overrides: createTestProviderOverrides(),
///   child: MyWidget(),
/// )
/// ```
List<Override> createTestProviderOverrides() {
  final testDb = createTestDatabase();
  return createTestProviderOverridesWithDb(testDb);
}

/// Creates provider overrides with a specific database instance.
///
/// Use this when you need to access the database directly in tests
/// to set up test data.
List<Override> createTestProviderOverridesWithDb(AppDatabase db) {
  return [
    databaseProvider.overrideWithValue(db),
  ];
}

/// Helper for widget tests that use StreamProvider/FutureProvider.
///
/// This wraps tests in runAsync to properly handle Drift's internal
/// stream timers and avoid "Timer is still pending" errors.
///
/// Usage:
/// ```dart
/// testWidgets('my test', (tester) async {
///   await testWithDatabase(tester, (db) async {
///     await pumpWidgetWithDb(tester, db, const MyWidget());
///     // ... assertions
///   });
/// });
/// ```
Future<void> testWithDatabase(
  WidgetTester tester,
  Future<void> Function(AppDatabase db) testFn,
) async {
  final db = createTestDatabase();
  try {
    await testFn(db);
  } finally {
    await tester.runAsync(() async {
      await db.close();
    });
  }
}

/// Pumps a widget with provider overrides using a specific database.
Future<void> pumpWidgetWithDb(
  WidgetTester tester,
  AppDatabase db,
  Widget child, {
  Duration settleDuration = const Duration(milliseconds: 100),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: createTestProviderOverridesWithDb(db),
      child: MaterialApp(home: child),
    ),
  );

  // Allow streams to initialize
  await tester.pump();
  await tester.pump(settleDuration);
}

/// Legacy helper - wraps widget in ProviderScope with database cleanup.
///
/// Note: For tests with StreamProvider that fail due to timer issues,
/// use testWithDatabase + pumpWidgetWithDb instead.
Future<void> pumpWidgetWithProviders(
  WidgetTester tester,
  Widget child, {
  AppDatabase? database,
  Duration settleDuration = const Duration(milliseconds: 100),
}) async {
  final db = database ?? createTestDatabase();

  // Register cleanup to close the database after the test
  addTearDown(() async {
    await tester.runAsync(() async {
      await db.close();
    });
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: createTestProviderOverridesWithDb(db),
      child: MaterialApp(home: child),
    ),
  );

  // Allow streams to initialize
  await tester.pump();
  await tester.pump(settleDuration);
}

/// Pumps frames and then disposes resources properly.
///
/// Call this at the end of tests that use StreamProvider to allow
/// pending microtasks to complete before teardown.
Future<void> cleanupAfterStreamTest(WidgetTester tester) async {
  // Pump frames to allow streams to settle
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  // Process any remaining async work
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
}

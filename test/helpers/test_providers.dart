import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

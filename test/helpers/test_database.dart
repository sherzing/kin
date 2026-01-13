import 'package:drift/native.dart';
import 'package:kin/data/database/database.dart';

/// Creates an in-memory database for testing.
///
/// The database is created fresh for each test and automatically
/// disposed when the test completes.
///
/// Usage:
/// ```dart
/// late AppDatabase db;
///
/// setUp(() {
///   db = createTestDatabase();
/// });
///
/// tearDown(() async {
///   await db.close();
/// });
/// ```
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(
    NativeDatabase.memory(),
  );
}

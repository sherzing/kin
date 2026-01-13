import 'package:drift/drift.dart';

/// Circles table - tags/groups for organizing contacts.
///
/// Examples: #family, #college, #motorcycles
class Circles extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Circle display name.
  TextColumn get name => text()();

  /// Optional hex color code (e.g., "#FF5733").
  TextColumn get colorHex => text().nullable()();

  /// Row creation timestamp (Unix).
  IntColumn get createdAt => integer()();

  /// Row last update timestamp (Unix).
  IntColumn get updatedAt => integer()();

  /// Soft delete timestamp (Unix). NULL means not deleted.
  IntColumn get deletedAt => integer().nullable()();

  /// Dirty flag for sync - true if changed locally since last sync.
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

/// Contacts table - stores people the user wants to stay in touch with.
///
/// Uses UUID primary keys and soft deletes for sync-ready architecture.
class Contacts extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Contact's display name.
  TextColumn get name => text()();

  /// Local file path to avatar image.
  TextColumn get avatarLocalPath => text().nullable()();

  /// Phone number.
  TextColumn get phone => text().nullable()();

  /// Email address.
  TextColumn get email => text().nullable()();

  /// Birthday as Unix timestamp.
  IntColumn get birthday => integer().nullable()();

  /// Job title.
  TextColumn get jobTitle => text().nullable()();

  /// Desired contact frequency in days.
  IntColumn get cadenceDays => integer().withDefault(const Constant(30))();

  /// Last time user interacted with this contact (Unix timestamp).
  IntColumn get lastContactedAt => integer().nullable()();

  /// Hides contact from Daily Deck until this date (Unix timestamp).
  IntColumn get snoozedUntil => integer().nullable()();

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

import 'package:drift/drift.dart';

import 'circles.dart';
import 'contacts.dart';

/// Junction table linking contacts to circles (many-to-many).
class ContactCircles extends Table {
  /// Reference to contact ID.
  TextColumn get contactId => text().references(Contacts, #id)();

  /// Reference to circle ID.
  TextColumn get circleId => text().references(Circles, #id)();

  /// Row creation timestamp (Unix).
  IntColumn get createdAt => integer()();

  /// Row last update timestamp (Unix).
  IntColumn get updatedAt => integer()();

  /// Soft delete timestamp (Unix). NULL means not deleted.
  IntColumn get deletedAt => integer().nullable()();

  /// Dirty flag for sync - true if changed locally since last sync.
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {contactId, circleId};
}

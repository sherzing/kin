import 'package:drift/drift.dart';

import 'contacts.dart';

/// Interaction types as defined in the spec.
enum InteractionType {
  call,
  meetup,
  message,
  email,
  gift,
}

/// Interactions table - logged conversations/meetings with contacts.
class Interactions extends Table {
  /// UUID v4 primary key.
  TextColumn get id => text()();

  /// Reference to the contact this interaction is with.
  TextColumn get contactId => text().references(Contacts, #id)();

  /// Type of interaction: call, meetup, message, email, gift.
  TextColumn get type => text()();

  /// Markdown content/notes for this interaction.
  TextColumn get content => text().nullable()();

  /// True = preparation note (before interaction), False = reflection (after).
  BoolColumn get isPreparation =>
      boolean().withDefault(const Constant(false))();

  /// When the interaction occurred (Unix timestamp).
  IntColumn get happenedAt => integer()();

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

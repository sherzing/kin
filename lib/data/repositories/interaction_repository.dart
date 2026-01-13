import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../database/tables/interactions.dart';

/// Repository for managing interactions in the database.
class InteractionRepository {
  InteractionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Get all non-deleted interactions.
  Future<List<Interaction>> getAll() {
    return (_db.select(_db.interactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .get();
  }

  /// Get a single interaction by ID.
  Future<Interaction?> getById(String id) {
    return (_db.select(_db.interactions)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get interactions for a specific contact.
  Future<List<Interaction>> getForContact(String contactId) {
    return (_db.select(_db.interactions)
          ..where(
              (t) => t.contactId.equals(contactId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .get();
  }

  /// Get preparation notes for a contact (notes before interaction).
  Future<List<Interaction>> getPreparationNotes(String contactId) {
    return (_db.select(_db.interactions)
          ..where((t) =>
              t.contactId.equals(contactId) &
              t.isPreparation.equals(true) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .get();
  }

  /// Get reflections for a contact (notes after interaction).
  Future<List<Interaction>> getReflections(String contactId) {
    return (_db.select(_db.interactions)
          ..where((t) =>
              t.contactId.equals(contactId) &
              t.isPreparation.equals(false) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .get();
  }

  /// Create a new interaction.
  Future<Interaction> create({
    required String contactId,
    required InteractionType type,
    String? content,
    bool isPreparation = false,
    DateTime? happenedAt,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final id = _uuid.v4();
    final timestamp = happenedAt?.millisecondsSinceEpoch ?? (now * 1000);

    final companion = InteractionsCompanion.insert(
      id: id,
      contactId: contactId,
      type: type.name,
      content: Value(content),
      isPreparation: Value(isPreparation),
      happenedAt: timestamp ~/ 1000,
      createdAt: now,
      updatedAt: now,
      isDirty: const Value(true),
    );

    await _db.into(_db.interactions).insert(companion);
    return (await getById(id))!;
  }

  /// Update an existing interaction.
  Future<Interaction> update(
    String id, {
    InteractionType? type,
    String? content,
    bool? isPreparation,
    DateTime? happenedAt,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final companion = InteractionsCompanion(
      type: type != null ? Value(type.name) : const Value.absent(),
      content: content != null ? Value(content) : const Value.absent(),
      isPreparation:
          isPreparation != null ? Value(isPreparation) : const Value.absent(),
      happenedAt: happenedAt != null
          ? Value(happenedAt.millisecondsSinceEpoch ~/ 1000)
          : const Value.absent(),
      updatedAt: Value(now),
      isDirty: const Value(true),
    );

    await (_db.update(_db.interactions)..where((t) => t.id.equals(id)))
        .write(companion);
    return (await getById(id))!;
  }

  /// Soft delete an interaction.
  Future<void> delete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.interactions)..where((t) => t.id.equals(id))).write(
      InteractionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Search interactions by content.
  Future<List<Interaction>> search(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.interactions)
          ..where((t) => t.deletedAt.isNull() & t.content.like(pattern))
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .get();
  }

  /// Get interactions by type.
  Future<List<Interaction>> getByType(InteractionType type) {
    return (_db.select(_db.interactions)
          ..where((t) => t.type.equals(type.name) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .get();
  }

  /// Get the most recent interaction for a contact.
  Future<Interaction?> getMostRecent(String contactId) {
    return (_db.select(_db.interactions)
          ..where(
              (t) => t.contactId.equals(contactId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch all non-deleted interactions as a stream.
  Stream<List<Interaction>> watchAll() {
    return (_db.select(_db.interactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .watch();
  }

  /// Watch interactions for a specific contact.
  Stream<List<Interaction>> watchForContact(String contactId) {
    return (_db.select(_db.interactions)
          ..where(
              (t) => t.contactId.equals(contactId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .watch();
  }

  /// Watch preparation notes for a contact.
  Stream<List<Interaction>> watchPreparationNotes(String contactId) {
    return (_db.select(_db.interactions)
          ..where((t) =>
              t.contactId.equals(contactId) &
              t.isPreparation.equals(true) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.happenedAt)]))
        .watch();
  }
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

/// Repository for managing circles (tags/groups) in the database.
class CircleRepository {
  CircleRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Get all non-deleted circles.
  Future<List<Circle>> getAll() {
    return (_db.select(_db.circles)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Get a single circle by ID.
  Future<Circle?> getById(String id) {
    return (_db.select(_db.circles)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get circles for a specific contact.
  Future<List<Circle>> getForContact(String contactId) async {
    final query = _db.select(_db.circles).join([
      innerJoin(
        _db.contactCircles,
        _db.contactCircles.circleId.equalsExp(_db.circles.id),
      ),
    ])
      ..where(_db.contactCircles.contactId.equals(contactId) &
          _db.contactCircles.deletedAt.isNull() &
          _db.circles.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.circles.name)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.circles)).toList();
  }

  /// Create a new circle.
  Future<Circle> create({
    required String name,
    String? colorHex,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final id = _uuid.v4();

    final companion = CirclesCompanion.insert(
      id: id,
      name: name,
      colorHex: Value(colorHex),
      createdAt: now,
      updatedAt: now,
      isDirty: const Value(true),
    );

    await _db.into(_db.circles).insert(companion);
    return (await getById(id))!;
  }

  /// Update an existing circle.
  Future<Circle> update(
    String id, {
    String? name,
    String? colorHex,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final companion = CirclesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      colorHex: colorHex != null ? Value(colorHex) : const Value.absent(),
      updatedAt: Value(now),
      isDirty: const Value(true),
    );

    await (_db.update(_db.circles)..where((t) => t.id.equals(id)))
        .write(companion);
    return (await getById(id))!;
  }

  /// Soft delete a circle.
  Future<void> delete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.circles)..where((t) => t.id.equals(id))).write(
      CirclesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Add a contact to a circle.
  Future<void> addContactToCircle(String contactId, String circleId) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final existing = await (_db.select(_db.contactCircles)
          ..where((t) =>
              t.contactId.equals(contactId) & t.circleId.equals(circleId)))
        .getSingleOrNull();

    if (existing != null) {
      // Restore if soft deleted
      if (existing.deletedAt != null) {
        await (_db.update(_db.contactCircles)
              ..where((t) =>
                  t.contactId.equals(contactId) & t.circleId.equals(circleId)))
            .write(
          ContactCirclesCompanion(
            deletedAt: const Value(null),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      }
      return;
    }

    final companion = ContactCirclesCompanion.insert(
      contactId: contactId,
      circleId: circleId,
      createdAt: now,
      updatedAt: now,
      isDirty: const Value(true),
    );

    await _db.into(_db.contactCircles).insert(companion);
  }

  /// Remove a contact from a circle (soft delete).
  Future<void> removeContactFromCircle(
      String contactId, String circleId) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.contactCircles)
          ..where((t) =>
              t.contactId.equals(contactId) & t.circleId.equals(circleId)))
        .write(
      ContactCirclesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Get contacts in a specific circle.
  Future<List<Contact>> getContactsInCircle(String circleId) async {
    final query = _db.select(_db.contacts).join([
      innerJoin(
        _db.contactCircles,
        _db.contactCircles.contactId.equalsExp(_db.contacts.id),
      ),
    ])
      ..where(_db.contactCircles.circleId.equals(circleId) &
          _db.contactCircles.deletedAt.isNull() &
          _db.contacts.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.contacts.name)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.contacts)).toList();
  }

  /// Watch all non-deleted circles as a stream.
  Stream<List<Circle>> watchAll() {
    return (_db.select(_db.circles)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Search circles by name.
  Future<List<Circle>> search(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.circles)
          ..where((t) => t.deletedAt.isNull() & t.name.like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch circles for a specific contact.
  Stream<List<Circle>> watchForContact(String contactId) {
    final query = _db.select(_db.circles).join([
      innerJoin(
        _db.contactCircles,
        _db.contactCircles.circleId.equalsExp(_db.circles.id),
      ),
    ])
      ..where(_db.contactCircles.contactId.equals(contactId) &
          _db.contactCircles.deletedAt.isNull() &
          _db.circles.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.circles.name)]);

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(_db.circles)).toList();
    });
  }
}

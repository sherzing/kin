import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

/// Repository for managing contacts in the database.
class ContactRepository {
  ContactRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// Get all non-deleted contacts.
  Future<List<Contact>> getAll() {
    return (_db.select(_db.contacts)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Get a single contact by ID.
  Future<Contact?> getById(String id) {
    return (_db.select(_db.contacts)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get contacts due for contact today (for Daily Deck).
  ///
  /// Returns contacts where:
  /// - (lastContactedAt + cadenceDays) <= today
  /// - snoozedUntil is null or <= today
  Future<List<Contact>> getDueContacts() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final todayStart =
        DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final todayTimestamp = todayStart.millisecondsSinceEpoch ~/ 1000;

    return (_db.select(_db.contacts)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.snoozedUntil.isNull() | t.snoozedUntil.isSmallerOrEqualValue(now))))
        .get()
        .then((contacts) {
      return contacts.where((contact) {
        if (contact.lastContactedAt == null) return true;
        final lastContact = contact.lastContactedAt!;
        final cadenceSeconds = contact.cadenceDays * 86400;
        final dueDate = lastContact + cadenceSeconds;
        return dueDate <= todayTimestamp;
      }).toList();
    });
  }

  /// Create a new contact.
  Future<Contact> create({
    required String name,
    String? avatarLocalPath,
    String? phone,
    String? email,
    DateTime? birthday,
    String? jobTitle,
    int cadenceDays = 30,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final id = _uuid.v4();

    final companion = ContactsCompanion.insert(
      id: id,
      name: name,
      avatarLocalPath: Value(avatarLocalPath),
      phone: Value(phone),
      email: Value(email),
      birthday: Value(birthday?.millisecondsSinceEpoch),
      jobTitle: Value(jobTitle),
      cadenceDays: Value(cadenceDays),
      createdAt: now,
      updatedAt: now,
      isDirty: const Value(true),
    );

    await _db.into(_db.contacts).insert(companion);
    return (await getById(id))!;
  }

  /// Update an existing contact.
  Future<Contact> update(
    String id, {
    String? name,
    String? avatarLocalPath,
    String? phone,
    String? email,
    DateTime? birthday,
    String? jobTitle,
    int? cadenceDays,
    DateTime? lastContactedAt,
    DateTime? snoozedUntil,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final companion = ContactsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      avatarLocalPath: avatarLocalPath != null
          ? Value(avatarLocalPath)
          : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      birthday:
          birthday != null ? Value(birthday.millisecondsSinceEpoch) : const Value.absent(),
      jobTitle: jobTitle != null ? Value(jobTitle) : const Value.absent(),
      cadenceDays:
          cadenceDays != null ? Value(cadenceDays) : const Value.absent(),
      lastContactedAt: lastContactedAt != null
          ? Value(lastContactedAt.millisecondsSinceEpoch ~/ 1000)
          : const Value.absent(),
      snoozedUntil: snoozedUntil != null
          ? Value(snoozedUntil.millisecondsSinceEpoch ~/ 1000)
          : const Value.absent(),
      updatedAt: Value(now),
      isDirty: const Value(true),
    );

    await (_db.update(_db.contacts)..where((t) => t.id.equals(id)))
        .write(companion);
    return (await getById(id))!;
  }

  /// Mark a contact's last contacted date as now.
  Future<Contact> markContacted(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(
        lastContactedAt: Value(now),
        snoozedUntil: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
    return (await getById(id))!;
  }

  /// Snooze a contact until a specific date.
  Future<Contact> snooze(String id, DateTime until) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final untilTimestamp = until.millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(
        snoozedUntil: Value(untilTimestamp),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
    return (await getById(id))!;
  }

  /// Clear snooze for a contact.
  Future<Contact> clearSnooze(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(
        snoozedUntil: const Value(null),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
    return (await getById(id))!;
  }

  /// Soft delete a contact.
  Future<void> delete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await (_db.update(_db.contacts)..where((t) => t.id.equals(id))).write(
      ContactsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isDirty: const Value(true),
      ),
    );
  }

  /// Search contacts by name.
  Future<List<Contact>> search(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.contacts)
          ..where((t) => t.deletedAt.isNull() & t.name.like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch all non-deleted contacts as a stream.
  Stream<List<Contact>> watchAll() {
    return (_db.select(_db.contacts)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Watch contacts due for Daily Deck.
  ///
  /// Returns contacts where:
  /// - (last_contacted_at + cadence_days) <= today, OR last_contacted_at is null
  /// - snoozed_until is null OR snoozed_until <= now
  /// - deleted_at is null
  ///
  /// Sorted by most overdue first (contacts with null last_contacted_at
  /// are considered infinitely overdue and appear first).
  Stream<List<Contact>> watchDueContacts() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return (_db.select(_db.contacts)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.snoozedUntil.isNull() | t.snoozedUntil.isSmallerOrEqualValue(now))))
        .watch()
        .map((contacts) {
      final todayStart =
          DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      final todayTimestamp = todayStart.millisecondsSinceEpoch ~/ 1000;

      // Filter to due contacts
      final dueContacts = contacts.where((contact) {
        if (contact.lastContactedAt == null) return true;
        final lastContact = contact.lastContactedAt!;
        final cadenceSeconds = contact.cadenceDays * 86400;
        final dueDate = lastContact + cadenceSeconds;
        return dueDate <= todayTimestamp;
      }).toList();

      // Sort by most overdue first
      // Overdue amount = today - (last_contacted_at + cadence_days)
      // Contacts with null last_contacted_at are treated as infinitely overdue
      dueContacts.sort((a, b) {
        final aOverdue = _calculateOverdueDays(a, todayTimestamp);
        final bOverdue = _calculateOverdueDays(b, todayTimestamp);
        return bOverdue.compareTo(aOverdue); // Descending (most overdue first)
      });

      return dueContacts;
    });
  }

  /// Calculate how many days overdue a contact is.
  ///
  /// Returns a large value for contacts with null last_contacted_at
  /// (considered infinitely overdue - they should appear first).
  int _calculateOverdueDays(Contact contact, int todayTimestamp) {
    if (contact.lastContactedAt == null) {
      return 999999; // Infinitely overdue
    }
    final lastContact = contact.lastContactedAt!;
    final cadenceSeconds = contact.cadenceDays * 86400;
    final dueDate = lastContact + cadenceSeconds;
    final overdueSeconds = todayTimestamp - dueDate;
    return overdueSeconds ~/ 86400;
  }
}

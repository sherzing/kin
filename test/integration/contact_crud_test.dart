import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/providers.dart';
import 'package:kin/data/database/database.dart';

/// Integration tests for the full contact CRUD lifecycle.
///
/// These tests verify the complete flow from creating a contact through
/// updating, listing, searching, and deleting - simulating real user workflows.
void main() {
  late ProviderContainer container;
  late AppDatabase testDb;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(testDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  group('Contact CRUD Integration', () {
    test('full lifecycle: create, read, update, delete', () async {
      final notifier = container.read(contactNotifierProvider.notifier);

      // 1. CREATE - Add a new contact
      final contact = await notifier.create(
        name: 'John Doe',
        phone: '555-1234',
        email: 'john@example.com',
        cadenceDays: 14,
      );

      expect(contact.name, equals('John Doe'));
      expect(contact.phone, equals('555-1234'));
      expect(contact.cadenceDays, equals(14));

      // 2. READ - Verify contact appears in list
      await Future.delayed(const Duration(milliseconds: 50));
      var contacts = await container.read(contactsProvider.future);
      expect(contacts.length, equals(1));
      expect(contacts.first.id, equals(contact.id));

      // 3. READ - Fetch single contact by ID
      final fetched = await container.read(contactProvider(contact.id).future);
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('John Doe'));

      // 4. UPDATE - Modify contact fields
      final updated = await notifier.update(
        contact.id,
        name: 'John Smith',
        phone: '555-9999',
        cadenceDays: 30,
      );

      expect(updated.name, equals('John Smith'));
      expect(updated.phone, equals('555-9999'));
      expect(updated.cadenceDays, equals(30));

      // 5. DELETE - Soft delete the contact
      await notifier.delete(contact.id);

      // Verify contact no longer appears in list
      await Future.delayed(const Duration(milliseconds: 50));
      contacts = await container.read(contactsProvider.future);
      expect(contacts, isEmpty);

      // Verify direct fetch returns null (soft deleted)
      final deleted = await container.read(contactProvider(contact.id).future);
      expect(deleted, isNull);
    });

    test('multiple contacts workflow', () async {
      final notifier = container.read(contactNotifierProvider.notifier);

      // Create multiple contacts
      await notifier.create(name: 'Alice Anderson');
      await notifier.create(name: 'Bob Builder');
      await notifier.create(name: 'Charlie Chaplin');

      await Future.delayed(const Duration(milliseconds: 50));
      var contacts = await container.read(contactsProvider.future);
      expect(contacts.length, equals(3));

      // Contacts should be sorted by name
      expect(contacts[0].name, equals('Alice Anderson'));
      expect(contacts[1].name, equals('Bob Builder'));
      expect(contacts[2].name, equals('Charlie Chaplin'));

      // Search for contacts
      var results = await container.read(contactSearchProvider('Bob').future);
      expect(results.length, equals(1));
      expect(results.first.name, equals('Bob Builder'));

      // Search for partial match
      results = await container.read(contactSearchProvider('Cha').future);
      expect(results.length, equals(1));
      expect(results.first.name, equals('Charlie Chaplin'));

      // Delete one contact
      await notifier.delete(contacts[1].id); // Delete Bob

      await Future.delayed(const Duration(milliseconds: 50));
      contacts = await container.read(contactsProvider.future);
      expect(contacts.length, equals(2));
      expect(contacts.map((c) => c.name), isNot(contains('Bob Builder')));
    });

    test('mark contacted workflow', () async {
      final notifier = container.read(contactNotifierProvider.notifier);

      // Create contact with no last contacted date
      final contact = await notifier.create(name: 'New Contact');
      expect(contact.lastContactedAt, isNull);

      // Should appear in due contacts (never contacted)
      await Future.delayed(const Duration(milliseconds: 50));
      var dueContacts = await container.read(dueContactsProvider.future);
      expect(dueContacts.length, equals(1));

      // Mark as contacted
      final marked = await notifier.markContacted(contact.id);
      expect(marked.lastContactedAt, isNotNull);

      // Should no longer be due (just contacted)
      await Future.delayed(const Duration(milliseconds: 50));
      dueContacts = await container.read(dueContactsProvider.future);
      expect(dueContacts, isEmpty);
    });

    test('snooze workflow', () async {
      final notifier = container.read(contactNotifierProvider.notifier);

      // Create contact that would be due
      final contact = await notifier.create(name: 'Snooze Test');

      // Initially should be due (never contacted)
      await Future.delayed(const Duration(milliseconds: 50));
      var dueContacts = await container.read(dueContactsProvider.future);
      expect(dueContacts.length, equals(1));

      // Snooze for 7 days
      final snoozeDate = DateTime.now().add(const Duration(days: 7));
      final snoozed = await notifier.snooze(contact.id, snoozeDate);
      expect(snoozed.snoozedUntil, isNotNull);

      // Should no longer be due
      await Future.delayed(const Duration(milliseconds: 50));
      dueContacts = await container.read(dueContactsProvider.future);
      expect(dueContacts, isEmpty);

      // Mark as contacted should clear snooze
      final marked = await notifier.markContacted(contact.id);
      expect(marked.snoozedUntil, isNull);
    });

    test('provider invalidation on mutations', () async {
      final notifier = container.read(contactNotifierProvider.notifier);

      // Create initial contact
      await notifier.create(name: 'Test Contact');

      // Read initial state
      var contacts = await container.read(contactsProvider.future);
      expect(contacts.length, equals(1));

      // Create another contact - providers should be invalidated
      await notifier.create(name: 'Another Contact');

      // Force re-read after invalidation
      await Future.delayed(const Duration(milliseconds: 50));
      contacts = await container.read(contactsProvider.future);
      expect(contacts.length, equals(2));
    });
  });
}

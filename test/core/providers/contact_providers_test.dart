import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/providers.dart';
import 'package:kin/data/database/database.dart';

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

  group('contactsProvider', () {
    test('emits empty list initially', () async {
      final stream = container.read(contactsProvider.stream);
      final contacts = await stream.first;
      expect(contacts, isEmpty);
    });

    test('emits contacts after creation', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      await notifier.create(name: 'Test Contact');

      // Re-read to get updated stream
      await Future.delayed(const Duration(milliseconds: 50));
      final contacts = await container.read(contactsProvider.future);
      expect(contacts.length, equals(1));
      expect(contacts.first.name, equals('Test Contact'));
    });
  });

  group('contactProvider', () {
    test('returns null for non-existent id', () async {
      final contact = await container.read(contactProvider('non-existent').future);
      expect(contact, isNull);
    });

    test('returns contact for valid id', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final created = await notifier.create(name: 'Test Contact');

      final contact = await container.read(contactProvider(created.id).future);
      expect(contact, isNotNull);
      expect(contact!.name, equals('Test Contact'));
    });
  });

  group('contactSearchProvider', () {
    test('returns empty list for empty query', () async {
      final results = await container.read(contactSearchProvider('').future);
      expect(results, isEmpty);
    });

    test('finds contacts matching query', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      await notifier.create(name: 'John Doe');
      await notifier.create(name: 'Jane Smith');
      await notifier.create(name: 'Bob Johnson');

      final results = await container.read(contactSearchProvider('John').future);
      expect(results.length, equals(2)); // John Doe and Bob Johnson
    });
  });

  group('ContactNotifier', () {
    test('create creates contact with required fields', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final contact = await notifier.create(name: 'Test Contact');

      expect(contact.name, equals('Test Contact'));
      expect(contact.id, isNotEmpty);
      expect(contact.cadenceDays, equals(30)); // default value
    });

    test('create creates contact with all optional fields', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final birthday = DateTime(1990, 5, 15);

      final contact = await notifier.create(
        name: 'Test Contact',
        phone: '555-1234',
        email: 'test@example.com',
        birthday: birthday,
        jobTitle: 'Developer',
        avatarLocalPath: '/path/to/avatar.jpg',
        cadenceDays: 14,
      );

      expect(contact.name, equals('Test Contact'));
      expect(contact.phone, equals('555-1234'));
      expect(contact.email, equals('test@example.com'));
      expect(contact.birthday, equals(birthday.millisecondsSinceEpoch));
      expect(contact.jobTitle, equals('Developer'));
      expect(contact.avatarLocalPath, equals('/path/to/avatar.jpg'));
      expect(contact.cadenceDays, equals(14));
    });

    test('update modifies contact fields', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final contact = await notifier.create(name: 'Original Name');

      final updated = await notifier.update(
        contact.id,
        name: 'Updated Name',
        phone: '555-9999',
      );

      expect(updated.name, equals('Updated Name'));
      expect(updated.phone, equals('555-9999'));
    });

    test('delete soft deletes contact', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final contact = await notifier.create(name: 'To Delete');

      await notifier.delete(contact.id);

      final result = await container.read(contactProvider(contact.id).future);
      expect(result, isNull); // Soft deleted contacts return null
    });

    test('markContacted updates lastContactedAt', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final contact = await notifier.create(name: 'Test Contact');
      expect(contact.lastContactedAt, isNull);

      final updated = await notifier.markContacted(contact.id);
      expect(updated.lastContactedAt, isNotNull);
    });

    test('snooze sets snoozedUntil date', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final contact = await notifier.create(name: 'Test Contact');
      expect(contact.snoozedUntil, isNull);

      final snoozeDate = DateTime.now().add(const Duration(days: 7));
      final updated = await notifier.snooze(contact.id, snoozeDate);

      expect(updated.snoozedUntil, isNotNull);
    });
  });

  group('dueContactsProvider', () {
    test('emits empty list when no contacts exist', () async {
      final stream = container.read(dueContactsProvider.stream);
      final contacts = await stream.first;
      expect(contacts, isEmpty);
    });

    test('includes contacts that have never been contacted', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      await notifier.create(name: 'Never Contacted');

      await Future.delayed(const Duration(milliseconds: 50));
      final dueContacts = await container.read(dueContactsProvider.future);

      expect(dueContacts.length, equals(1));
      expect(dueContacts.first.name, equals('Never Contacted'));
    });

    test('excludes snoozed contacts', () async {
      final notifier = container.read(contactNotifierProvider.notifier);
      final contact = await notifier.create(name: 'Snoozed Contact');
      await notifier.snooze(contact.id, DateTime.now().add(const Duration(days: 7)));

      await Future.delayed(const Duration(milliseconds: 50));
      final dueContacts = await container.read(dueContactsProvider.future);

      expect(dueContacts, isEmpty);
    });
  });
}

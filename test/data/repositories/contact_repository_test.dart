import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/database/database.dart';
import 'package:kin/data/repositories/contact_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ContactRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = ContactRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ContactRepository', () {
    group('create', () {
      test('creates a contact with required fields', () async {
        final contact = await repository.create(name: 'John Doe');

        expect(contact.name, equals('John Doe'));
        expect(contact.id, isNotEmpty);
        expect(contact.cadenceDays, equals(30));
        expect(contact.createdAt, isNotNull);
        expect(contact.updatedAt, isNotNull);
        expect(contact.isDirty, isTrue);
      });

      test('creates a contact with all optional fields', () async {
        final birthday = DateTime(1990, 5, 15);
        final contact = await repository.create(
          name: 'Jane Smith',
          phone: '+1234567890',
          email: 'jane@example.com',
          birthday: birthday,
          jobTitle: 'Engineer',
          cadenceDays: 14,
        );

        expect(contact.name, equals('Jane Smith'));
        expect(contact.phone, equals('+1234567890'));
        expect(contact.email, equals('jane@example.com'));
        expect(contact.birthday, isNotNull);
        expect(contact.jobTitle, equals('Engineer'));
        expect(contact.cadenceDays, equals(14));
      });
    });

    group('getById', () {
      test('returns contact when exists', () async {
        final created = await repository.create(name: 'Test User');
        final found = await repository.getById(created.id);

        expect(found, isNotNull);
        expect(found!.id, equals(created.id));
        expect(found.name, equals('Test User'));
      });

      test('returns null when not exists', () async {
        final found = await repository.getById('non-existent-id');
        expect(found, isNull);
      });

      test('returns null for soft-deleted contact', () async {
        final created = await repository.create(name: 'To Delete');
        await repository.delete(created.id);
        final found = await repository.getById(created.id);

        expect(found, isNull);
      });
    });

    group('getAll', () {
      test('returns empty list when no contacts', () async {
        final contacts = await repository.getAll();
        expect(contacts, isEmpty);
      });

      test('returns all non-deleted contacts', () async {
        await repository.create(name: 'Alice');
        await repository.create(name: 'Bob');
        final deleted = await repository.create(name: 'Charlie');
        await repository.delete(deleted.id);

        final contacts = await repository.getAll();

        expect(contacts, hasLength(2));
        expect(contacts.map((c) => c.name), containsAll(['Alice', 'Bob']));
      });

      test('returns contacts sorted by name', () async {
        await repository.create(name: 'Zoe');
        await repository.create(name: 'Alice');
        await repository.create(name: 'Mike');

        final contacts = await repository.getAll();

        expect(contacts[0].name, equals('Alice'));
        expect(contacts[1].name, equals('Mike'));
        expect(contacts[2].name, equals('Zoe'));
      });
    });

    group('update', () {
      test('updates contact name', () async {
        final created = await repository.create(name: 'Original');
        final updated = await repository.update(created.id, name: 'Updated');

        expect(updated.name, equals('Updated'));
        expect(updated.id, equals(created.id));
      });

      test('updates multiple fields', () async {
        final created = await repository.create(name: 'Test');
        final updated = await repository.update(
          created.id,
          name: 'New Name',
          phone: '555-1234',
          cadenceDays: 7,
        );

        expect(updated.name, equals('New Name'));
        expect(updated.phone, equals('555-1234'));
        expect(updated.cadenceDays, equals(7));
      });

      test('sets isDirty to true', () async {
        final created = await repository.create(name: 'Test');
        final updated = await repository.update(created.id, name: 'Changed');

        expect(updated.isDirty, isTrue);
      });
    });

    group('delete', () {
      test('soft deletes contact', () async {
        final created = await repository.create(name: 'To Delete');
        await repository.delete(created.id);

        final contacts = await repository.getAll();
        expect(contacts, isEmpty);
      });
    });

    group('markContacted', () {
      test('updates lastContactedAt', () async {
        final created = await repository.create(name: 'Test');
        expect(created.lastContactedAt, isNull);

        final updated = await repository.markContacted(created.id);

        expect(updated.lastContactedAt, isNotNull);
      });

      test('clears snoozedUntil', () async {
        final created = await repository.create(name: 'Test');
        await repository.snooze(created.id, DateTime.now().add(const Duration(days: 7)));

        final updated = await repository.markContacted(created.id);

        expect(updated.snoozedUntil, isNull);
      });
    });

    group('snooze', () {
      test('sets snoozedUntil date', () async {
        final created = await repository.create(name: 'Test');
        final snoozeDate = DateTime.now().add(const Duration(days: 3));

        final updated = await repository.snooze(created.id, snoozeDate);

        expect(updated.snoozedUntil, isNotNull);
      });
    });

    group('search', () {
      test('finds contacts by name', () async {
        await repository.create(name: 'John Smith');
        await repository.create(name: 'Jane Doe');
        await repository.create(name: 'Bob Johnson');

        final results = await repository.search('John');

        expect(results, hasLength(2));
        expect(results.map((c) => c.name), containsAll(['John Smith', 'Bob Johnson']));
      });

      test('returns empty list for no matches', () async {
        await repository.create(name: 'Alice');

        final results = await repository.search('Bob');

        expect(results, isEmpty);
      });
    });

    group('watchAll', () {
      test('emits contacts on changes', () async {
        await repository.create(name: 'First');

        expect(
          repository.watchAll(),
          emitsInOrder([
            predicate<List<Contact>>((list) => list.length == 1),
          ]),
        );
      });
    });
  });
}

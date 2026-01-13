import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/database/database.dart';
import 'package:kin/data/repositories/circle_repository.dart';
import 'package:kin/data/repositories/contact_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late CircleRepository circleRepo;
  late ContactRepository contactRepo;

  setUp(() {
    db = createTestDatabase();
    circleRepo = CircleRepository(db);
    contactRepo = ContactRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CircleRepository', () {
    group('create', () {
      test('creates a circle with name', () async {
        final circle = await circleRepo.create(name: 'Family');

        expect(circle.name, equals('Family'));
        expect(circle.id, isNotEmpty);
        expect(circle.isDirty, isTrue);
      });

      test('creates a circle with color', () async {
        final circle = await circleRepo.create(
          name: 'Friends',
          colorHex: '#FF5733',
        );

        expect(circle.name, equals('Friends'));
        expect(circle.colorHex, equals('#FF5733'));
      });
    });

    group('getById', () {
      test('returns circle when exists', () async {
        final created = await circleRepo.create(name: 'Test');
        final found = await circleRepo.getById(created.id);

        expect(found, isNotNull);
        expect(found!.id, equals(created.id));
      });

      test('returns null when not exists', () async {
        final found = await circleRepo.getById('non-existent');
        expect(found, isNull);
      });
    });

    group('getAll', () {
      test('returns all non-deleted circles', () async {
        await circleRepo.create(name: 'Family');
        await circleRepo.create(name: 'Work');
        final deleted = await circleRepo.create(name: 'Old');
        await circleRepo.delete(deleted.id);

        final circles = await circleRepo.getAll();

        expect(circles, hasLength(2));
      });

      test('returns circles sorted by name', () async {
        await circleRepo.create(name: 'Work');
        await circleRepo.create(name: 'Family');
        await circleRepo.create(name: 'School');

        final circles = await circleRepo.getAll();

        expect(circles[0].name, equals('Family'));
        expect(circles[1].name, equals('School'));
        expect(circles[2].name, equals('Work'));
      });
    });

    group('update', () {
      test('updates circle name', () async {
        final created = await circleRepo.create(name: 'Original');
        final updated = await circleRepo.update(created.id, name: 'Updated');

        expect(updated.name, equals('Updated'));
      });

      test('updates circle color', () async {
        final created = await circleRepo.create(name: 'Test');
        final updated = await circleRepo.update(created.id, colorHex: '#00FF00');

        expect(updated.colorHex, equals('#00FF00'));
      });
    });

    group('delete', () {
      test('soft deletes circle', () async {
        final created = await circleRepo.create(name: 'To Delete');
        await circleRepo.delete(created.id);

        final circles = await circleRepo.getAll();
        expect(circles, isEmpty);
      });
    });

    group('contact-circle relationships', () {
      test('addContactToCircle links contact and circle', () async {
        final contact = await contactRepo.create(name: 'John');
        final circle = await circleRepo.create(name: 'Friends');

        await circleRepo.addContactToCircle(contact.id, circle.id);

        final circles = await circleRepo.getForContact(contact.id);
        expect(circles, hasLength(1));
        expect(circles[0].name, equals('Friends'));
      });

      test('getContactsInCircle returns contacts', () async {
        final contact1 = await contactRepo.create(name: 'Alice');
        final contact2 = await contactRepo.create(name: 'Bob');
        final circle = await circleRepo.create(name: 'Team');

        await circleRepo.addContactToCircle(contact1.id, circle.id);
        await circleRepo.addContactToCircle(contact2.id, circle.id);

        final contacts = await circleRepo.getContactsInCircle(circle.id);
        expect(contacts, hasLength(2));
        expect(contacts.map((c) => c.name), containsAll(['Alice', 'Bob']));
      });

      test('removeContactFromCircle unlinks contact and circle', () async {
        final contact = await contactRepo.create(name: 'John');
        final circle = await circleRepo.create(name: 'Friends');

        await circleRepo.addContactToCircle(contact.id, circle.id);
        await circleRepo.removeContactFromCircle(contact.id, circle.id);

        final circles = await circleRepo.getForContact(contact.id);
        expect(circles, isEmpty);
      });

      test('addContactToCircle restores soft-deleted relationship', () async {
        final contact = await contactRepo.create(name: 'John');
        final circle = await circleRepo.create(name: 'Friends');

        await circleRepo.addContactToCircle(contact.id, circle.id);
        await circleRepo.removeContactFromCircle(contact.id, circle.id);
        await circleRepo.addContactToCircle(contact.id, circle.id);

        final circles = await circleRepo.getForContact(contact.id);
        expect(circles, hasLength(1));
      });
    });

    group('watchAll', () {
      test('emits circles on changes', () async {
        await circleRepo.create(name: 'Test');

        expect(
          circleRepo.watchAll(),
          emitsInOrder([
            predicate<List<Circle>>((list) => list.length == 1),
          ]),
        );
      });
    });

    group('watchForContact', () {
      test('emits circles for contact', () async {
        final contact = await contactRepo.create(name: 'Test');
        final circle = await circleRepo.create(name: 'Group');
        await circleRepo.addContactToCircle(contact.id, circle.id);

        expect(
          circleRepo.watchForContact(contact.id),
          emitsInOrder([
            predicate<List<Circle>>((list) => list.length == 1),
          ]),
        );
      });
    });
  });
}

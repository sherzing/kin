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

  group('circlesProvider', () {
    test('emits empty list initially', () async {
      final stream = container.read(circlesProvider.stream);
      final circles = await stream.first;
      expect(circles, isEmpty);
    });

    test('emits circles after creation', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      await notifier.create(name: 'Family');

      await Future.delayed(const Duration(milliseconds: 50));
      final circles = await container.read(circlesProvider.future);
      expect(circles.length, equals(1));
      expect(circles.first.name, equals('Family'));
    });

    test('emits multiple circles in order', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      await notifier.create(name: 'Family');
      await notifier.create(name: 'Work');
      await notifier.create(name: 'Friends');

      await Future.delayed(const Duration(milliseconds: 50));
      final circles = await container.read(circlesProvider.future);
      expect(circles.length, equals(3));
    });
  });

  group('circleProvider', () {
    test('returns null for non-existent id', () async {
      final circle = await container.read(circleProvider('non-existent').future);
      expect(circle, isNull);
    });

    test('returns circle for valid id', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      final created = await notifier.create(name: 'Test Circle');

      final circle = await container.read(circleProvider(created.id).future);
      expect(circle, isNotNull);
      expect(circle!.name, equals('Test Circle'));
    });
  });

  group('CircleNotifier', () {
    test('create creates circle with required fields', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      final circle = await notifier.create(name: 'Test Circle');

      expect(circle.name, equals('Test Circle'));
      expect(circle.id, isNotEmpty);
    });

    test('create creates circle with color', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      final circle = await notifier.create(
        name: 'Colored Circle',
        colorHex: '#FF5733',
      );

      expect(circle.name, equals('Colored Circle'));
      expect(circle.colorHex, equals('#FF5733'));
    });

    test('update modifies circle name', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      final circle = await notifier.create(name: 'Original Name');

      final updated = await notifier.update(circle.id, name: 'Updated Name');
      expect(updated.name, equals('Updated Name'));
    });

    test('update modifies circle color', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      final circle = await notifier.create(
        name: 'Circle',
        colorHex: '#000000',
      );

      final updated = await notifier.update(circle.id, colorHex: '#FFFFFF');
      expect(updated.colorHex, equals('#FFFFFF'));
    });

    test('delete soft deletes circle', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      final circle = await notifier.create(name: 'To Delete');

      await notifier.delete(circle.id);

      final result = await container.read(circleProvider(circle.id).future);
      expect(result, isNull);
    });

    test('deleted circles not returned by circlesProvider', () async {
      final notifier = container.read(circleNotifierProvider.notifier);
      await notifier.create(name: 'Circle 1');
      final circle2 = await notifier.create(name: 'Circle 2');

      await notifier.delete(circle2.id);

      await Future.delayed(const Duration(milliseconds: 50));
      final circles = await container.read(circlesProvider.future);
      expect(circles.length, equals(1));
      expect(circles.first.name, equals('Circle 1'));
    });
  });

  group('Circle-Contact Associations', () {
    test('addContactToCircle creates association', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final circleNotifier = container.read(circleNotifierProvider.notifier);

      final contact = await contactNotifier.create(name: 'Test Contact');
      final circle = await circleNotifier.create(name: 'Test Circle');

      await circleNotifier.addContactToCircle(contact.id, circle.id);

      final contactsInCircle =
          await container.read(contactsInCircleProvider(circle.id).future);
      expect(contactsInCircle.length, equals(1));
      expect(contactsInCircle.first.id, equals(contact.id));
    });

    test('removeContactFromCircle removes association', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final circleNotifier = container.read(circleNotifierProvider.notifier);

      final contact = await contactNotifier.create(name: 'Test Contact');
      final circle = await circleNotifier.create(name: 'Test Circle');

      await circleNotifier.addContactToCircle(contact.id, circle.id);
      await circleNotifier.removeContactFromCircle(contact.id, circle.id);

      final contactsInCircle =
          await container.read(contactsInCircleProvider(circle.id).future);
      expect(contactsInCircle, isEmpty);
    });

    test('contact can belong to multiple circles', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final circleNotifier = container.read(circleNotifierProvider.notifier);

      final contact = await contactNotifier.create(name: 'Multi-Circle Contact');
      final family = await circleNotifier.create(name: 'Family');
      final friends = await circleNotifier.create(name: 'Friends');
      final work = await circleNotifier.create(name: 'Work');

      await circleNotifier.addContactToCircle(contact.id, family.id);
      await circleNotifier.addContactToCircle(contact.id, friends.id);
      await circleNotifier.addContactToCircle(contact.id, work.id);

      // circlesForContactProvider uses a stream, so we read it with future
      await Future.delayed(const Duration(milliseconds: 50));
      final circlesForContact =
          await container.read(circlesForContactProvider(contact.id).future);
      expect(circlesForContact.length, equals(3));
    });

    test('circle can contain multiple contacts', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final circleNotifier = container.read(circleNotifierProvider.notifier);

      final contact1 = await contactNotifier.create(name: 'Contact 1');
      final contact2 = await contactNotifier.create(name: 'Contact 2');
      final contact3 = await contactNotifier.create(name: 'Contact 3');
      final circle = await circleNotifier.create(name: 'Team Circle');

      await circleNotifier.addContactToCircle(contact1.id, circle.id);
      await circleNotifier.addContactToCircle(contact2.id, circle.id);
      await circleNotifier.addContactToCircle(contact3.id, circle.id);

      final contactsInCircle =
          await container.read(contactsInCircleProvider(circle.id).future);
      expect(contactsInCircle.length, equals(3));
    });

    test('circlesForContactProvider returns empty for contact with no circles',
        () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final contact = await contactNotifier.create(name: 'Lonely Contact');

      await Future.delayed(const Duration(milliseconds: 50));
      final circles =
          await container.read(circlesForContactProvider(contact.id).future);
      expect(circles, isEmpty);
    });

    test('contactsInCircleProvider returns empty for circle with no contacts',
        () async {
      final circleNotifier = container.read(circleNotifierProvider.notifier);
      final circle = await circleNotifier.create(name: 'Empty Circle');

      final contacts =
          await container.read(contactsInCircleProvider(circle.id).future);
      expect(contacts, isEmpty);
    });

    test('deleting contact does not affect circle', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final circleNotifier = container.read(circleNotifierProvider.notifier);

      final contact = await contactNotifier.create(name: 'Test Contact');
      final circle = await circleNotifier.create(name: 'Test Circle');

      await circleNotifier.addContactToCircle(contact.id, circle.id);
      await contactNotifier.delete(contact.id);

      // Circle still exists
      final circleResult = await container.read(circleProvider(circle.id).future);
      expect(circleResult, isNotNull);

      // But contact is no longer in the circle (soft deleted)
      final contactsInCircle =
          await container.read(contactsInCircleProvider(circle.id).future);
      expect(contactsInCircle, isEmpty);
    });

    test('deleting circle does not affect contact', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final circleNotifier = container.read(circleNotifierProvider.notifier);

      final contact = await contactNotifier.create(name: 'Test Contact');
      final circle = await circleNotifier.create(name: 'Test Circle');

      await circleNotifier.addContactToCircle(contact.id, circle.id);
      await circleNotifier.delete(circle.id);

      // Contact still exists
      final contactResult = await container.read(contactProvider(contact.id).future);
      expect(contactResult, isNotNull);

      // Circle is deleted
      final circleResult = await container.read(circleProvider(circle.id).future);
      expect(circleResult, isNull);
    });
  });
}

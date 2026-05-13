import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/services/contact_import_service.dart';
import 'package:kin/core/services/contact_importer.dart';
import 'package:kin/data/database/database.dart';
import 'package:kin/data/repositories/repositories.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ContactRepository contacts;
  late CircleRepository circles;
  late _FakeAvatarStore avatars;
  late ContactImporter importer;

  setUp(() {
    db = createTestDatabase();
    contacts = ContactRepository(db);
    circles = CircleRepository(db);
    avatars = _FakeAvatarStore();
    importer = ContactImporter(
      contacts: contacts,
      circles: circles,
      avatarStore: avatars,
    );
  });

  tearDown(() async {
    await db.close();
  });

  ImportableContact ada({
    String id = 'ada',
    String name = 'Ada Lovelace',
    List<String> phones = const [],
    List<String> emails = const [],
    DateTime? birthday,
    String? jobTitle,
    Uint8List? thumbnail,
  }) =>
      ImportableContact(
        sourceId: id,
        displayName: name,
        phones: phones,
        emails: emails,
        birthday: birthday,
        jobTitle: jobTitle,
        thumbnail: thumbnail,
      );

  const config = ImportConfig(defaultCadenceDays: 30);

  group('field mapping', () {
    test('maps displayName, first phone, first email, birthday, jobTitle', () async {
      final result = await importer.run([
        ada(
          phones: const ['+1 555-0100', '+1 555-0101'],
          emails: const ['ada@example.com', 'lovelace@example.com'],
          birthday: DateTime(1815, 12, 10),
          jobTitle: 'Mathematician',
        ),
      ], config);

      expect(result.added, 1);
      final created = (await contacts.getAll()).single;
      expect(created.name, 'Ada Lovelace');
      expect(created.phone, '+1 555-0100');
      expect(created.email, 'ada@example.com');
      expect(created.birthday, DateTime(1815, 12, 10).millisecondsSinceEpoch);
      expect(created.jobTitle, 'Mathematician');
      expect(created.cadenceDays, 30);
      expect(created.isDirty, isTrue);
    });

    test('uses config.defaultCadenceDays', () async {
      await importer.run(
        [ada()],
        const ImportConfig(defaultCadenceDays: 90),
      );
      expect((await contacts.getAll()).single.cadenceDays, 90);
    });

    test('handles contact with no phones or emails', () async {
      final result = await importer.run([ada()], config);
      expect(result.added, 1);
      final created = (await contacts.getAll()).single;
      expect(created.phone, isNull);
      expect(created.email, isNull);
    });
  });

  group('avatar persistence', () {
    test('persists thumbnail bytes via AvatarStore and stores returned path', () async {
      final bytes = Uint8List.fromList([0xff, 0xd8, 0xff]);
      await importer.run([ada(thumbnail: bytes)], config);

      expect(avatars.saves, hasLength(1));
      expect(avatars.saves.single.bytes, bytes);
      final created = (await contacts.getAll()).single;
      expect(created.avatarLocalPath, avatars.saves.single.returnedPath);
    });

    test('leaves avatarLocalPath null when no thumbnail', () async {
      await importer.run([ada()], config);
      expect(avatars.saves, isEmpty);
      expect((await contacts.getAll()).single.avatarLocalPath, isNull);
    });
  });

  group('duplicate detection', () {
    test('skip strategy: phone match → not added, counted as skipped', () async {
      await contacts.create(name: 'Existing Ada', phone: '+1 555-0100');

      final result = await importer.run([
        ada(phones: const ['+1 555-0100']),
      ], const ImportConfig(defaultCadenceDays: 30, duplicateStrategy: DuplicateStrategy.skip));

      expect(result.added, 0);
      expect(result.skipped, 1);
      expect((await contacts.getAll()), hasLength(1));
    });

    test('skip strategy: email match → not added', () async {
      await contacts.create(name: 'Existing', email: 'ada@example.com');

      final result = await importer.run([
        ada(emails: const ['ada@example.com']),
      ], const ImportConfig(defaultCadenceDays: 30, duplicateStrategy: DuplicateStrategy.skip));

      expect(result.skipped, 1);
      expect(result.added, 0);
    });

    test('skip strategy: name match (no phone/email) → not added', () async {
      await contacts.create(name: 'Ada Lovelace');

      final result = await importer.run([ada()], const ImportConfig(
        defaultCadenceDays: 30,
        duplicateStrategy: DuplicateStrategy.skip,
      ));

      expect(result.skipped, 1);
      expect(result.added, 0);
    });

    test('skip strategy: no match → contact is added', () async {
      await contacts.create(name: 'Someone Else', phone: '+1 555-9999');

      final result = await importer.run([
        ada(phones: const ['+1 555-0100']),
      ], const ImportConfig(defaultCadenceDays: 30, duplicateStrategy: DuplicateStrategy.skip));

      expect(result.added, 1);
      expect(result.skipped, 0);
    });

    test('update strategy: phone match → existing contact updated', () async {
      final existing = await contacts.create(
        name: 'Old Name',
        phone: '+1 555-0100',
        cadenceDays: 7,
      );

      final result = await importer.run([
        ada(
          name: 'Ada Lovelace',
          phones: const ['+1 555-0100'],
          emails: const ['ada@example.com'],
          jobTitle: 'Mathematician',
        ),
      ], const ImportConfig(
        defaultCadenceDays: 30,
        duplicateStrategy: DuplicateStrategy.update,
      ));

      expect(result.updated, 1);
      expect(result.added, 0);
      final reloaded = await contacts.getById(existing.id);
      expect(reloaded!.name, 'Ada Lovelace');
      expect(reloaded.email, 'ada@example.com');
      expect(reloaded.jobTitle, 'Mathematician');
      expect(reloaded.cadenceDays, 7, reason: 'preserve existing cadence');
    });
  });

  group('circle assignment', () {
    test('assigns all imported contacts to config.circleId when set', () async {
      final circle = await circles.create(name: 'From iPhone');
      final result = await importer.run([
        ada(),
        ada(id: 'b', name: 'Bob'),
      ], ImportConfig(defaultCadenceDays: 30, circleId: circle.id));

      expect(result.added, 2);
      final inCircle = await circles.getContactsInCircle(circle.id);
      expect(inCircle.map((c) => c.name), containsAll(['Ada Lovelace', 'Bob']));
    });

    test('does not assign any circle when config.circleId is null', () async {
      final circle = await circles.create(name: 'Untouched');
      await importer.run([ada()], config);
      final inCircle = await circles.getContactsInCircle(circle.id);
      expect(inCircle, isEmpty);
    });
  });

  group('result counts', () {
    test('reports added, skipped, and updated separately across mixed batch',
        () async {
      await contacts.create(name: 'Carol', phone: '+1 555-3333');

      final result = await importer.run([
        ada(id: '1', name: 'Ada', phones: const ['+1 555-1111']),
        ada(id: '2', name: 'Carol', phones: const ['+1 555-3333']),
      ], const ImportConfig(
        defaultCadenceDays: 30,
        duplicateStrategy: DuplicateStrategy.update,
      ));

      expect(result.added, 1);
      expect(result.updated, 1);
      expect(result.skipped, 0);
    });
  });
}

class _SavedAvatar {
  _SavedAvatar(this.bytes, this.returnedPath);
  final Uint8List bytes;
  final String returnedPath;
}

class _FakeAvatarStore implements AvatarStore {
  final List<_SavedAvatar> saves = [];
  int _counter = 0;

  @override
  Future<String> save(String contactId, Uint8List bytes) async {
    final path = '/fake/avatars/${contactId}_${_counter++}.jpg';
    saves.add(_SavedAvatar(bytes, path));
    return path;
  }
}

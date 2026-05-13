import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/providers/contact_import_provider.dart';
import 'package:kin/core/services/contact_import_service.dart';

void main() {
  group('ImportableContact', () {
    test('holds name, phones, emails, birthday, jobTitle, thumbnail', () {
      final thumb = Uint8List.fromList([1, 2, 3]);
      final c = ImportableContact(
        sourceId: 'abc-123',
        displayName: 'Ada Lovelace',
        phones: const ['+1 555-0100'],
        emails: const ['ada@example.com'],
        birthday: DateTime(1815, 12, 10),
        jobTitle: 'Mathematician',
        thumbnail: thumb,
      );

      expect(c.sourceId, 'abc-123');
      expect(c.displayName, 'Ada Lovelace');
      expect(c.phones, ['+1 555-0100']);
      expect(c.emails, ['ada@example.com']);
      expect(c.birthday, DateTime(1815, 12, 10));
      expect(c.jobTitle, 'Mathematician');
      expect(c.thumbnail, thumb);
    });

    test('phones and emails default to empty lists; other fields nullable', () {
      const c = ImportableContact(
        sourceId: 'x',
        displayName: 'Anon',
      );
      expect(c.phones, isEmpty);
      expect(c.emails, isEmpty);
      expect(c.birthday, isNull);
      expect(c.jobTitle, isNull);
      expect(c.thumbnail, isNull);
    });

    test('equality is value-based on sourceId, name, phones, emails', () {
      const a = ImportableContact(
        sourceId: 'x',
        displayName: 'A',
        phones: ['1'],
        emails: ['a@a'],
      );
      const b = ImportableContact(
        sourceId: 'x',
        displayName: 'A',
        phones: ['1'],
        emails: ['a@a'],
      );
      const c = ImportableContact(
        sourceId: 'y',
        displayName: 'A',
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ContactPermissionStatus', () {
    test('has granted, denied, permanentlyDenied, restricted', () {
      expect(ContactPermissionStatus.values, [
        ContactPermissionStatus.granted,
        ContactPermissionStatus.denied,
        ContactPermissionStatus.permanentlyDenied,
        ContactPermissionStatus.restricted,
      ]);
    });

    test('isGranted is true only for granted', () {
      expect(ContactPermissionStatus.granted.isGranted, isTrue);
      expect(ContactPermissionStatus.denied.isGranted, isFalse);
      expect(ContactPermissionStatus.permanentlyDenied.isGranted, isFalse);
      expect(ContactPermissionStatus.restricted.isGranted, isFalse);
    });
  });

  group('contactImportServiceProvider', () {
    test('exposes a FlutterContactImportService by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(contactImportServiceProvider);
      expect(service, isA<FlutterContactImportService>());
    });

    test('can be overridden in tests', () {
      final fake = _FakeContactImportService(
        permission: ContactPermissionStatus.denied,
        contacts: const [],
      );
      final container = ProviderContainer(overrides: [
        contactImportServiceProvider.overrideWithValue(fake),
      ]);
      addTearDown(container.dispose);

      expect(container.read(contactImportServiceProvider), same(fake));
    });
  });

  group('ContactImportService contract', () {
    test('can be implemented by a fake (interface compiles)', () async {
      final fake = _FakeContactImportService(
        permission: ContactPermissionStatus.granted,
        contacts: const [
          ImportableContact(sourceId: '1', displayName: 'Bob'),
        ],
      );

      expect(await fake.currentPermissionStatus(),
          ContactPermissionStatus.granted);
      expect(await fake.requestPermission(),
          ContactPermissionStatus.granted);
      expect((await fake.loadContacts()).single.displayName, 'Bob');
    });
  });
}

class _FakeContactImportService implements ContactImportService {
  _FakeContactImportService({required this.permission, required this.contacts});

  final ContactPermissionStatus permission;
  final List<ImportableContact> contacts;

  @override
  Future<ContactPermissionStatus> currentPermissionStatus() async => permission;

  @override
  Future<ContactPermissionStatus> requestPermission() async => permission;

  @override
  Future<List<ImportableContact>> loadContacts() async => contacts;
}

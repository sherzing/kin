import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/providers/contact_import_provider.dart';
import 'package:kin/core/services/contact_import_service.dart';
import 'package:kin/presentation/screens/import_source_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required ContactImportService service,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactImportServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(home: ImportSourceScreen()),
      ),
    );
    await tester.pump();
  }

  group('ImportSourceScreen', () {
    testWidgets('renders all three source options', (tester) async {
      await pumpScreen(tester, service: _FakeService.granted([]));

      expect(find.text('iPhone Contacts'), findsOneWidget);
      expect(find.text('CSV file'), findsOneWidget);
      expect(find.text('vCard file'), findsOneWidget);
    });

    testWidgets('CSV and vCard tiles are disabled (coming soon)', (tester) async {
      await pumpScreen(tester, service: _FakeService.granted([]));

      final csv = tester.widget<ListTile>(
        find.ancestor(of: find.text('CSV file'), matching: find.byType(ListTile)),
      );
      final vcf = tester.widget<ListTile>(
        find.ancestor(of: find.text('vCard file'), matching: find.byType(ListTile)),
      );
      expect(csv.enabled, isFalse);
      expect(vcf.enabled, isFalse);
    });

    testWidgets('tapping iPhone Contacts shows loading then success summary',
        (tester) async {
      final permissionGate = Completer<ContactPermissionStatus>();
      final service = _FakeService(
        permissionFuture: permissionGate.future,
        contacts: const [
          ImportableContact(sourceId: '1', displayName: 'Ada'),
          ImportableContact(sourceId: '2', displayName: 'Bob'),
        ],
      );
      await pumpScreen(tester, service: service);

      await tester.tap(find.text('iPhone Contacts'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      permissionGate.complete(ContactPermissionStatus.granted);
      await tester.pumpAndSettle();
      expect(find.textContaining('2'), findsWidgets);
      expect(service.requestedPermission, isTrue);
      expect(service.loadedContacts, isTrue);
    });

    testWidgets('denied permission shows error UI with Open Settings action',
        (tester) async {
      await pumpScreen(tester, service: _FakeService.denied());

      await tester.tap(find.text('iPhone Contacts'));
      await tester.pumpAndSettle();

      expect(find.textContaining('permission'), findsWidgets);
      expect(find.widgetWithText(TextButton, 'Open Settings'), findsOneWidget);
    });
  });
}

class _FakeService implements ContactImportService {
  _FakeService({
    required Future<ContactPermissionStatus> permissionFuture,
    required this.contacts,
  }) : _permissionFuture = permissionFuture;

  factory _FakeService.granted(List<ImportableContact> contacts) => _FakeService(
        permissionFuture: Future.value(ContactPermissionStatus.granted),
        contacts: contacts,
      );

  factory _FakeService.denied() => _FakeService(
        permissionFuture: Future.value(ContactPermissionStatus.denied),
        contacts: const [],
      );

  final Future<ContactPermissionStatus> _permissionFuture;
  final List<ImportableContact> contacts;
  bool requestedPermission = false;
  bool loadedContacts = false;

  @override
  Future<ContactPermissionStatus> currentPermissionStatus() => _permissionFuture;

  @override
  Future<ContactPermissionStatus> requestPermission() {
    requestedPermission = true;
    return _permissionFuture;
  }

  @override
  Future<List<ImportableContact>> loadContacts() async {
    loadedContacts = true;
    return contacts;
  }
}

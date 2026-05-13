import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart' as fc;

/// Permission state for accessing the device's contacts.
enum ContactPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted;

  bool get isGranted => this == ContactPermissionStatus.granted;
}

/// A contact loaded from an external source (iOS Contacts, CSV, vCard),
/// not yet persisted to Kin. Pure value type — no platform dependencies.
class ImportableContact {
  const ImportableContact({
    required this.sourceId,
    required this.displayName,
    this.phones = const [],
    this.emails = const [],
    this.birthday,
    this.jobTitle,
    this.thumbnail,
  });

  /// Stable identifier from the source (e.g. iOS Contacts identifier).
  /// Used for selection/deselection in the UI.
  final String sourceId;
  final String displayName;
  final List<String> phones;
  final List<String> emails;
  final DateTime? birthday;
  final String? jobTitle;
  final Uint8List? thumbnail;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportableContact &&
        other.sourceId == sourceId &&
        other.displayName == displayName &&
        _listEquals(other.phones, phones) &&
        _listEquals(other.emails, emails);
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, displayName, Object.hashAll(phones), Object.hashAll(emails));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Boundary between Kin and the platform's contact source.
/// Concrete implementations wrap the OS contacts API (iOS) or file parsers
/// (CSV/vCard). Tests inject a fake.
abstract interface class ContactImportService {
  Future<ContactPermissionStatus> currentPermissionStatus();
  Future<ContactPermissionStatus> requestPermission();
  Future<List<ImportableContact>> loadContacts();
}

/// Wraps the `flutter_contacts` package. Thin pass-through — the testable
/// behavior (mapping, dedup) lives in [ImportableContact] and downstream
/// services. flutter_contacts itself is a platform-channel boundary and is
/// exercised by manual / integration testing on device.
class FlutterContactImportService implements ContactImportService {
  const FlutterContactImportService();

  @override
  Future<ContactPermissionStatus> currentPermissionStatus() async {
    return _toStatus(await fc.FlutterContacts.requestPermission(readonly: true));
  }

  @override
  Future<ContactPermissionStatus> requestPermission() async {
    return _toStatus(await fc.FlutterContacts.requestPermission(readonly: true));
  }

  @override
  Future<List<ImportableContact>> loadContacts() async {
    final contacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: true,
    );
    return contacts.map(_fromFlutterContact).toList(growable: false);
  }

  static ContactPermissionStatus _toStatus(bool granted) =>
      granted ? ContactPermissionStatus.granted : ContactPermissionStatus.denied;

  static ImportableContact _fromFlutterContact(fc.Contact c) {
    DateTime? birthday;
    for (final e in c.events) {
      if (e.label == fc.EventLabel.birthday) {
        birthday = DateTime(e.year ?? 1900, e.month, e.day);
        break;
      }
    }
    final orgTitle = c.organizations.isNotEmpty ? c.organizations.first.title : '';
    return ImportableContact(
      sourceId: c.id,
      displayName: c.displayName,
      phones: c.phones.map((p) => p.number).where((s) => s.isNotEmpty).toList(growable: false),
      emails: c.emails.map((e) => e.address).where((s) => s.isNotEmpty).toList(growable: false),
      birthday: birthday,
      jobTitle: orgTitle.isEmpty ? null : orgTitle,
      thumbnail: c.thumbnail,
    );
  }
}

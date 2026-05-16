import 'dart:io';
import 'dart:typed_data';

import 'package:fast_contacts/fast_contacts.dart' as fc;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:url_launcher/url_launcher.dart';

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

/// Wraps `fast_contacts` (for bulk contact retrieval) and `permission_handler`
/// (for permission gating). fast_contacts requires the permission to already
/// be granted before calling [loadContacts]; we use permission_handler so the
/// flow surfaces the iOS system prompt without depending on a contacts
/// package that does its own permission handling. Birthday is intentionally
/// not imported here — fast_contacts doesn't expose contact events.
class FlutterContactImportService implements ContactImportService {
  const FlutterContactImportService();

  @override
  Future<ContactPermissionStatus> currentPermissionStatus() async =>
      _toStatus(await ph.Permission.contacts.status);

  @override
  Future<ContactPermissionStatus> requestPermission() async =>
      _toStatus(await ph.Permission.contacts.request());

  @override
  Future<List<ImportableContact>> loadContacts() async {
    final contacts = await fc.FastContacts.getAllContacts();
    final result = <ImportableContact>[];
    for (final c in contacts) {
      Uint8List? thumb;
      try {
        thumb = await fc.FastContacts.getContactImage(c.id);
      } catch (_) {
        thumb = null;
      }
      result.add(_fromFastContact(c, thumb));
    }
    return result;
  }

  /// Opens the iOS Settings app at the Kin app entry, where the user can
  /// toggle Contacts permission. Uses url_launcher with the `app-settings:`
  /// URL scheme on iOS; falls back to a no-op on other platforms.
  Future<void> openPlatformSettings() async {
    if (!Platform.isIOS) return;
    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static ContactPermissionStatus _toStatus(ph.PermissionStatus s) {
    if (s.isGranted || s.isLimited) return ContactPermissionStatus.granted;
    if (s.isPermanentlyDenied) return ContactPermissionStatus.permanentlyDenied;
    if (s.isRestricted) return ContactPermissionStatus.restricted;
    return ContactPermissionStatus.denied;
  }

  static ImportableContact _fromFastContact(fc.Contact c, Uint8List? thumbnail) {
    return ImportableContact(
      sourceId: c.id,
      displayName: c.displayName,
      phones: c.phones
          .map((p) => p.number)
          .where((s) => s.isNotEmpty)
          .toList(growable: false),
      emails: c.emails
          .map((e) => e.address)
          .where((s) => s.isNotEmpty)
          .toList(growable: false),
      birthday: null,
      jobTitle: c.organization?.jobDescription.isNotEmpty == true
          ? c.organization!.jobDescription
          : null,
      thumbnail: thumbnail,
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database/database.dart';
import '../../data/repositories/repositories.dart';
import 'contact_import_service.dart';

enum DuplicateStrategy { skip, update }

class ImportConfig {
  const ImportConfig({
    required this.defaultCadenceDays,
    this.circleId,
    this.duplicateStrategy = DuplicateStrategy.skip,
  });

  final int defaultCadenceDays;
  final String? circleId;
  final DuplicateStrategy duplicateStrategy;
}

class ImportResult {
  const ImportResult({this.added = 0, this.skipped = 0, this.updated = 0});

  final int added;
  final int skipped;
  final int updated;
}

/// Persists thumbnail bytes to a file path. Injected so tests can capture
/// writes without touching the filesystem.
abstract interface class AvatarStore {
  Future<String> save(String contactId, Uint8List bytes);
}

/// Writes avatars under `<appDocuments>/avatars/`, matching the
/// convention used by [ContactFormScreen]'s image picker.
class FilesAvatarStore implements AvatarStore {
  const FilesAvatarStore();

  @override
  Future<String> save(String contactId, Uint8List bytes) async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(appDir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }
    final path = p.join(avatarsDir.path,
        '${contactId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }
}

/// Writes selected contacts into the Kin database. Handles field mapping,
/// duplicate detection, and circle assignment. Avatar bytes are delegated to
/// an [AvatarStore].
class ContactImporter {
  ContactImporter({
    required this.contacts,
    required this.circles,
    required this.avatarStore,
  });

  final ContactRepository contacts;
  final CircleRepository circles;
  final AvatarStore avatarStore;

  Future<ImportResult> run(
    List<ImportableContact> selected,
    ImportConfig config,
  ) async {
    final existing = await contacts.getAll();
    var added = 0;
    var skipped = 0;
    var updated = 0;

    for (final c in selected) {
      final dup = _findDuplicate(c, existing);
      if (dup != null) {
        if (config.duplicateStrategy == DuplicateStrategy.skip) {
          skipped++;
          continue;
        }
        await contacts.update(
          dup.id,
          name: c.displayName,
          phone: c.phones.isNotEmpty ? c.phones.first : null,
          email: c.emails.isNotEmpty ? c.emails.first : null,
          birthday: c.birthday,
          jobTitle: c.jobTitle,
        );
        if (config.circleId != null) {
          await circles.addContactToCircle(dup.id, config.circleId!);
        }
        updated++;
        continue;
      }

      final created = await contacts.create(
        name: c.displayName,
        phone: c.phones.isNotEmpty ? c.phones.first : null,
        email: c.emails.isNotEmpty ? c.emails.first : null,
        birthday: c.birthday,
        jobTitle: c.jobTitle,
        cadenceDays: config.defaultCadenceDays,
      );

      if (c.thumbnail != null) {
        final path = await avatarStore.save(created.id, c.thumbnail!);
        await contacts.update(created.id, avatarLocalPath: path);
      }
      if (config.circleId != null) {
        await circles.addContactToCircle(created.id, config.circleId!);
      }
      added++;
    }

    return ImportResult(added: added, skipped: skipped, updated: updated);
  }

  Contact? _findDuplicate(ImportableContact c, List<Contact> existing) {
    for (final phone in c.phones) {
      for (final e in existing) {
        if (e.phone != null && e.phone == phone) return e;
      }
    }
    for (final email in c.emails) {
      for (final e in existing) {
        if (e.email != null && e.email == email) return e;
      }
    }
    if (c.phones.isEmpty && c.emails.isEmpty) {
      for (final e in existing) {
        if (e.name == c.displayName) return e;
      }
    }
    return null;
  }
}

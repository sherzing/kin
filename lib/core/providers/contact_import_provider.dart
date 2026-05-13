import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/contact_import_service.dart';
import '../services/contact_importer.dart';
import 'database_providers.dart';

/// Provides the active [ContactImportService]. Defaults to the native iOS
/// implementation; tests and alternative sources (CSV/vCard) can override.
final contactImportServiceProvider = Provider<ContactImportService>((_) {
  return const FlutterContactImportService();
});

/// Provider for the avatar persistence strategy (filesystem by default).
final avatarStoreProvider = Provider<AvatarStore>((_) {
  return const FilesAvatarStore();
});

/// Provides the [ContactImporter] that writes selected contacts to the DB.
final contactImporterProvider = Provider<ContactImporter>((ref) {
  return ContactImporter(
    contacts: ref.watch(contactRepositoryProvider),
    circles: ref.watch(circleRepositoryProvider),
    avatarStore: ref.watch(avatarStoreProvider),
  );
});

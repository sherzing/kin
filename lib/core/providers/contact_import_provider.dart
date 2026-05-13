import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/contact_import_service.dart';

/// Provides the active [ContactImportService]. Defaults to the native iOS
/// implementation; tests and alternative sources (CSV/vCard) can override.
final contactImportServiceProvider = Provider<ContactImportService>((_) {
  return const FlutterContactImportService();
});

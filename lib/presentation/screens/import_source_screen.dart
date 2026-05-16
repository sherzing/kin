import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/contact_import_provider.dart';
import '../../core/services/contact_import_service.dart';

/// Holds contacts most-recently loaded from the source picker, so the
/// downstream selection screen can read them.
final loadedImportContactsProvider =
    StateProvider<List<ImportableContact>>((_) => const []);

class ImportSourceScreen extends ConsumerStatefulWidget {
  const ImportSourceScreen({super.key});

  @override
  ConsumerState<ImportSourceScreen> createState() => _ImportSourceScreenState();
}

class _ImportSourceScreenState extends ConsumerState<ImportSourceScreen> {
  bool _loading = false;
  ContactPermissionStatus? _deniedStatus;

  Future<void> _loadFromIPhoneContacts() async {
    setState(() {
      _loading = true;
      _deniedStatus = null;
    });
    final service = ref.read(contactImportServiceProvider);
    final status = await service.requestPermission();
    if (!status.isGranted) {
      setState(() {
        _loading = false;
        _deniedStatus = status;
      });
      return;
    }

    final contacts = await service.loadContacts();
    if (!mounted) return;
    ref.read(loadedImportContactsProvider.notifier).state = contacts;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loaded = ref.watch(loadedImportContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Contacts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_iphone),
                  title: const Text('iPhone Contacts'),
                  subtitle: const Text('Import from your phone\'s address book'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _loadFromIPhoneContacts,
                ),
                ListTile(
                  enabled: false,
                  leading: const Icon(Icons.description),
                  title: const Text('CSV file'),
                  subtitle: const Text('Coming soon'),
                ),
                ListTile(
                  enabled: false,
                  leading: const Icon(Icons.contact_page),
                  title: const Text('vCard file'),
                  subtitle: const Text('Coming soon'),
                ),
                if (_deniedStatus != null)
                  _DeniedBanner(
                    status: _deniedStatus!,
                    service: ref.read(contactImportServiceProvider),
                  ),
                if (loaded.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Loaded ${loaded.length} contact${loaded.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _DeniedBanner extends StatelessWidget {
  const _DeniedBanner({required this.status, required this.service});
  final ContactPermissionStatus status;
  final ContactImportService service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kin needs contacts permission to import.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              if (service is FlutterContactImportService) {
                (service as FlutterContactImportService).openPlatformSettings();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

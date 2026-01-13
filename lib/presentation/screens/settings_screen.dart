import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen for app settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Organization',
            children: [
              ListTile(
                leading: const Icon(Icons.label),
                title: const Text('Manage Circles'),
                subtitle: const Text('Create and edit contact circles'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/circles'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About Kin'),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Kin',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'A local-first personal relationship manager',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}

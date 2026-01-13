import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/database.dart';

/// Screen displaying detailed information about a contact.
class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({
    super.key,
    required this.contactId,
  });

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactProvider(contactId));

    return contactAsync.when(
      data: (contact) {
        if (contact == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Contact Not Found')),
            body: const Center(child: Text('Contact not found')),
          );
        }
        return _ContactDetailView(contact: contact);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ContactDetailView extends ConsumerWidget {
  const _ContactDetailView({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_contacted',
                child: Text('Mark as Contacted'),
              ),
              const PopupMenuItem(
                value: 'snooze',
                child: Text('Snooze'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ContactHeader(contact: contact),
            const SizedBox(height: 24),
            _ContactInfoSection(contact: contact),
            const SizedBox(height: 24),
            _ContactStatusSection(contact: contact),
            const SizedBox(height: 24),
            _InteractionsSection(contactId: contact.id),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/contacts/${contact.id}/interactions');
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Interaction'),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phone ?? '');
    final emailController = TextEditingController(text: contact.email ?? '');
    final jobTitleController =
        TextEditingController(text: contact.jobTitle ?? '');
    final cadenceController =
        TextEditingController(text: contact.cadenceDays.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: jobTitleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cadenceController,
                decoration:
                    const InputDecoration(labelText: 'Contact Cadence (days)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      await ref.read(contactNotifierProvider.notifier).update(
            contact.id,
            name: nameController.text.trim(),
            phone: phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            email: emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim(),
            jobTitle: jobTitleController.text.trim().isEmpty
                ? null
                : jobTitleController.text.trim(),
            cadenceDays: int.tryParse(cadenceController.text) ?? 30,
          );
    }
  }

  Future<void> _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'mark_contacted':
        await ref.read(contactNotifierProvider.notifier).markContacted(contact.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marked as contacted')),
          );
        }
        break;
      case 'snooze':
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          await ref.read(contactNotifierProvider.notifier).snooze(contact.id, date);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Snoozed until ${date.toLocal()}')),
            );
          }
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Contact?'),
            content: Text('Are you sure you want to delete ${contact.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(contactNotifierProvider.notifier).delete(contact.id);
          if (context.mounted) {
            context.go('/contacts');
          }
        }
        break;
    }
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _LargeContactAvatar(contact: contact),
          const SizedBox(height: 16),
          Text(
            contact.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (contact.jobTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              contact.jobTitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LargeContactAvatar extends StatelessWidget {
  const _LargeContactAvatar({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: healthColor, width: 4),
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          _getInitials(),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }

  String _getInitials() {
    final parts = contact.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }

  Color _getHealthColor() {
    if (contact.lastContactedAt == null) {
      return AppColors.healthRed;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final lastContact = contact.lastContactedAt!;
    final cadenceSeconds = contact.cadenceDays * 86400;

    final elapsed = now - lastContact;
    final percentage = elapsed / cadenceSeconds;

    if (percentage <= 0.5) {
      return AppColors.healthGreen;
    } else if (percentage <= 1.0) {
      return AppColors.healthYellow;
    } else {
      return AppColors.healthRed;
    }
  }
}

class _ContactInfoSection extends StatelessWidget {
  const _ContactInfoSection({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Info',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (contact.phone != null)
              _InfoRow(icon: Icons.phone, label: 'Phone', value: contact.phone!),
            if (contact.email != null)
              _InfoRow(icon: Icons.email, label: 'Email', value: contact.email!),
            if (contact.birthday != null)
              _InfoRow(
                icon: Icons.cake,
                label: 'Birthday',
                value: _formatDate(contact.birthday!),
              ),
            if (contact.phone == null &&
                contact.email == null &&
                contact.birthday == null)
              const Text('No contact info added'),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactStatusSection extends StatelessWidget {
  const _ContactStatusSection({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.schedule,
              label: 'Cadence',
              value: 'Every ${contact.cadenceDays} days',
            ),
            _InfoRow(
              icon: Icons.history,
              label: 'Last Contacted',
              value: contact.lastContactedAt != null
                  ? _formatDate(contact.lastContactedAt!)
                  : 'Never',
            ),
            if (contact.snoozedUntil != null)
              _InfoRow(
                icon: Icons.snooze,
                label: 'Snoozed Until',
                value: _formatDate(contact.snoozedUntil!),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection({required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Interactions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    context.go('/contacts/$contactId/interactions');
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('No interactions logged yet'),
          ],
        ),
      ),
    );
  }
}

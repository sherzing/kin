import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/database.dart';

/// Screen displaying the list of all contacts.
class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const _EmptyContactsView();
          }
          return _ContactListView(contacts: contacts);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading contacts: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddContactDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter contact name',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'Enter email address',
                ),
                keyboardType: TextInputType.emailAddress,
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
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      await ref.read(contactNotifierProvider.notifier).create(
            name: nameController.text.trim(),
            phone: phoneController.text.trim().isEmpty
                ? null
                : phoneController.text.trim(),
            email: emailController.text.trim().isEmpty
                ? null
                : emailController.text.trim(),
          );
    }
  }
}

class _EmptyContactsView extends StatelessWidget {
  const _EmptyContactsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No contacts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first contact',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _ContactListView extends StatelessWidget {
  const _ContactListView({required this.contacts});

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _ContactListTile(contact: contact);
      },
    );
  }
}

class _ContactListTile extends StatelessWidget {
  const _ContactListTile({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _ContactAvatar(contact: contact),
      title: Text(contact.name),
      subtitle: _buildSubtitle(),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.go('/contacts/${contact.id}');
      },
    );
  }

  Widget? _buildSubtitle() {
    final parts = <String>[];
    if (contact.phone != null) parts.add(contact.phone!);
    if (contact.email != null) parts.add(contact.email!);
    if (parts.isEmpty) return null;
    return Text(parts.first);
  }
}

class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor();

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: healthColor, width: 3),
      ),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          _getInitials(),
          style: TextStyle(
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

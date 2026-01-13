import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/database.dart';

/// Provider for the currently selected circle filter.
/// null means "All contacts", otherwise filter by the circle ID.
final selectedCircleFilterProvider = StateProvider<String?>((ref) => null);

/// Screen displaying the list of all contacts.
class ContactListScreen extends ConsumerWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);
    final circlesAsync = ref.watch(circlesProvider);
    final selectedCircle = ref.watch(selectedCircleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: [
          // Circle filter chips
          circlesAsync.when(
            data: (circles) {
              if (circles.isEmpty) {
                return const SizedBox.shrink();
              }
              return _CircleFilterChips(
                circles: circles,
                selectedCircleId: selectedCircle,
                onSelected: (circleId) {
                  ref.read(selectedCircleFilterProvider.notifier).state = circleId;
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Contact list
          Expanded(
            child: contactsAsync.when(
              data: (contacts) {
                if (contacts.isEmpty) {
                  return const _EmptyContactsView();
                }
                return _FilteredContactList(
                  allContacts: contacts,
                  selectedCircleId: selectedCircle,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading contacts: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CircleFilterChips extends StatelessWidget {
  const _CircleFilterChips({
    required this.circles,
    required this.selectedCircleId,
    required this.onSelected,
  });

  final List<Circle> circles;
  final String? selectedCircleId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedCircleId == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...circles.map((circle) {
            final isSelected = selectedCircleId == circle.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: CircleAvatar(
                  backgroundColor: _hexToColor(circle.colorHex),
                  radius: 8,
                ),
                label: Text(circle.name),
                selected: isSelected,
                onSelected: (_) => onSelected(isSelected ? null : circle.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return Colors.blue;
    }
    final hexCode = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

class _FilteredContactList extends ConsumerWidget {
  const _FilteredContactList({
    required this.allContacts,
    required this.selectedCircleId,
  });

  final List<Contact> allContacts;
  final String? selectedCircleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedCircleId == null) {
      // Show all contacts
      return _ContactListView(contacts: allContacts);
    }

    // Filter by circle
    final contactsInCircleAsync = ref.watch(contactsInCircleProvider(selectedCircleId!));

    return contactsInCircleAsync.when(
      data: (filteredContacts) {
        if (filteredContacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_off,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No contacts in this circle',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          );
        }
        return _ContactListView(contacts: filteredContacts);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
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

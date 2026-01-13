import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';

/// Screen for searching contacts, interactions, and circles.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize with current query if exists
    final currentQuery = ref.read(searchQueryProvider);
    if (currentQuery.isNotEmpty) {
      _searchController.text = currentQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _SearchField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: _clearSearch,
        ),
      ),
      body: query.isEmpty || query.length < 2
          ? const _EmptySearchState()
          : resultsAsync.when(
              data: (results) => results.isEmpty
                  ? _NoResultsState(query: query)
                  : _SearchResultsList(results: results),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
    );
  }
}

/// Search text field for the app bar.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search contacts, notes, circles...',
        border: InputBorder.none,
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
      ),
      textInputAction: TextInputAction.search,
    );
  }
}

/// Empty state when no search query is entered.
class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: theme.colorScheme.outline.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for contacts and interactions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Type at least 2 characters to search',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// State when search returns no results.
class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.outline.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No matches for "$query"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// List of search results grouped by type.
class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.results});

  final SearchResults results;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Contacts section
        if (results.contacts.isNotEmpty) ...[
          _SectionHeader(
            title: 'Contacts',
            count: results.contacts.length,
            icon: Icons.person,
          ),
          ...results.contacts.map((contact) => _ContactResultTile(contact: contact)),
        ],

        // Interactions section
        if (results.interactions.isNotEmpty) ...[
          _SectionHeader(
            title: 'Notes & Interactions',
            count: results.interactions.length,
            icon: Icons.note,
          ),
          ...results.interactions
              .map((interaction) => _InteractionResultTile(interaction: interaction)),
        ],

        // Circles section
        if (results.circles.isNotEmpty) ...[
          _SectionHeader(
            title: 'Circles',
            count: results.circles.length,
            icon: Icons.group_work,
          ),
          ...results.circles.map((circle) => _CircleResultTile(circle: circle)),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

/// Section header for grouped results.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List tile for a contact result.
class _ContactResultTile extends StatelessWidget {
  const _ContactResultTile({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(_getInitials()),
      ),
      title: Text(contact.name),
      subtitle: Text(contact.phone ?? contact.email ?? 'No contact info'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/contacts/${contact.id}'),
    );
  }

  String _getInitials() {
    final parts = contact.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }
}

/// List tile for an interaction result.
class _InteractionResultTile extends ConsumerWidget {
  const _InteractionResultTile({required this.interaction});

  final Interaction interaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the contact name for display
    final contactAsync = ref.watch(contactProvider(interaction.contactId));
    final contactName = contactAsync.maybeWhen(
      data: (contact) => contact?.name ?? 'Unknown',
      orElse: () => 'Loading...',
    );

    final typeDisplay = interaction.type.isNotEmpty
        ? interaction.type[0].toUpperCase() + interaction.type.substring(1)
        : 'Note';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          _getIconForType(interaction.type),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        interaction.content ?? typeDisplay,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('$typeDisplay with $contactName'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/contacts/${interaction.contactId}/interactions'),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return Icons.phone;
      case 'meetup':
        return Icons.people;
      case 'message':
        return Icons.message;
      case 'email':
        return Icons.email;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.note;
    }
  }
}

/// List tile for a circle result.
class _CircleResultTile extends StatelessWidget {
  const _CircleResultTile({required this.circle});

  final Circle circle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _hexToColor(circle.colorHex),
        child: const Icon(Icons.group_work, color: Colors.white),
      ),
      title: Text(circle.name),
      subtitle: const Text('Circle'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/settings/circles'),
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

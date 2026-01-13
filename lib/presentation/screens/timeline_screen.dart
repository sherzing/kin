import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';
import '../../data/database/tables/interactions.dart';

/// Provider for the currently selected interaction type filter.
/// null means show all types.
final timelineTypeFilterProvider = StateProvider<InteractionType?>((ref) => null);

/// Screen showing all interactions in chronological order.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionsAsync = ref.watch(timelineProvider);
    final typeFilter = ref.watch(timelineTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          PopupMenuButton<InteractionType?>(
            icon: Icon(
              typeFilter == null ? Icons.filter_list : Icons.filter_list_alt,
              color: typeFilter != null ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Filter by type',
            onSelected: (type) {
              ref.read(timelineTypeFilterProvider.notifier).state = type;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All types'),
              ),
              const PopupMenuDivider(),
              ...InteractionType.values.map((type) => PopupMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getIconForType(type), size: 20),
                        const SizedBox(width: 8),
                        Text(_getTypeLabel(type)),
                        if (typeFilter == type) ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 18),
                        ],
                      ],
                    ),
                  )),
            ],
          ),
        ],
      ),
      body: interactionsAsync.when(
        data: (interactions) {
          // Filter by type if selected
          final filtered = typeFilter == null
              ? interactions
              : interactions.where((i) => i.type == typeFilter.name).toList();

          if (filtered.isEmpty) {
            return _EmptyTimelineState(hasFilter: typeFilter != null);
          }

          return _TimelineList(interactions: filtered);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  IconData _getIconForType(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return Icons.phone;
      case InteractionType.meetup:
        return Icons.people;
      case InteractionType.message:
        return Icons.message;
      case InteractionType.email:
        return Icons.email;
      case InteractionType.gift:
        return Icons.card_giftcard;
    }
  }

  String _getTypeLabel(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return 'Calls';
      case InteractionType.meetup:
        return 'Meetups';
      case InteractionType.message:
        return 'Messages';
      case InteractionType.email:
        return 'Emails';
      case InteractionType.gift:
        return 'Gifts';
    }
  }
}

/// Empty state for timeline.
class _EmptyTimelineState extends StatelessWidget {
  const _EmptyTimelineState({required this.hasFilter});

  final bool hasFilter;

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
              hasFilter ? Icons.filter_list_off : Icons.timeline,
              size: 80,
              color: theme.colorScheme.outline.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilter ? 'No matching interactions' : 'No interactions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try removing the filter or log some interactions'
                  : 'Interactions you log will appear here',
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

/// Timeline list grouped by date.
class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.interactions});

  final List<Interaction> interactions;

  @override
  Widget build(BuildContext context) {
    // Group interactions by date
    final grouped = _groupByDate(interactions);

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final dateLabel = entry.key;
        final dayInteractions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            _DateHeader(label: dateLabel),
            // Interactions for this date
            ...dayInteractions.map((i) => _TimelineInteractionTile(interaction: i)),
          ],
        );
      },
    );
  }

  Map<String, List<Interaction>> _groupByDate(List<Interaction> interactions) {
    final grouped = <String, List<Interaction>>{};

    for (final interaction in interactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(interaction.happenedAt * 1000);
      final label = _getDateLabel(date);

      grouped.putIfAbsent(label, () => []).add(interaction);
    }

    return grouped;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      // Within last week - show day name
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    } else if (date.year == now.year) {
      // Same year - show month and day
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    } else {
      // Different year
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

/// Date header for grouped timeline.
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Single interaction tile in the timeline.
class _TimelineInteractionTile extends ConsumerWidget {
  const _TimelineInteractionTile({required this.interaction});

  final Interaction interaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactProvider(interaction.contactId));
    final contactName = contactAsync.maybeWhen(
      data: (contact) => contact?.name ?? 'Unknown',
      orElse: () => 'Loading...',
    );

    final typeDisplay = interaction.type.isNotEmpty
        ? interaction.type[0].toUpperCase() + interaction.type.substring(1)
        : 'Note';

    final time = DateTime.fromMillisecondsSinceEpoch(interaction.happenedAt * 1000);
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          _getIconForType(interaction.type),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(contactName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(typeDisplay),
          if (interaction.content != null && interaction.content!.isNotEmpty)
            Text(
              interaction.content!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: Text(
        timeString,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
      isThreeLine: interaction.content != null && interaction.content!.isNotEmpty,
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

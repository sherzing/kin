import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';
import '../../data/database/tables/interactions.dart';
import '../widgets/widgets.dart';

/// Screen displaying interaction history for a contact.
class InteractionListScreen extends ConsumerWidget {
  const InteractionListScreen({
    super.key,
    required this.contactId,
  });

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionsAsync = ref.watch(interactionsForContactProvider(contactId));
    final contactAsync = ref.watch(contactProvider(contactId));

    return Scaffold(
      appBar: AppBar(
        title: contactAsync.when(
          data: (contact) => Text(contact?.name ?? 'Interactions'),
          loading: () => const Text('Interactions'),
          error: (error, stack) => const Text('Interactions'),
        ),
      ),
      body: interactionsAsync.when(
        data: (interactions) {
          if (interactions.isEmpty) {
            return _EmptyInteractionsView(
              onLogInteraction: () =>
                  context.push('/contacts/$contactId/interactions/new'),
            );
          }
          return _InteractionTimeline(
            interactions: interactions,
            contactId: contactId,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading interactions: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contacts/$contactId/interactions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Log Interaction'),
      ),
    );
  }
}

class _EmptyInteractionsView extends StatelessWidget {
  const _EmptyInteractionsView({this.onLogInteraction});

  final VoidCallback? onLogInteraction;

  @override
  Widget build(BuildContext context) {
    return NoInteractionsIllustration(onLogInteraction: onLogInteraction);
  }
}

class _InteractionTimeline extends StatelessWidget {
  const _InteractionTimeline({
    required this.interactions,
    required this.contactId,
  });

  final List<Interaction> interactions;
  final String contactId;

  @override
  Widget build(BuildContext context) {
    // Group interactions by date
    final grouped = _groupByDate(interactions);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return _DateGroup(
          date: entry.key,
          interactions: entry.value,
          contactId: contactId,
        );
      },
    );
  }

  Map<String, List<Interaction>> _groupByDate(List<Interaction> interactions) {
    final Map<String, List<Interaction>> grouped = {};

    for (final interaction in interactions) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        interaction.happenedAt * 1000,
      );
      final key = _formatDateKey(date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(interaction);
    }

    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateOnly).inDays < 7) {
      return _weekdayName(date.weekday);
    } else {
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.interactions,
    required this.contactId,
  });

  final String date;
  final List<Interaction> interactions;
  final String contactId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            date,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...interactions.map((interaction) => _InteractionCard(
              interaction: interaction,
              contactId: contactId,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({
    required this.interaction,
    required this.contactId,
  });

  final Interaction interaction;
  final String contactId;

  @override
  Widget build(BuildContext context) {
    final type = InteractionType.values.firstWhere(
      (t) => t.name == interaction.type,
      orElse: () => InteractionType.call,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push(
          '/contacts/$contactId/interactions/${interaction.id}/edit',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getTypeLabel(type),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (interaction.isPreparation) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Prep',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          _formatTime(interaction.happenedAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                        ),
                      ],
                    ),
                    if (interaction.content != null &&
                        interaction.content!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _truncateContent(interaction.content!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return Icons.call;
      case InteractionType.meetup:
        return Icons.people;
      case InteractionType.message:
        return Icons.chat;
      case InteractionType.email:
        return Icons.email;
      case InteractionType.gift:
        return Icons.card_giftcard;
    }
  }

  String _getTypeLabel(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return 'Call';
      case InteractionType.meetup:
        return 'Meetup';
      case InteractionType.message:
        return 'Message';
      case InteractionType.email:
        return 'Email';
      case InteractionType.gift:
        return 'Gift';
    }
  }

  Color _getTypeColor(InteractionType type) {
    switch (type) {
      case InteractionType.call:
        return Colors.blue;
      case InteractionType.meetup:
        return Colors.green;
      case InteractionType.message:
        return Colors.purple;
      case InteractionType.email:
        return Colors.orange;
      case InteractionType.gift:
        return Colors.pink;
    }
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _truncateContent(String content) {
    // Remove markdown syntax for preview
    String cleaned = content
        .replaceAll(RegExp(r'\*\*|__|~~|`'), '')
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^[-*]\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';
import '../widgets/widgets.dart';

/// The Daily Deck screen - home screen showing prioritized contacts.
///
/// Displays contacts that are due for contact based on their cadence,
/// sorted by most overdue first.
class DailyDeckScreen extends ConsumerWidget {
  const DailyDeckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueContactsAsync = ref.watch(dailyDeckProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Deck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: dueContactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const _EmptyDeckView();
          }
          return _DeckCardList(contacts: contacts);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load contacts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state when there are no contacts due.
class _EmptyDeckView extends StatelessWidget {
  const _EmptyDeckView();

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
              Icons.check_circle_outline,
              size: 80,
              color: theme.colorScheme.primary.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              "You're all caught up!",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No contacts are due for a check-in right now. Great job staying connected!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A swipeable card list for the Daily Deck.
class _DeckCardList extends ConsumerWidget {
  const _DeckCardList({required this.contacts});

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Deck count header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.inbox,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${contacts.length} ${contacts.length == 1 ? 'contact' : 'contacts'} to reach out to',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),

        // Card list
        Expanded(
          child: ListView.builder(
            itemCount: contacts.length,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return SwipeableDeckCard(
                contact: contact,
                onTap: () => context.go('/contacts/${contact.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

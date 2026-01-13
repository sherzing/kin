import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/database/database.dart';
import '../widgets/widgets.dart';

/// Provider to track whether to show celebration.
/// Resets when the deck has contacts again.
final showCelebrationProvider = StateProvider<bool>((ref) => false);

/// Provider to track the previous contact count for detecting transitions.
final _previousContactCountProvider = StateProvider<int?>((ref) => null);

/// The Daily Deck screen - home screen showing prioritized contacts.
///
/// Displays contacts that are due for contact based on their cadence,
/// sorted by most overdue first.
class DailyDeckScreen extends ConsumerWidget {
  const DailyDeckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueContactsAsync = ref.watch(dailyDeckProvider);
    final showCelebration = ref.watch(showCelebrationProvider);

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
      body: Stack(
        children: [
          dueContactsAsync.when(
            data: (contacts) {
              // Check for celebration trigger
              final previousCount = ref.read(_previousContactCountProvider);
              if (previousCount != null &&
                  previousCount > 0 &&
                  contacts.isEmpty) {
                // Deck just became empty - trigger celebration
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(showCelebrationProvider.notifier).state = true;
                });
              }
              // Update previous count
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(_previousContactCountProvider.notifier).state =
                    contacts.length;
              });

              if (contacts.isEmpty) {
                return const _EmptyDeckView();
              }

              // Reset celebration flag when deck has contacts
              if (showCelebration && contacts.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(showCelebrationProvider.notifier).state = false;
                });
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
          // Celebration overlay
          if (showCelebration)
            CelebrationOverlay(
              onComplete: () {
                ref.read(showCelebrationProvider.notifier).state = false;
              },
            ),
        ],
      ),
    );
  }
}

/// Empty state when there are no contacts due.
class _EmptyDeckView extends StatelessWidget {
  const _EmptyDeckView();

  @override
  Widget build(BuildContext context) {
    return const AllCaughtUpIllustration();
  }
}

/// A swipeable card list for the Daily Deck with staggered animations.
class _DeckCardList extends ConsumerStatefulWidget {
  const _DeckCardList({required this.contacts});

  final List<Contact> contacts;

  @override
  ConsumerState<_DeckCardList> createState() => _DeckCardListState();
}

class _DeckCardListState extends ConsumerState<_DeckCardList>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.contacts.length * 50),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Deck count header with fade-in
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _staggerController,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.inbox,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.contacts.length} ${widget.contacts.length == 1 ? 'contact' : 'contacts'} to reach out to',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),

        // Card list with staggered animations
        Expanded(
          child: ListView.builder(
            itemCount: widget.contacts.length,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              final contact = widget.contacts[index];

              // Calculate stagger interval for this card
              final startInterval = 0.1 + (index * 0.1);
              final endInterval = (startInterval + 0.3).clamp(0.0, 1.0);

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _staggerController,
                    curve: Interval(
                      startInterval.clamp(0.0, 1.0),
                      endInterval,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _staggerController,
                    curve: Interval(
                      startInterval.clamp(0.0, 1.0),
                      endInterval,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: SwipeableDeckCard(
                    contact: contact,
                    onTap: () => context.go('/contacts/${contact.id}'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

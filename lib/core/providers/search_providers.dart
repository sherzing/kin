import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import 'database_providers.dart';

/// Provider for the current search query.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Combined search results across all entity types.
class SearchResults {
  const SearchResults({
    this.contacts = const [],
    this.interactions = const [],
    this.circles = const [],
  });

  final List<Contact> contacts;
  final List<Interaction> interactions;
  final List<Circle> circles;

  bool get isEmpty => contacts.isEmpty && interactions.isEmpty && circles.isEmpty;
  int get totalCount => contacts.length + interactions.length + circles.length;

  static const empty = SearchResults();
}

/// Provider for search results.
///
/// Searches across contacts (by name), interactions (by content),
/// and circles (by name) based on the current search query.
final searchResultsProvider = FutureProvider<SearchResults>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();

  if (query.isEmpty || query.length < 2) {
    return SearchResults.empty;
  }

  final contactRepo = ref.read(contactRepositoryProvider);
  final interactionRepo = ref.read(interactionRepositoryProvider);
  final circleRepo = ref.read(circleRepositoryProvider);

  // Search all repositories in parallel
  final results = await Future.wait([
    contactRepo.search(query),
    interactionRepo.search(query),
    circleRepo.search(query),
  ]);

  return SearchResults(
    contacts: results[0] as List<Contact>,
    interactions: results[1] as List<Interaction>,
    circles: results[2] as List<Circle>,
  );
});

/// Provider for all interactions in chronological order (timeline).
///
/// Shows all interactions sorted by happenedAt descending (newest first).
final timelineProvider = StreamProvider<List<Interaction>>((ref) {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.watchAll();
});

/// Provider for timeline with optional contact filter.
final filteredTimelineProvider =
    StreamProvider.family<List<Interaction>, String?>((ref, contactId) {
  final repository = ref.watch(interactionRepositoryProvider);

  if (contactId == null) {
    return repository.watchAll();
  } else {
    return repository.watchForContact(contactId);
  }
});

/// Provider for paginated timeline.
///
/// Returns interactions in pages for efficient loading of large histories.
class TimelinePagination {
  const TimelinePagination({
    required this.interactions,
    required this.hasMore,
    required this.currentPage,
  });

  final List<Interaction> interactions;
  final bool hasMore;
  final int currentPage;

  static const int pageSize = 20;

  static const empty = TimelinePagination(
    interactions: [],
    hasMore: false,
    currentPage: 0,
  );
}

/// Notifier for paginated timeline loading.
class TimelinePaginationNotifier extends Notifier<TimelinePagination> {
  @override
  TimelinePagination build() {
    return TimelinePagination.empty;
  }

  Future<void> loadNextPage() async {
    final repository = ref.read(interactionRepositoryProvider);
    final currentPage = state.currentPage;
    final offset = currentPage * TimelinePagination.pageSize;

    final newInteractions = await repository.getAll(
      limit: TimelinePagination.pageSize + 1, // +1 to check if there's more
      offset: offset,
    );

    final hasMore = newInteractions.length > TimelinePagination.pageSize;
    final pageInteractions = hasMore
        ? newInteractions.sublist(0, TimelinePagination.pageSize)
        : newInteractions;

    state = TimelinePagination(
      interactions: [...state.interactions, ...pageInteractions],
      hasMore: hasMore,
      currentPage: currentPage + 1,
    );
  }

  void reset() {
    state = TimelinePagination.empty;
  }
}

/// Provider for paginated timeline.
final timelinePaginationProvider =
    NotifierProvider<TimelinePaginationNotifier, TimelinePagination>(() {
  return TimelinePaginationNotifier();
});

/// Search result type for unified display.
enum SearchResultType { contact, interaction, circle }

/// A single search result item for unified display.
class SearchResultItem {
  const SearchResultItem({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.metadata,
  });

  final SearchResultType type;
  final String id;
  final String title;
  final String? subtitle;
  final Map<String, dynamic>? metadata;

  factory SearchResultItem.fromContact(Contact contact) {
    return SearchResultItem(
      type: SearchResultType.contact,
      id: contact.id,
      title: contact.name,
      subtitle: contact.phone ?? contact.email,
      metadata: {'contact': contact},
    );
  }

  factory SearchResultItem.fromInteraction(Interaction interaction) {
    // Capitalize the type for display
    final typeDisplay = interaction.type.isNotEmpty
        ? interaction.type[0].toUpperCase() + interaction.type.substring(1)
        : 'Interaction';

    return SearchResultItem(
      type: SearchResultType.interaction,
      id: interaction.id,
      title: typeDisplay,
      subtitle: interaction.content,
      metadata: {
        'interaction': interaction,
        'contactId': interaction.contactId,
      },
    );
  }

  factory SearchResultItem.fromCircle(Circle circle) {
    return SearchResultItem(
      type: SearchResultType.circle,
      id: circle.id,
      title: circle.name,
      subtitle: null,
      metadata: {'circle': circle, 'colorHex': circle.colorHex},
    );
  }
}

/// Provider for flattened search results as a list.
final flatSearchResultsProvider = Provider<List<SearchResultItem>>((ref) {
  final resultsAsync = ref.watch(searchResultsProvider);

  return resultsAsync.maybeWhen(
    data: (results) {
      final items = <SearchResultItem>[];

      // Add contacts
      for (final contact in results.contacts) {
        items.add(SearchResultItem.fromContact(contact));
      }

      // Add interactions
      for (final interaction in results.interactions) {
        items.add(SearchResultItem.fromInteraction(interaction));
      }

      // Add circles
      for (final circle in results.circles) {
        items.add(SearchResultItem.fromCircle(circle));
      }

      return items;
    },
    orElse: () => [],
  );
});

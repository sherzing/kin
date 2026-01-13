import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/database/tables/interactions.dart';
import 'database_providers.dart';

/// Provider for all non-deleted interactions as a stream.
final interactionsProvider = StreamProvider<List<Interaction>>((ref) {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.watchAll();
});

/// Provider for interactions for a specific contact.
final interactionsForContactProvider =
    StreamProvider.family<List<Interaction>, String>((ref, contactId) {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.watchForContact(contactId);
});

/// Provider for preparation notes for a specific contact.
final preparationNotesProvider =
    StreamProvider.family<List<Interaction>, String>((ref, contactId) {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.watchPreparationNotes(contactId);
});

/// Provider for a single interaction by ID.
final interactionProvider =
    FutureProvider.family<Interaction?, String>((ref, id) async {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.getById(id);
});

/// Provider for the most recent interaction for a contact.
final recentInteractionProvider =
    FutureProvider.family<Interaction?, String>((ref, contactId) async {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.getMostRecent(contactId);
});

/// Provider for searching interactions.
final interactionSearchProvider =
    FutureProvider.family<List<Interaction>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.search(query);
});

/// Provider for interactions filtered by type.
final interactionsByTypeProvider =
    FutureProvider.family<List<Interaction>, InteractionType>(
        (ref, type) async {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.getByType(type);
});

/// Notifier for interaction mutations (create, update, delete).
class InteractionNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Create a new interaction.
  Future<Interaction> create({
    required String contactId,
    required InteractionType type,
    String? content,
    bool isPreparation = false,
    DateTime? happenedAt,
  }) async {
    final repository = ref.read(interactionRepositoryProvider);
    final interaction = await repository.create(
      contactId: contactId,
      type: type,
      content: content,
      isPreparation: isPreparation,
      happenedAt: happenedAt,
    );
    ref.invalidate(interactionsProvider);
    ref.invalidate(interactionsForContactProvider(contactId));
    ref.invalidate(recentInteractionProvider(contactId));
    return interaction;
  }

  /// Update an existing interaction.
  Future<Interaction> update(
    String id, {
    String? contactId, // Only used for invalidation
    InteractionType? type,
    String? content,
    bool? isPreparation,
    DateTime? happenedAt,
  }) async {
    final repository = ref.read(interactionRepositoryProvider);
    final interaction = await repository.update(
      id,
      type: type,
      content: content,
      isPreparation: isPreparation,
      happenedAt: happenedAt,
    );
    ref.invalidate(interactionsProvider);
    ref.invalidate(interactionProvider(id));
    if (contactId != null) {
      ref.invalidate(interactionsForContactProvider(contactId));
      ref.invalidate(recentInteractionProvider(contactId));
    }
    return interaction;
  }

  /// Delete an interaction (soft delete).
  Future<void> delete(String id, {String? contactId}) async {
    final repository = ref.read(interactionRepositoryProvider);
    await repository.delete(id);
    ref.invalidate(interactionsProvider);
    ref.invalidate(interactionProvider(id));
    if (contactId != null) {
      ref.invalidate(interactionsForContactProvider(contactId));
      ref.invalidate(recentInteractionProvider(contactId));
    }
  }
}

/// Provider for interaction mutations.
final interactionNotifierProvider =
    NotifierProvider<InteractionNotifier, void>(() {
  return InteractionNotifier();
});

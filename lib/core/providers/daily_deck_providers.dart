import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/database/tables/interactions.dart';
import 'contact_providers.dart';
import 'database_providers.dart';
import 'interaction_providers.dart';

/// Provider for contacts due in the Daily Deck.
///
/// Returns contacts where:
/// - (last_contacted_at + cadence_days) <= today, OR last_contacted_at is null
/// - snoozed_until is null OR snoozed_until <= today
/// - deleted_at is null
///
/// Sorted by most overdue first.
final dailyDeckProvider = StreamProvider<List<Contact>>((ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchDueContacts();
});

/// Provider for the count of contacts in the Daily Deck.
final dailyDeckCountProvider = Provider<AsyncValue<int>>((ref) {
  final deckAsync = ref.watch(dailyDeckProvider);
  return deckAsync.whenData((contacts) => contacts.length);
});

/// Notifier for Daily Deck actions (quick log, snooze, dismiss).
class DailyDeckNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Quick log a contact - marks them as contacted now without detailed notes.
  ///
  /// Creates a minimal interaction and updates the contact's last_contacted_at.
  /// Returns the created interaction.
  Future<Interaction> quickLog(
    String contactId, {
    InteractionType type = InteractionType.message,
  }) async {
    final interactionNotifier = ref.read(interactionNotifierProvider.notifier);

    // Create a simple interaction - the notifier handles updating last_contacted_at
    final interaction = await interactionNotifier.create(
      contactId: contactId,
      type: type,
      isPreparation: false,
    );

    // Invalidate daily deck to refresh the list
    ref.invalidate(dailyDeckProvider);

    return interaction;
  }

  /// Snooze a contact until a specific date.
  ///
  /// The contact won't appear in the Daily Deck until the snooze expires.
  Future<Contact> snooze(String contactId, DateTime until) async {
    final contactNotifier = ref.read(contactNotifierProvider.notifier);
    final contact = await contactNotifier.snooze(contactId, until);

    // Invalidate daily deck to refresh the list
    ref.invalidate(dailyDeckProvider);

    return contact;
  }

  /// Snooze a contact for a number of days from now.
  Future<Contact> snoozeForDays(String contactId, int days) async {
    final until = DateTime.now().add(Duration(days: days));
    return snooze(contactId, until);
  }

  /// Clear snooze for a contact, making them appear in the deck if due.
  Future<Contact> clearSnooze(String contactId) async {
    final repository = ref.read(contactRepositoryProvider);
    final contact = await repository.clearSnooze(contactId);

    ref.invalidate(dailyDeckProvider);
    ref.invalidate(contactProvider(contactId));

    return contact;
  }

  /// Mark a contact as contacted without creating an interaction.
  ///
  /// Use this for "I already talked to them" scenarios.
  Future<Contact> markContacted(String contactId) async {
    final contactNotifier = ref.read(contactNotifierProvider.notifier);
    final contact = await contactNotifier.markContacted(contactId);

    // Invalidate daily deck to refresh the list
    ref.invalidate(dailyDeckProvider);

    return contact;
  }
}

/// Provider for Daily Deck actions.
final dailyDeckNotifierProvider =
    NotifierProvider<DailyDeckNotifier, void>(() {
  return DailyDeckNotifier();
});

/// Provider for snooze presets (in days).
///
/// Common snooze durations for quick selection.
final snoozePresetsProvider = Provider<List<SnoozePreset>>((ref) {
  return const [
    SnoozePreset(days: 1, label: 'Tomorrow'),
    SnoozePreset(days: 3, label: '3 days'),
    SnoozePreset(days: 7, label: '1 week'),
    SnoozePreset(days: 14, label: '2 weeks'),
    SnoozePreset(days: 30, label: '1 month'),
  ];
});

/// A snooze duration preset.
class SnoozePreset {
  const SnoozePreset({
    required this.days,
    required this.label,
  });

  final int days;
  final String label;

  DateTime get until => DateTime.now().add(Duration(days: days));
}

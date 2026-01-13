import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import 'database_providers.dart';

/// Provider for all non-deleted contacts as a stream.
final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchAll();
});

/// Provider for contacts due in the Daily Deck as a stream.
final dueContactsProvider = StreamProvider<List<Contact>>((ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.watchDueContacts();
});

/// Provider for a single contact by ID.
final contactProvider =
    FutureProvider.family<Contact?, String>((ref, id) async {
  final repository = ref.watch(contactRepositoryProvider);
  return repository.getById(id);
});

/// Provider for searching contacts by name.
final contactSearchProvider =
    FutureProvider.family<List<Contact>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.watch(contactRepositoryProvider);
  return repository.search(query);
});

/// Notifier for contact mutations (create, update, delete).
class ContactNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Create a new contact.
  Future<Contact> create({
    required String name,
    String? phone,
    String? email,
    DateTime? birthday,
    String? jobTitle,
    int cadenceDays = 30,
  }) async {
    final repository = ref.read(contactRepositoryProvider);
    final contact = await repository.create(
      name: name,
      phone: phone,
      email: email,
      birthday: birthday,
      jobTitle: jobTitle,
      cadenceDays: cadenceDays,
    );
    ref.invalidate(contactsProvider);
    ref.invalidate(dueContactsProvider);
    return contact;
  }

  /// Update an existing contact.
  Future<Contact> update(
    String id, {
    String? name,
    String? phone,
    String? email,
    DateTime? birthday,
    String? jobTitle,
    int? cadenceDays,
  }) async {
    final repository = ref.read(contactRepositoryProvider);
    final contact = await repository.update(
      id,
      name: name,
      phone: phone,
      email: email,
      birthday: birthday,
      jobTitle: jobTitle,
      cadenceDays: cadenceDays,
    );
    ref.invalidate(contactsProvider);
    ref.invalidate(dueContactsProvider);
    ref.invalidate(contactProvider(id));
    return contact;
  }

  /// Delete a contact (soft delete).
  Future<void> delete(String id) async {
    final repository = ref.read(contactRepositoryProvider);
    await repository.delete(id);
    ref.invalidate(contactsProvider);
    ref.invalidate(dueContactsProvider);
    ref.invalidate(contactProvider(id));
  }

  /// Mark a contact as contacted today.
  Future<Contact> markContacted(String id) async {
    final repository = ref.read(contactRepositoryProvider);
    final contact = await repository.markContacted(id);
    ref.invalidate(contactsProvider);
    ref.invalidate(dueContactsProvider);
    ref.invalidate(contactProvider(id));
    return contact;
  }

  /// Snooze a contact until a specific date.
  Future<Contact> snooze(String id, DateTime until) async {
    final repository = ref.read(contactRepositoryProvider);
    final contact = await repository.snooze(id, until);
    ref.invalidate(contactsProvider);
    ref.invalidate(dueContactsProvider);
    ref.invalidate(contactProvider(id));
    return contact;
  }
}

/// Provider for contact mutations.
final contactNotifierProvider = NotifierProvider<ContactNotifier, void>(() {
  return ContactNotifier();
});

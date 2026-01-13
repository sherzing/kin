import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import 'database_providers.dart';

/// Provider for all non-deleted circles as a stream.
final circlesProvider = StreamProvider<List<Circle>>((ref) {
  final repository = ref.watch(circleRepositoryProvider);
  return repository.watchAll();
});

/// Provider for a single circle by ID.
final circleProvider =
    FutureProvider.family<Circle?, String>((ref, id) async {
  final repository = ref.watch(circleRepositoryProvider);
  return repository.getById(id);
});

/// Provider for circles assigned to a specific contact.
final circlesForContactProvider =
    StreamProvider.family<List<Circle>, String>((ref, contactId) {
  final repository = ref.watch(circleRepositoryProvider);
  return repository.watchForContact(contactId);
});

/// Provider for contacts in a specific circle.
final contactsInCircleProvider =
    FutureProvider.family<List<Contact>, String>((ref, circleId) async {
  final repository = ref.watch(circleRepositoryProvider);
  return repository.getContactsInCircle(circleId);
});

/// Notifier for circle mutations (create, update, delete, assign contacts).
class CircleNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Create a new circle.
  Future<Circle> create({
    required String name,
    String? colorHex,
  }) async {
    final repository = ref.read(circleRepositoryProvider);
    final circle = await repository.create(
      name: name,
      colorHex: colorHex,
    );
    ref.invalidate(circlesProvider);
    return circle;
  }

  /// Update an existing circle.
  Future<Circle> update(
    String id, {
    String? name,
    String? colorHex,
  }) async {
    final repository = ref.read(circleRepositoryProvider);
    final circle = await repository.update(
      id,
      name: name,
      colorHex: colorHex,
    );
    ref.invalidate(circlesProvider);
    ref.invalidate(circleProvider(id));
    return circle;
  }

  /// Delete a circle (soft delete).
  Future<void> delete(String id) async {
    final repository = ref.read(circleRepositoryProvider);
    await repository.delete(id);
    ref.invalidate(circlesProvider);
    ref.invalidate(circleProvider(id));
  }

  /// Add a contact to a circle.
  Future<void> addContactToCircle(String contactId, String circleId) async {
    final repository = ref.read(circleRepositoryProvider);
    await repository.addContactToCircle(contactId, circleId);
    ref.invalidate(circlesForContactProvider(contactId));
    ref.invalidate(contactsInCircleProvider(circleId));
  }

  /// Remove a contact from a circle.
  Future<void> removeContactFromCircle(
      String contactId, String circleId) async {
    final repository = ref.read(circleRepositoryProvider);
    await repository.removeContactFromCircle(contactId, circleId);
    ref.invalidate(circlesForContactProvider(contactId));
    ref.invalidate(contactsInCircleProvider(circleId));
  }
}

/// Provider for circle mutations.
final circleNotifierProvider = NotifierProvider<CircleNotifier, void>(() {
  return CircleNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/repositories/repositories.dart';

/// Provider for the app database instance.
///
/// This is a singleton database that persists for the app's lifetime.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider for the contact repository.
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ContactRepository(db);
});

/// Provider for the circle repository.
final circleRepositoryProvider = Provider<CircleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CircleRepository(db);
});

/// Provider for the interaction repository.
final interactionRepositoryProvider = Provider<InteractionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InteractionRepository(db);
});

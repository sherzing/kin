import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/providers.dart';
import 'package:kin/data/database/database.dart';

import '../../helpers/test_providers.dart';

void main() {
  setUpAll(() {
    setUpTestEnvironment();
  });

  group('dailyDeckProvider', () {
    test('returns empty list when no contacts exist', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        // Wait for stream to emit
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, isEmpty);

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('returns contacts that have never been contacted', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        // Create a contact with no lastContactedAt
        final contactRepo = container.read(contactRepositoryProvider);
        await contactRepo.create(name: 'Never Contacted');

        // Wait for stream to emit
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, hasLength(1));
        expect(dueContacts.first.name, 'Never Contacted');

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('returns contacts past their cadence', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);

        // Create contact and mark as contacted 35 days ago (past 30-day cadence)
        final contact = await contactRepo.create(name: 'Overdue', cadenceDays: 30);
        final thirtyFiveDaysAgo = DateTime.now().subtract(const Duration(days: 35));
        await contactRepo.update(contact.id, lastContactedAt: thirtyFiveDaysAgo);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, hasLength(1));
        expect(dueContacts.first.name, 'Overdue');

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('excludes contacts within their cadence', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);

        // Create contact and mark as contacted yesterday (within 30-day cadence)
        final contact = await contactRepo.create(name: 'Recent', cadenceDays: 30);
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        await contactRepo.update(contact.id, lastContactedAt: yesterday);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, isEmpty);

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('excludes snoozed contacts', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);

        // Create contact that is due but snoozed
        final contact = await contactRepo.create(name: 'Snoozed', cadenceDays: 1);
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        await contactRepo.update(contact.id, lastContactedAt: twoDaysAgo);

        // Snooze for 1 week
        await contactRepo.snooze(contact.id, DateTime.now().add(const Duration(days: 7)));

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, isEmpty);

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('includes contacts with expired snooze', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);

        // Create contact that is due with expired snooze
        final contact = await contactRepo.create(name: 'Snooze Expired', cadenceDays: 1);

        // Set lastContactedAt to 10 days ago and snoozedUntil to yesterday
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        await contactRepo.update(contact.id, lastContactedAt: tenDaysAgo);

        // Manually update snoozedUntil to yesterday (expired)
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        await contactRepo.update(contact.id, snoozedUntil: yesterday);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, hasLength(1));
        expect(dueContacts.first.name, 'Snooze Expired');

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('sorts by most overdue first', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);

        // Create contacts with different overdue amounts
        final c1 = await contactRepo.create(name: 'Slightly Overdue', cadenceDays: 7);
        final c2 = await contactRepo.create(name: 'Very Overdue', cadenceDays: 7);
        final c3 = await contactRepo.create(name: 'Never Contacted'); // Most overdue

        // Set last contacted times
        await contactRepo.update(
          c1.id,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 8)),
        ); // 1 day overdue
        await contactRepo.update(
          c2.id,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 21)),
        ); // 14 days overdue

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts, hasLength(3));
        // Never contacted should be first (most overdue)
        expect(dueContacts[0].name, 'Never Contacted');
        // Then very overdue
        expect(dueContacts[1].name, 'Very Overdue');
        // Then slightly overdue
        expect(dueContacts[2].name, 'Slightly Overdue');

        container.dispose();
      } finally {
        await db.close();
      }
    });
  });

  group('DailyDeckNotifier', () {
    test('quickLog creates interaction and removes from deck', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);
        final contact = await contactRepo.create(name: 'Test Contact');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should be in deck (never contacted)
        var dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts.any((c) => c.id == contact.id), isTrue);

        // Quick log
        final notifier = container.read(dailyDeckNotifierProvider.notifier);
        await notifier.quickLog(contact.id);

        // Should be removed from deck
        await Future<void>.delayed(const Duration(milliseconds: 100));
        dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts.any((c) => c.id == contact.id), isFalse);

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('snoozeForDays removes contact from deck', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);
        final contact = await contactRepo.create(name: 'Snooze Test');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should be in deck
        var dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts.any((c) => c.id == contact.id), isTrue);

        // Snooze for 3 days
        final notifier = container.read(dailyDeckNotifierProvider.notifier);
        await notifier.snoozeForDays(contact.id, 3);

        // Should be removed from deck
        await Future<void>.delayed(const Duration(milliseconds: 100));
        dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts.any((c) => c.id == contact.id), isFalse);

        container.dispose();
      } finally {
        await db.close();
      }
    });

    test('clearSnooze adds contact back to deck if due', () async {
      final db = createTestDatabase();

      try {
        final container = ProviderContainer(
          overrides: createTestProviderOverridesWithDb(db),
        );

        final contactRepo = container.read(contactRepositoryProvider);
        final contact = await contactRepo.create(name: 'Clear Snooze Test', cadenceDays: 1);

        // Make contact due and snoozed
        await contactRepo.update(
          contact.id,
          lastContactedAt: DateTime.now().subtract(const Duration(days: 5)),
        );
        await contactRepo.snooze(contact.id, DateTime.now().add(const Duration(days: 7)));

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should NOT be in deck (snoozed)
        var dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts.any((c) => c.id == contact.id), isFalse);

        // Clear snooze
        final notifier = container.read(dailyDeckNotifierProvider.notifier);
        await notifier.clearSnooze(contact.id);

        // Should now be in deck
        await Future<void>.delayed(const Duration(milliseconds: 100));
        dueContacts = await container.read(dailyDeckProvider.future);
        expect(dueContacts.any((c) => c.id == contact.id), isTrue);

        container.dispose();
      } finally {
        await db.close();
      }
    });
  });

  group('snoozePresetsProvider', () {
    test('provides default snooze presets', () {
      final container = ProviderContainer();
      final presets = container.read(snoozePresetsProvider);

      expect(presets, isNotEmpty);
      expect(presets.any((p) => p.label == 'Tomorrow'), isTrue);
      expect(presets.any((p) => p.label == '1 week'), isTrue);
      expect(presets.any((p) => p.label == '1 month'), isTrue);

      container.dispose();
    });

    test('SnoozePreset calculates correct until date', () {
      final preset = SnoozePreset(days: 7, label: '1 week');
      final until = preset.until;
      final expectedDate = DateTime.now().add(const Duration(days: 7));

      expect(until.day, expectedDate.day);
      expect(until.month, expectedDate.month);
      expect(until.year, expectedDate.year);
    });
  });
}

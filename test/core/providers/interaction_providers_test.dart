import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kin/core/providers/providers.dart';
import 'package:kin/data/database/database.dart';
import 'package:kin/data/database/tables/interactions.dart';

void main() {
  late ProviderContainer container;
  late AppDatabase testDb;
  late String testContactId;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    testDb = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(testDb),
      ],
    );

    // Create a test contact for interactions
    final contactNotifier = container.read(contactNotifierProvider.notifier);
    final contact = await contactNotifier.create(name: 'Test Contact');
    testContactId = contact.id;
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  group('interactionsProvider', () {
    test('emits empty list initially', () async {
      final stream = container.read(interactionsProvider.stream);
      final interactions = await stream.first;
      expect(interactions, isEmpty);
    });

    test('emits interactions after creation', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final interactions = await container.read(interactionsProvider.future);
      expect(interactions.length, equals(1));
      expect(interactions.first.type, equals('call'));
    });
  });

  group('interactionsForContactProvider', () {
    test('returns empty list for contact with no interactions', () async {
      final stream =
          container.read(interactionsForContactProvider(testContactId).stream);
      final interactions = await stream.first;
      expect(interactions, isEmpty);
    });

    test('returns only interactions for specified contact', () async {
      // Create another contact
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final otherContact = await contactNotifier.create(name: 'Other Contact');

      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );
      await notifier.create(
        contactId: otherContact.id,
        type: InteractionType.meetup,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final interactions = await container
          .read(interactionsForContactProvider(testContactId).future);
      expect(interactions.length, equals(1));
      expect(interactions.first.type, equals('call'));
    });
  });

  group('InteractionNotifier', () {
    test('create creates interaction with required fields', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      final interaction = await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      expect(interaction.contactId, equals(testContactId));
      expect(interaction.type, equals('call'));
      expect(interaction.id, isNotEmpty);
      expect(interaction.isPreparation, isFalse);
    });

    test('create creates interaction with all optional fields', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      final happenedAt = DateTime(2024, 6, 15, 10, 30);

      final interaction = await notifier.create(
        contactId: testContactId,
        type: InteractionType.meetup,
        content: 'Had coffee together',
        isPreparation: true,
        happenedAt: happenedAt,
      );

      expect(interaction.contactId, equals(testContactId));
      expect(interaction.type, equals('meetup'));
      expect(interaction.content, equals('Had coffee together'));
      expect(interaction.isPreparation, isTrue);
      expect(
        interaction.happenedAt,
        equals(happenedAt.millisecondsSinceEpoch ~/ 1000),
      );
    });

    test('update modifies interaction fields', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      final interaction = await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        content: 'Original content',
      );

      final updated = await notifier.update(
        interaction.id,
        contactId: testContactId,
        type: InteractionType.message,
        content: 'Updated content',
      );

      expect(updated.type, equals('message'));
      expect(updated.content, equals('Updated content'));
    });

    test('delete soft deletes interaction', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      final interaction = await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      await notifier.delete(interaction.id, contactId: testContactId);

      final result =
          await container.read(interactionProvider(interaction.id).future);
      expect(result, isNull); // Soft deleted interactions return null
    });
  });

  group('last_contacted_at update', () {
    test('creating non-prep interaction updates contact last_contacted_at',
        () async {
      // Verify contact has no last_contacted_at initially
      final contactBefore =
          await container.read(contactProvider(testContactId).future);
      expect(contactBefore!.lastContactedAt, isNull);

      // Create a non-preparation interaction
      final notifier = container.read(interactionNotifierProvider.notifier);
      final happenedAt = DateTime(2024, 6, 15, 10, 30);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        isPreparation: false,
        happenedAt: happenedAt,
      );

      // Verify contact's last_contacted_at is updated
      await Future.delayed(const Duration(milliseconds: 50));
      container.invalidate(contactProvider(testContactId));
      final contactAfter =
          await container.read(contactProvider(testContactId).future);
      expect(contactAfter!.lastContactedAt, isNotNull);
      expect(
        contactAfter.lastContactedAt,
        equals(happenedAt.millisecondsSinceEpoch ~/ 1000),
      );
    });

    test('creating prep interaction does NOT update contact last_contacted_at',
        () async {
      // Verify contact has no last_contacted_at initially
      final contactBefore =
          await container.read(contactProvider(testContactId).future);
      expect(contactBefore!.lastContactedAt, isNull);

      // Create a preparation interaction
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        isPreparation: true,
      );

      // Verify contact's last_contacted_at is still null
      await Future.delayed(const Duration(milliseconds: 50));
      container.invalidate(contactProvider(testContactId));
      final contactAfter =
          await container.read(contactProvider(testContactId).future);
      expect(contactAfter!.lastContactedAt, isNull);
    });

    test('updating interaction to non-prep updates contact last_contacted_at',
        () async {
      // Create a prep interaction first
      final notifier = container.read(interactionNotifierProvider.notifier);
      final happenedAt = DateTime(2024, 6, 15, 10, 30);
      final interaction = await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        isPreparation: true,
        happenedAt: happenedAt,
      );

      // Verify contact has no last_contacted_at
      final contactBefore =
          await container.read(contactProvider(testContactId).future);
      expect(contactBefore!.lastContactedAt, isNull);

      // Update interaction to non-prep
      await notifier.update(
        interaction.id,
        contactId: testContactId,
        isPreparation: false,
      );

      // Verify contact's last_contacted_at is now updated
      await Future.delayed(const Duration(milliseconds: 50));
      container.invalidate(contactProvider(testContactId));
      final contactAfter =
          await container.read(contactProvider(testContactId).future);
      expect(contactAfter!.lastContactedAt, isNotNull);
      expect(
        contactAfter.lastContactedAt,
        equals(happenedAt.millisecondsSinceEpoch ~/ 1000),
      );
    });
  });

  group('preparationNotesProvider', () {
    test('returns only preparation interactions', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);

      // Create both prep and non-prep interactions
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        isPreparation: false,
        content: 'Regular call',
      );
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        isPreparation: true,
        content: 'Prep notes',
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final prepNotes =
          await container.read(preparationNotesProvider(testContactId).future);

      expect(prepNotes.length, equals(1));
      expect(prepNotes.first.content, equals('Prep notes'));
      expect(prepNotes.first.isPreparation, isTrue);
    });
  });

  group('interactionSearchProvider', () {
    test('returns empty list for empty query', () async {
      final results =
          await container.read(interactionSearchProvider('').future);
      expect(results, isEmpty);
    });

    test('finds interactions matching content', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        content: 'Discussed project timeline',
      );
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.meetup,
        content: 'Coffee chat',
      );

      final results =
          await container.read(interactionSearchProvider('project').future);
      expect(results.length, equals(1));
      expect(results.first.content, contains('project'));
    });
  });

  group('interactionsByTypeProvider', () {
    test('returns only interactions of specified type', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.meetup,
      );
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      final calls = await container
          .read(interactionsByTypeProvider(InteractionType.call).future);
      expect(calls.length, equals(2));
      expect(calls.every((i) => i.type == 'call'), isTrue);
    });
  });
}

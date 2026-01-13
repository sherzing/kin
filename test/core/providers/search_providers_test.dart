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

    // Create a test contact
    final contactNotifier = container.read(contactNotifierProvider.notifier);
    final contact = await contactNotifier.create(name: 'Test Contact');
    testContactId = contact.id;
  });

  tearDown(() async {
    container.dispose();
    await testDb.close();
  });

  group('searchQueryProvider', () {
    test('initial value is empty string', () {
      final query = container.read(searchQueryProvider);
      expect(query, equals(''));
    });

    test('can update query', () {
      container.read(searchQueryProvider.notifier).state = 'test query';
      final query = container.read(searchQueryProvider);
      expect(query, equals('test query'));
    });
  });

  group('SearchResults', () {
    test('isEmpty returns true when all lists are empty', () {
      const results = SearchResults();
      expect(results.isEmpty, isTrue);
    });

    test('isEmpty returns false when contacts has items', () {
      final results = SearchResults(contacts: [
        Contact(
          id: '1',
          name: 'Test',
          cadenceDays: 30,
          createdAt: 0,
          updatedAt: 0,
          isDirty: false,
        ),
      ]);
      expect(results.isEmpty, isFalse);
    });

    test('totalCount returns sum of all lists', () {
      final results = SearchResults(
        contacts: [
          Contact(
            id: '1',
            name: 'Test',
            cadenceDays: 30,
            createdAt: 0,
            updatedAt: 0,
            isDirty: false,
          ),
        ],
        circles: [
          Circle(
            id: '1',
            name: 'Circle',
            createdAt: 0,
            updatedAt: 0,
            isDirty: false,
          ),
        ],
      );
      expect(results.totalCount, equals(2));
    });
  });

  group('searchResultsProvider', () {
    test('returns empty for empty query', () async {
      container.read(searchQueryProvider.notifier).state = '';
      final results = await container.read(searchResultsProvider.future);
      expect(results.isEmpty, isTrue);
    });

    test('returns empty for query shorter than 2 characters', () async {
      container.read(searchQueryProvider.notifier).state = 'a';
      final results = await container.read(searchResultsProvider.future);
      expect(results.isEmpty, isTrue);
    });

    test('finds contacts by name', () async {
      container.read(searchQueryProvider.notifier).state = 'Test';

      await Future.delayed(const Duration(milliseconds: 50));
      final results = await container.read(searchResultsProvider.future);

      expect(results.contacts.length, equals(1));
      expect(results.contacts.first.name, equals('Test Contact'));
    });

    test('finds interactions by content', () async {
      // Create an interaction with searchable content
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        content: 'Discussed important project details',
      );

      container.read(searchQueryProvider.notifier).state = 'project';

      await Future.delayed(const Duration(milliseconds: 50));
      final results = await container.read(searchResultsProvider.future);

      expect(results.interactions.length, equals(1));
      expect(results.interactions.first.content, contains('project'));
    });

    test('finds circles by name', () async {
      // Create a circle
      final circleNotifier = container.read(circleNotifierProvider.notifier);
      await circleNotifier.create(name: 'Family Circle');

      container.read(searchQueryProvider.notifier).state = 'Family';

      await Future.delayed(const Duration(milliseconds: 50));
      final results = await container.read(searchResultsProvider.future);

      expect(results.circles.length, equals(1));
      expect(results.circles.first.name, equals('Family Circle'));
    });

    test('finds results across all entity types', () async {
      // Create matching data for all types
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      await contactNotifier.create(name: 'Alpha Person');

      final interactionNotifier =
          container.read(interactionNotifierProvider.notifier);
      await interactionNotifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        content: 'Alpha meeting notes',
      );

      final circleNotifier = container.read(circleNotifierProvider.notifier);
      await circleNotifier.create(name: 'Alpha Team');

      container.read(searchQueryProvider.notifier).state = 'Alpha';

      await Future.delayed(const Duration(milliseconds: 50));
      final results = await container.read(searchResultsProvider.future);

      expect(results.contacts.length, equals(1));
      expect(results.interactions.length, equals(1));
      expect(results.circles.length, equals(1));
      expect(results.totalCount, equals(3));
    });

    test('search is case-insensitive', () async {
      container.read(searchQueryProvider.notifier).state = 'test';

      await Future.delayed(const Duration(milliseconds: 50));
      final results = await container.read(searchResultsProvider.future);

      expect(results.contacts.length, equals(1));
      expect(results.contacts.first.name, equals('Test Contact'));
    });
  });

  group('timelineProvider', () {
    test('returns empty list when no interactions exist', () async {
      final interactions = await container.read(timelineProvider.future);
      expect(interactions, isEmpty);
    });

    test('returns all interactions sorted by happenedAt descending', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);

      final older = DateTime(2024, 1, 1);
      final newer = DateTime(2024, 6, 1);

      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        happenedAt: older,
      );
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.meetup,
        happenedAt: newer,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final interactions = await container.read(timelineProvider.future);

      expect(interactions.length, equals(2));
      // Newer should be first
      expect(interactions.first.type, equals('meetup'));
      expect(interactions.last.type, equals('call'));
    });

    test('includes interactions from all contacts', () async {
      // Create another contact
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final otherContact = await contactNotifier.create(name: 'Other Person');

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
      final interactions = await container.read(timelineProvider.future);

      expect(interactions.length, equals(2));
    });
  });

  group('filteredTimelineProvider', () {
    test('returns all interactions when contactId is null', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final interactions =
          await container.read(filteredTimelineProvider(null).future);

      expect(interactions.length, equals(1));
    });

    test('returns only interactions for specified contact', () async {
      final contactNotifier = container.read(contactNotifierProvider.notifier);
      final otherContact = await contactNotifier.create(name: 'Other Person');

      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        content: 'Test interaction',
      );
      await notifier.create(
        contactId: otherContact.id,
        type: InteractionType.meetup,
        content: 'Other interaction',
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final interactions =
          await container.read(filteredTimelineProvider(testContactId).future);

      expect(interactions.length, equals(1));
      expect(interactions.first.content, equals('Test interaction'));
    });
  });

  group('TimelinePagination', () {
    test('pageSize is 20', () {
      expect(TimelinePagination.pageSize, equals(20));
    });

    test('empty has correct initial values', () {
      expect(TimelinePagination.empty.interactions, isEmpty);
      expect(TimelinePagination.empty.hasMore, isFalse);
      expect(TimelinePagination.empty.currentPage, equals(0));
    });
  });

  group('TimelinePaginationNotifier', () {
    test('initial state is empty', () {
      final state = container.read(timelinePaginationProvider);
      expect(state.interactions, isEmpty);
      expect(state.currentPage, equals(0));
    });

    test('loadNextPage loads interactions', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      await container
          .read(timelinePaginationProvider.notifier)
          .loadNextPage();

      final state = container.read(timelinePaginationProvider);
      expect(state.interactions.length, equals(1));
      expect(state.currentPage, equals(1));
    });

    test('reset clears state', () async {
      final notifier = container.read(interactionNotifierProvider.notifier);
      await notifier.create(
        contactId: testContactId,
        type: InteractionType.call,
      );

      await container
          .read(timelinePaginationProvider.notifier)
          .loadNextPage();
      container.read(timelinePaginationProvider.notifier).reset();

      final state = container.read(timelinePaginationProvider);
      expect(state.interactions, isEmpty);
      expect(state.currentPage, equals(0));
    });
  });

  group('SearchResultItem', () {
    test('fromContact creates correct item', () {
      final contact = Contact(
        id: 'c1',
        name: 'John Doe',
        phone: '555-1234',
        cadenceDays: 30,
        createdAt: 0,
        updatedAt: 0,
        isDirty: false,
      );

      final item = SearchResultItem.fromContact(contact);

      expect(item.type, equals(SearchResultType.contact));
      expect(item.id, equals('c1'));
      expect(item.title, equals('John Doe'));
      expect(item.subtitle, equals('555-1234'));
    });

    test('fromInteraction creates correct item', () {
      final interaction = Interaction(
        id: 'i1',
        contactId: 'c1',
        type: 'call',
        content: 'Discussion notes',
        happenedAt: 0,
        isPreparation: false,
        createdAt: 0,
        updatedAt: 0,
        isDirty: false,
      );

      final item = SearchResultItem.fromInteraction(interaction);

      expect(item.type, equals(SearchResultType.interaction));
      expect(item.id, equals('i1'));
      expect(item.title, equals('Call'));
      expect(item.subtitle, equals('Discussion notes'));
    });

    test('fromCircle creates correct item', () {
      final circle = Circle(
        id: 'circle1',
        name: 'Work Team',
        colorHex: '#FF0000',
        createdAt: 0,
        updatedAt: 0,
        isDirty: false,
      );

      final item = SearchResultItem.fromCircle(circle);

      expect(item.type, equals(SearchResultType.circle));
      expect(item.id, equals('circle1'));
      expect(item.title, equals('Work Team'));
      expect(item.metadata?['colorHex'], equals('#FF0000'));
    });
  });

  group('flatSearchResultsProvider', () {
    test('returns empty list when no results', () {
      container.read(searchQueryProvider.notifier).state = '';
      final items = container.read(flatSearchResultsProvider);
      expect(items, isEmpty);
    });

    test('flattens results from all types', () async {
      // Create data
      final circleNotifier = container.read(circleNotifierProvider.notifier);
      await circleNotifier.create(name: 'Alpha Circle');

      final interactionNotifier =
          container.read(interactionNotifierProvider.notifier);
      await interactionNotifier.create(
        contactId: testContactId,
        type: InteractionType.call,
        content: 'Alpha notes',
      );

      // Also have the Test Contact which doesn't match "Alpha"
      container.read(searchQueryProvider.notifier).state = 'Alpha';

      await Future.delayed(const Duration(milliseconds: 100));
      // Need to refresh the async provider
      container.invalidate(searchResultsProvider);
      await container.read(searchResultsProvider.future);

      final items = container.read(flatSearchResultsProvider);

      // Should have 1 interaction + 1 circle (Test Contact doesn't match Alpha)
      expect(items.length, equals(2));
    });
  });
}

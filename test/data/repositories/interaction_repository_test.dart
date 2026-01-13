import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/database/database.dart';
import 'package:kin/data/database/tables/interactions.dart';
import 'package:kin/data/repositories/contact_repository.dart';
import 'package:kin/data/repositories/interaction_repository.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late InteractionRepository interactionRepo;
  late ContactRepository contactRepo;

  setUp(() {
    db = createTestDatabase();
    interactionRepo = InteractionRepository(db);
    contactRepo = ContactRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('InteractionRepository', () {
    group('create', () {
      test('creates an interaction with required fields', () async {
        final contact = await contactRepo.create(name: 'John');
        final interaction = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );

        expect(interaction.contactId, equals(contact.id));
        expect(interaction.type, equals('call'));
        expect(interaction.id, isNotEmpty);
        expect(interaction.isDirty, isTrue);
      });

      test('creates an interaction with content', () async {
        final contact = await contactRepo.create(name: 'Jane');
        final interaction = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.meetup,
          content: '# Meeting Notes\n\nDiscussed project timeline.',
        );

        expect(interaction.content, contains('Meeting Notes'));
      });

      test('creates a preparation note', () async {
        final contact = await contactRepo.create(name: 'Bob');
        final interaction = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          content: 'Remember to ask about the birthday party',
          isPreparation: true,
        );

        expect(interaction.isPreparation, isTrue);
      });

      test('creates with custom happenedAt date', () async {
        final contact = await contactRepo.create(name: 'Alice');
        final pastDate = DateTime.now().subtract(const Duration(days: 7));
        final interaction = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.email,
          happenedAt: pastDate,
        );

        expect(interaction.happenedAt, isNotNull);
      });
    });

    group('getById', () {
      test('returns interaction when exists', () async {
        final contact = await contactRepo.create(name: 'Test');
        final created = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.message,
        );

        final found = await interactionRepo.getById(created.id);

        expect(found, isNotNull);
        expect(found!.id, equals(created.id));
      });

      test('returns null when not exists', () async {
        final found = await interactionRepo.getById('non-existent');
        expect(found, isNull);
      });
    });

    group('getForContact', () {
      test('returns interactions for contact', () async {
        final contact = await contactRepo.create(name: 'John');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.message,
        );

        final interactions = await interactionRepo.getForContact(contact.id);

        expect(interactions, hasLength(2));
      });

      test('does not return other contacts interactions', () async {
        final contact1 = await contactRepo.create(name: 'John');
        final contact2 = await contactRepo.create(name: 'Jane');
        await interactionRepo.create(
          contactId: contact1.id,
          type: InteractionType.call,
        );
        await interactionRepo.create(
          contactId: contact2.id,
          type: InteractionType.call,
        );

        final interactions = await interactionRepo.getForContact(contact1.id);

        expect(interactions, hasLength(1));
      });
    });

    group('getPreparationNotes', () {
      test('returns only preparation notes', () async {
        final contact = await contactRepo.create(name: 'Test');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          isPreparation: true,
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          isPreparation: false,
        );

        final notes = await interactionRepo.getPreparationNotes(contact.id);

        expect(notes, hasLength(1));
        expect(notes[0].isPreparation, isTrue);
      });
    });

    group('getReflections', () {
      test('returns only reflections', () async {
        final contact = await contactRepo.create(name: 'Test');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          isPreparation: true,
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.meetup,
          isPreparation: false,
        );

        final reflections = await interactionRepo.getReflections(contact.id);

        expect(reflections, hasLength(1));
        expect(reflections[0].isPreparation, isFalse);
      });
    });

    group('update', () {
      test('updates interaction content', () async {
        final contact = await contactRepo.create(name: 'Test');
        final created = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          content: 'Original',
        );

        final updated = await interactionRepo.update(
          created.id,
          content: 'Updated content',
        );

        expect(updated.content, equals('Updated content'));
      });

      test('updates interaction type', () async {
        final contact = await contactRepo.create(name: 'Test');
        final created = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );

        final updated = await interactionRepo.update(
          created.id,
          type: InteractionType.meetup,
        );

        expect(updated.type, equals('meetup'));
      });
    });

    group('delete', () {
      test('soft deletes interaction', () async {
        final contact = await contactRepo.create(name: 'Test');
        final created = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );

        await interactionRepo.delete(created.id);

        final interactions = await interactionRepo.getForContact(contact.id);
        expect(interactions, isEmpty);
      });
    });

    group('search', () {
      test('finds interactions by content', () async {
        final contact = await contactRepo.create(name: 'Test');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          content: 'Discussed the project deadline',
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.message,
          content: 'Birthday wishes',
        );

        final results = await interactionRepo.search('project');

        expect(results, hasLength(1));
        expect(results[0].content, contains('project'));
      });
    });

    group('getByType', () {
      test('filters by interaction type', () async {
        final contact = await contactRepo.create(name: 'Test');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.meetup,
        );
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );

        final calls = await interactionRepo.getByType(InteractionType.call);

        expect(calls, hasLength(2));
      });
    });

    group('getMostRecent', () {
      test('returns most recent interaction for contact', () async {
        final contact = await contactRepo.create(name: 'Test');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
          happenedAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final recent = await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.message,
          happenedAt: DateTime.now(),
        );

        final mostRecent = await interactionRepo.getMostRecent(contact.id);

        expect(mostRecent, isNotNull);
        expect(mostRecent!.id, equals(recent.id));
      });

      test('returns null when no interactions', () async {
        final contact = await contactRepo.create(name: 'Test');
        final mostRecent = await interactionRepo.getMostRecent(contact.id);

        expect(mostRecent, isNull);
      });
    });

    group('watchForContact', () {
      test('emits interactions on changes', () async {
        final contact = await contactRepo.create(name: 'Test');
        await interactionRepo.create(
          contactId: contact.id,
          type: InteractionType.call,
        );

        expect(
          interactionRepo.watchForContact(contact.id),
          emitsInOrder([
            predicate<List<Interaction>>((list) => list.length == 1),
          ]),
        );
      });
    });
  });
}

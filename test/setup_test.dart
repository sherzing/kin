import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kin/data/database/database.dart';

import 'helpers/test_helpers.dart';

void main() {
  group('Project Setup', () {
    group('Folder Structure', () {
      test('lib/data directory exists', () {
        expect(Directory('lib/data').existsSync(), isTrue);
      });

      test('lib/data/models directory exists', () {
        expect(Directory('lib/data/models').existsSync(), isTrue);
      });

      test('lib/data/database directory exists', () {
        expect(Directory('lib/data/database').existsSync(), isTrue);
      });

      test('lib/data/repositories directory exists', () {
        expect(Directory('lib/data/repositories').existsSync(), isTrue);
      });

      test('lib/domain/providers directory exists', () {
        expect(Directory('lib/domain/providers').existsSync(), isTrue);
      });

      test('lib/presentation/screens directory exists', () {
        expect(Directory('lib/presentation/screens').existsSync(), isTrue);
      });

      test('lib/presentation/widgets directory exists', () {
        expect(Directory('lib/presentation/widgets').existsSync(), isTrue);
      });

      test('lib/core/constants directory exists', () {
        expect(Directory('lib/core/constants').existsSync(), isTrue);
      });

      test('lib/core/theme directory exists', () {
        expect(Directory('lib/core/theme').existsSync(), isTrue);
      });
    });

    group('Generated Code', () {
      test('database.g.dart exists', () {
        expect(File('lib/data/database/database.g.dart').existsSync(), isTrue);
      });
    });

    group('Database', () {
      late AppDatabase db;

      setUp(() {
        db = createTestDatabase();
      });

      tearDown(() async {
        await db.close();
      });

      test('can create in-memory database', () {
        expect(db, isNotNull);
      });

      test('database schema version is 1', () {
        expect(db.schemaVersion, equals(1));
      });
    });
  });
}

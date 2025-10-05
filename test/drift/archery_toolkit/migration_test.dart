// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:archery_toolkit/db/db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldSessionsData = <v1.SessionsData>[];
    final expectedNewSessionsData = <v2.SessionsData>[];

    final oldArrowScoresData = <v1.ArrowScoresData>[];
    final expectedNewArrowScoresData = <v2.ArrowScoresData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.sessions, oldSessionsData);
        batch.insertAll(oldDb.arrowScores, oldArrowScoresData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewSessionsData,
          await newDb.select(newDb.sessions).get(),
        );
        expect(
          expectedNewArrowScoresData,
          await newDb.select(newDb.arrowScores).get(),
        );
      },
    );
  });

  test('migration from v2 to v3 does not corrupt data', () async {
    final startTime = DateTime(2025);
    final oldSessionsData = <v2.SessionsData>[
      v2.SessionsData(
        id: 1,
        startTime: startTime,
        arrowsPerEnd: 6,
        distance: 30,
        distanceUnit: 'metres',
        scoringSystem: 'metric',
      ),
    ];
    final expectedNewSessionsData = <v3.SessionsData>[
      v3.SessionsData(
        id: 1,
        startTime: startTime,
        arrowsPerEnd: 6,
        distance: 30,
        distanceUnit: 'metres',
        scoringSystem: 'metric',
        isCompetition: false,
      ),
    ];

    final oldArrowScoresData = <v1.ArrowScoresData>[];
    final expectedNewArrowScoresData = <v2.ArrowScoresData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.sessions, oldSessionsData);
        batch.insertAll(oldDb.arrowScores, oldArrowScoresData);
      },
      validateItems: (newDb) async {
        expect(
          await newDb.select(newDb.sessions).get(),
          expectedNewSessionsData,
        );
        expect(
          await newDb.select(newDb.arrowScores).get(),
          expectedNewArrowScoresData,
        );
      },
    );
  });

  test('migration from v3 to v4 does not corrupt data', () async {
    final startTime = DateTime(2025);
    final oldSessionsData = <v3.SessionsData>[
      v3.SessionsData(
        id: 1,
        startTime: startTime,
        arrowsPerEnd: 6,
        distance: 30,
        distanceUnit: 'metres',
        scoringSystem: 'metric',
        isCompetition: false,
      ),
      v3.SessionsData(
        id: 2,
        startTime: startTime,
        arrowsPerEnd: null,
        distance: 30,
        distanceUnit: 'metres',
        scoringSystem: 'metric',
        isCompetition: false,
      ),
    ];
    final expectedNewSessionsData = <v4.SessionsData>[
      v4.SessionsData(
        id: 1,
        startTime: startTime,
        arrowsPerEnd: '6',
        distance: 30,
        distanceUnit: 'metres',
        scoringSystem: 'metric',
        isCompetition: false,
      ),
      v4.SessionsData(
        id: 2,
        startTime: startTime,
        arrowsPerEnd: '',
        distance: 30,
        distanceUnit: 'metres',
        scoringSystem: 'metric',
        isCompetition: false,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.sessions, oldSessionsData);
      },
      validateItems: (newDb) async {
        expect(
          await newDb.select(newDb.sessions).get(),
          expectedNewSessionsData,
        );
      },
    );
  });
}

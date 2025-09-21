import 'package:archery_toolkit/db/db.steps.dart';
import 'package:drift/drift.dart';
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'db.g.dart';

@DriftDatabase(tables: [Sessions, ArrowScores])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() {
    return AppDatabase(driftDatabase(name: 'archery_toolkit'));
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Following the advice from https://drift.simonbinder.eu/Migrations/api/#general-tips
      await customStatement('PRAGMA foreign_keys = OFF');

      await transaction(
        () => VersionedSchema.runMigrationSteps(
          migrator: m,
          from: from,
          to: to,
          steps: _upgrade,
        ),
      );

      if (kDebugMode) {
        final wrongForeignKeys = await customSelect(
          'PRAGMA foreign_key_check',
        ).get();
        assert(
          wrongForeignKeys.isEmpty,
          '${wrongForeignKeys.map((e) => e.data)}',
        );
      }

      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

extension Migrations on GeneratedDatabase {
  MigrationStepWithVersion get _upgrade => migrationSteps(
    from1To2: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.sessions,
          newColumns: [schema.sessions.scoringSystem],
          columnTransformer: {
            schema.sessions.scoringSystem: Constant('metric'),
          },
        ),
      );
    },
  );
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime().withDefault(currentDateAndTime)();
  IntColumn get arrowsPerEnd => integer()();
  IntColumn get distance => integer()();
  TextColumn get distanceUnit => text()();
  TextColumn get scoringSystem => text()();
}

class ArrowScores extends Table {
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get index => integer()();
  IntColumn get scoreId => integer()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>>? get primaryKey => {sessionId, index};

  @override
  bool get withoutRowId => true;
}

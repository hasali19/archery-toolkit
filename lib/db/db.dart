import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

@DriftDatabase(tables: [Sessions, ArrowScores])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.open() {
    return AppDatabase(driftDatabase(name: 'archery_toolkit'));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime().withDefault(currentDateAndTime)();
  IntColumn get arrowsPerEnd => integer()();
  IntColumn get distance => integer()();
  TextColumn get distanceUnit => text()();
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

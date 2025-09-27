// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Sessions extends Table with TableInfo<Sessions, SessionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Sessions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> arrowsPerEnd = GeneratedColumn<int>(
    'arrows_per_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> distance = GeneratedColumn<int>(
    'distance',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> distanceUnit = GeneratedColumn<String>(
    'distance_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> scoringSystem = GeneratedColumn<String>(
    'scoring_system',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<bool> isCompetition = GeneratedColumn<bool>(
    'is_competition',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_competition" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    roundId,
    arrowsPerEnd,
    distance,
    distanceUnit,
    scoringSystem,
    isCompetition,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionsData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      ),
      arrowsPerEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arrows_per_end'],
      ),
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance'],
      ),
      distanceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_unit'],
      ),
      scoringSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scoring_system'],
      ),
      isCompetition: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_competition'],
      )!,
    );
  }

  @override
  Sessions createAlias(String alias) {
    return Sessions(attachedDatabase, alias);
  }
}

class SessionsData extends DataClass implements Insertable<SessionsData> {
  final int id;
  final DateTime startTime;
  final String? roundId;
  final int? arrowsPerEnd;
  final int? distance;
  final String? distanceUnit;
  final String? scoringSystem;
  final bool isCompetition;
  const SessionsData({
    required this.id,
    required this.startTime,
    this.roundId,
    this.arrowsPerEnd,
    this.distance,
    this.distanceUnit,
    this.scoringSystem,
    required this.isCompetition,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || roundId != null) {
      map['round_id'] = Variable<String>(roundId);
    }
    if (!nullToAbsent || arrowsPerEnd != null) {
      map['arrows_per_end'] = Variable<int>(arrowsPerEnd);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<int>(distance);
    }
    if (!nullToAbsent || distanceUnit != null) {
      map['distance_unit'] = Variable<String>(distanceUnit);
    }
    if (!nullToAbsent || scoringSystem != null) {
      map['scoring_system'] = Variable<String>(scoringSystem);
    }
    map['is_competition'] = Variable<bool>(isCompetition);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      roundId: roundId == null && nullToAbsent
          ? const Value.absent()
          : Value(roundId),
      arrowsPerEnd: arrowsPerEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(arrowsPerEnd),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      distanceUnit: distanceUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceUnit),
      scoringSystem: scoringSystem == null && nullToAbsent
          ? const Value.absent()
          : Value(scoringSystem),
      isCompetition: Value(isCompetition),
    );
  }

  factory SessionsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionsData(
      id: serializer.fromJson<int>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      roundId: serializer.fromJson<String?>(json['roundId']),
      arrowsPerEnd: serializer.fromJson<int?>(json['arrowsPerEnd']),
      distance: serializer.fromJson<int?>(json['distance']),
      distanceUnit: serializer.fromJson<String?>(json['distanceUnit']),
      scoringSystem: serializer.fromJson<String?>(json['scoringSystem']),
      isCompetition: serializer.fromJson<bool>(json['isCompetition']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'roundId': serializer.toJson<String?>(roundId),
      'arrowsPerEnd': serializer.toJson<int?>(arrowsPerEnd),
      'distance': serializer.toJson<int?>(distance),
      'distanceUnit': serializer.toJson<String?>(distanceUnit),
      'scoringSystem': serializer.toJson<String?>(scoringSystem),
      'isCompetition': serializer.toJson<bool>(isCompetition),
    };
  }

  SessionsData copyWith({
    int? id,
    DateTime? startTime,
    Value<String?> roundId = const Value.absent(),
    Value<int?> arrowsPerEnd = const Value.absent(),
    Value<int?> distance = const Value.absent(),
    Value<String?> distanceUnit = const Value.absent(),
    Value<String?> scoringSystem = const Value.absent(),
    bool? isCompetition,
  }) => SessionsData(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    roundId: roundId.present ? roundId.value : this.roundId,
    arrowsPerEnd: arrowsPerEnd.present ? arrowsPerEnd.value : this.arrowsPerEnd,
    distance: distance.present ? distance.value : this.distance,
    distanceUnit: distanceUnit.present ? distanceUnit.value : this.distanceUnit,
    scoringSystem: scoringSystem.present
        ? scoringSystem.value
        : this.scoringSystem,
    isCompetition: isCompetition ?? this.isCompetition,
  );
  SessionsData copyWithCompanion(SessionsCompanion data) {
    return SessionsData(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      arrowsPerEnd: data.arrowsPerEnd.present
          ? data.arrowsPerEnd.value
          : this.arrowsPerEnd,
      distance: data.distance.present ? data.distance.value : this.distance,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      scoringSystem: data.scoringSystem.present
          ? data.scoringSystem.value
          : this.scoringSystem,
      isCompetition: data.isCompetition.present
          ? data.isCompetition.value
          : this.isCompetition,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionsData(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('roundId: $roundId, ')
          ..write('arrowsPerEnd: $arrowsPerEnd, ')
          ..write('distance: $distance, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('scoringSystem: $scoringSystem, ')
          ..write('isCompetition: $isCompetition')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    roundId,
    arrowsPerEnd,
    distance,
    distanceUnit,
    scoringSystem,
    isCompetition,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionsData &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.roundId == this.roundId &&
          other.arrowsPerEnd == this.arrowsPerEnd &&
          other.distance == this.distance &&
          other.distanceUnit == this.distanceUnit &&
          other.scoringSystem == this.scoringSystem &&
          other.isCompetition == this.isCompetition);
}

class SessionsCompanion extends UpdateCompanion<SessionsData> {
  final Value<int> id;
  final Value<DateTime> startTime;
  final Value<String?> roundId;
  final Value<int?> arrowsPerEnd;
  final Value<int?> distance;
  final Value<String?> distanceUnit;
  final Value<String?> scoringSystem;
  final Value<bool> isCompetition;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.roundId = const Value.absent(),
    this.arrowsPerEnd = const Value.absent(),
    this.distance = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.scoringSystem = const Value.absent(),
    this.isCompetition = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.roundId = const Value.absent(),
    this.arrowsPerEnd = const Value.absent(),
    this.distance = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.scoringSystem = const Value.absent(),
    required bool isCompetition,
  }) : isCompetition = Value(isCompetition);
  static Insertable<SessionsData> custom({
    Expression<int>? id,
    Expression<DateTime>? startTime,
    Expression<String>? roundId,
    Expression<int>? arrowsPerEnd,
    Expression<int>? distance,
    Expression<String>? distanceUnit,
    Expression<String>? scoringSystem,
    Expression<bool>? isCompetition,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (roundId != null) 'round_id': roundId,
      if (arrowsPerEnd != null) 'arrows_per_end': arrowsPerEnd,
      if (distance != null) 'distance': distance,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (scoringSystem != null) 'scoring_system': scoringSystem,
      if (isCompetition != null) 'is_competition': isCompetition,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startTime,
    Value<String?>? roundId,
    Value<int?>? arrowsPerEnd,
    Value<int?>? distance,
    Value<String?>? distanceUnit,
    Value<String?>? scoringSystem,
    Value<bool>? isCompetition,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      roundId: roundId ?? this.roundId,
      arrowsPerEnd: arrowsPerEnd ?? this.arrowsPerEnd,
      distance: distance ?? this.distance,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      scoringSystem: scoringSystem ?? this.scoringSystem,
      isCompetition: isCompetition ?? this.isCompetition,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (arrowsPerEnd.present) {
      map['arrows_per_end'] = Variable<int>(arrowsPerEnd.value);
    }
    if (distance.present) {
      map['distance'] = Variable<int>(distance.value);
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(distanceUnit.value);
    }
    if (scoringSystem.present) {
      map['scoring_system'] = Variable<String>(scoringSystem.value);
    }
    if (isCompetition.present) {
      map['is_competition'] = Variable<bool>(isCompetition.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('roundId: $roundId, ')
          ..write('arrowsPerEnd: $arrowsPerEnd, ')
          ..write('distance: $distance, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('scoringSystem: $scoringSystem, ')
          ..write('isCompetition: $isCompetition')
          ..write(')'))
        .toString();
  }
}

class ArrowScores extends Table with TableInfo<ArrowScores, ArrowScoresData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ArrowScores(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> scoreId = GeneratedColumn<int>(
    'score_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression(
      'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [sessionId, index, scoreId, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'arrow_scores';
  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, index};
  @override
  ArrowScoresData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArrowScoresData(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      index: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index'],
      )!,
      scoreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  ArrowScores createAlias(String alias) {
    return ArrowScores(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class ArrowScoresData extends DataClass implements Insertable<ArrowScoresData> {
  final int sessionId;
  final int index;
  final int scoreId;
  final DateTime timestamp;
  const ArrowScoresData({
    required this.sessionId,
    required this.index,
    required this.scoreId,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<int>(sessionId);
    map['index'] = Variable<int>(index);
    map['score_id'] = Variable<int>(scoreId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ArrowScoresCompanion toCompanion(bool nullToAbsent) {
    return ArrowScoresCompanion(
      sessionId: Value(sessionId),
      index: Value(index),
      scoreId: Value(scoreId),
      timestamp: Value(timestamp),
    );
  }

  factory ArrowScoresData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArrowScoresData(
      sessionId: serializer.fromJson<int>(json['sessionId']),
      index: serializer.fromJson<int>(json['index']),
      scoreId: serializer.fromJson<int>(json['scoreId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<int>(sessionId),
      'index': serializer.toJson<int>(index),
      'scoreId': serializer.toJson<int>(scoreId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ArrowScoresData copyWith({
    int? sessionId,
    int? index,
    int? scoreId,
    DateTime? timestamp,
  }) => ArrowScoresData(
    sessionId: sessionId ?? this.sessionId,
    index: index ?? this.index,
    scoreId: scoreId ?? this.scoreId,
    timestamp: timestamp ?? this.timestamp,
  );
  ArrowScoresData copyWithCompanion(ArrowScoresCompanion data) {
    return ArrowScoresData(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      index: data.index.present ? data.index.value : this.index,
      scoreId: data.scoreId.present ? data.scoreId.value : this.scoreId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArrowScoresData(')
          ..write('sessionId: $sessionId, ')
          ..write('index: $index, ')
          ..write('scoreId: $scoreId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionId, index, scoreId, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArrowScoresData &&
          other.sessionId == this.sessionId &&
          other.index == this.index &&
          other.scoreId == this.scoreId &&
          other.timestamp == this.timestamp);
}

class ArrowScoresCompanion extends UpdateCompanion<ArrowScoresData> {
  final Value<int> sessionId;
  final Value<int> index;
  final Value<int> scoreId;
  final Value<DateTime> timestamp;
  const ArrowScoresCompanion({
    this.sessionId = const Value.absent(),
    this.index = const Value.absent(),
    this.scoreId = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ArrowScoresCompanion.insert({
    required int sessionId,
    required int index,
    required int scoreId,
    this.timestamp = const Value.absent(),
  }) : sessionId = Value(sessionId),
       index = Value(index),
       scoreId = Value(scoreId);
  static Insertable<ArrowScoresData> custom({
    Expression<int>? sessionId,
    Expression<int>? index,
    Expression<int>? scoreId,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (index != null) 'index': index,
      if (scoreId != null) 'score_id': scoreId,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ArrowScoresCompanion copyWith({
    Value<int>? sessionId,
    Value<int>? index,
    Value<int>? scoreId,
    Value<DateTime>? timestamp,
  }) {
    return ArrowScoresCompanion(
      sessionId: sessionId ?? this.sessionId,
      index: index ?? this.index,
      scoreId: scoreId ?? this.scoreId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (scoreId.present) {
      map['score_id'] = Variable<int>(scoreId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArrowScoresCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('index: $index, ')
          ..write('scoreId: $scoreId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV3 extends GeneratedDatabase {
  DatabaseAtV3(QueryExecutor e) : super(e);
  late final Sessions sessions = Sessions(this);
  late final ArrowScores arrowScores = ArrowScores(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions, arrowScores];
  @override
  int get schemaVersion => 3;
}

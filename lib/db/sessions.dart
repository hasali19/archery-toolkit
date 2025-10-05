import 'package:archery_toolkit/core/models.dart' show DistanceUnit;
import 'package:archery_toolkit/db/db.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:stream_transform/stream_transform.dart';

part 'sessions.g.dart';

final class NewSession {
  final String? roundId;
  final int? arrowsPerEnd;
  final int? distance;
  final DistanceUnit? distanceUnit;
  final String? scoringSystem;
  final bool isCompetition;

  const NewSession.round({
    required String this.roundId,
    required this.arrowsPerEnd,
    required this.isCompetition,
  }) : distance = null,
       distanceUnit = null,
       scoringSystem = null;

  const NewSession.freePractice({
    required int this.arrowsPerEnd,
    required int this.distance,
    required DistanceUnit this.distanceUnit,
    required String this.scoringSystem,
  }) : roundId = null,
       isCompetition = false;
}

@DriftAccessor(tables: [Sessions, ArrowScores])
class SessionsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.attachedDatabase);

  Future<({Session session, List<ArrowScore> scores})> getSessionWithScores(
    int sessionId,
  ) async {
    final sessionQuery = select(sessions)..where((s) => s.id.equals(sessionId));
    final session = await sessionQuery.getSingle();

    final scoresQuery = select(arrowScores)
      ..where((s) => s.sessionId.equals(sessionId))
      ..orderBy([(s) => OrderingTerm(expression: s.index)]);
    final scores = await scoresQuery.get();

    return (session: session, scores: scores);
  }

  Stream<Iterable<({Session session, List<ArrowScore> scores})>>
  watchSessionsWithScores() {
    final query = select(sessions)
      ..orderBy([(s) => OrderingTerm.desc(s.startTime)]);

    return query.watch().switchMap((sessions) {
      return select(arrowScores).watch().map((arrowScores) {
        final arrowScoresBySession = arrowScores.groupListsBy(
          (score) => score.sessionId,
        );

        return sessions.map(
          (session) => (
            session: session,
            scores: arrowScoresBySession[session.id] ?? [],
          ),
        );
      });
    });
  }

  Future<Session> insertSession(NewSession session) async {
    return await into(sessions).insertReturning(
      SessionsCompanion.insert(
        roundId: Value(session.roundId),
        arrowsPerEnd: session.arrowsPerEnd?.toString() ?? '',
        distance: Value(session.distance),
        distanceUnit: Value(session.distanceUnit),
        scoringSystem: Value(session.scoringSystem),
        isCompetition: session.isCompetition,
      ),
    );
  }

  Future<void> insertScore(int sessionId, int index, int scoreId) async {
    await into(arrowScores).insert(
      ArrowScoresCompanion.insert(
        sessionId: sessionId,
        index: index,
        scoreId: scoreId,
      ),
    );
  }

  Future<void> removeSession(int sessionId) async {
    final statement = delete(sessions)..where((s) => s.id.equals(sessionId));
    await statement.go();
  }

  Future<void> removeScore(int sessionId, int index) async {
    final query = db.delete(db.arrowScores)
      ..where((s) => s.sessionId.equals(sessionId) & s.index.equals(index));
    await query.go();
  }

  Future<void> updateSessionStartTime(int sessionId, DateTime startTime) async {
    final query = update(sessions)..where((s) => s.id.equals(sessionId));
    await query.write(SessionsCompanion(startTime: Value(startTime)));
  }
}

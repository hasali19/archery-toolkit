import 'package:archery_toolkit/core/models.dart';
import 'package:archery_toolkit/data/rounds.dart';
import 'package:archery_toolkit/data/scoring.dart';
import 'package:archery_toolkit/db/db.dart' as db;
import 'package:archery_toolkit/db/sessions.dart';

class SessionsRepo {
  final SessionsDao sessionsDao;

  SessionsRepo(this.sessionsDao);

  Future<Session> getSession(int sessionId) async {
    final (:session, :scores) = await sessionsDao.getSessionWithScores(
      sessionId,
    );
    return _mapDbToSession(session, scores);
  }

  Stream<Iterable<Session>> watchSessions() {
    return sessionsDao.watchSessionsWithScores().map(
      (sessionsWithScores) => sessionsWithScores.map((sessionWithScores) {
        final (:session, :scores) = sessionWithScores;
        return _mapDbToSession(session, scores);
      }),
    );
  }
}

Session _mapDbToSession(db.Session session, List<db.ArrowScore> scores) {
  final RoundDetails roundDetails;
  final arrowsPerEnds = session.arrowsPerEnd
      .split(',')
      .map((i) => int.tryParse(i));

  if (session.roundId case String roundId) {
    final round = standardRoundsById[roundId]!;

    int arrowsOffset = 0;
    int endsOffset = 0;

    final distances = <RoundDistance>[];
    for (final (distance, maybeArrowsPerEnd) in zip(
      round.distances,
      arrowsPerEnds,
    )) {
      final arrowsPerEnd = maybeArrowsPerEnd ?? distance.defaultArrowsPerEnd;
      final ends = distance.arrows ~/ arrowsPerEnd;

      distances.add(
        RoundDistance(
          distanceValue: distance.distanceValue,
          arrowsPerEnd: arrowsPerEnd,
          ends: ends,
          firstArrowIndex: arrowsOffset,
          firstEndIndex: endsOffset,
        ),
      );

      arrowsOffset += distance.arrows;
      endsOffset += ends;
    }

    roundDetails = RoundDetails(
      id: roundId,
      displayName: round.displayName,
      scoringSystem: round.scoringSystem,
      distances: distances,
    );
  } else {
    final distance = DistanceValue(session.distance!, session.distanceUnit!);

    roundDetails = RoundDetails(
      id: null,
      displayName: 'Free Practice • ${distance.value} ${distance.unit.name}',
      scoringSystem: scoringSystems[session.scoringSystem]!,
      distances: [
        RoundDistance(
          distanceValue: distance,
          arrowsPerEnd: arrowsPerEnds.first!,
          ends: 99,
          firstArrowIndex: 0,
          firstEndIndex: 0,
        ),
      ],
    );
  }

  return Session(
    id: session.id,
    startTime: session.startTime,
    roundDetails: roundDetails,
    scores: scores
        .map((score) => roundDetails.scoringSystem.get(score.scoreId))
        .toList(),
    isCompetition: session.isCompetition,
  );
}

Iterable<(T, U?)> zip<T, U>(Iterable<T> ts, Iterable<U> us) sync* {
  final tsIter = ts.iterator;
  final usIter = us.iterator;

  while (true) {
    if (!tsIter.moveNext()) {
      break;
    }

    final t = tsIter.current;
    if (usIter.moveNext()) {
      yield (t, usIter.current);
    } else {
      yield (t, null);
    }
  }
}

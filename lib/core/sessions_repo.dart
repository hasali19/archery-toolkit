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
  if (session.roundId case String roundId) {
    roundDetails = standardRounds[roundId]!;
  } else {
    final distance = DistanceValue(session.distance!, session.distanceUnit!);

    roundDetails = RoundDetails(
      id: null,
      displayName: 'Free Practice • ${distance.value} ${distance.unit.name}',
      scoringSystem: scoringSystems[session.scoringSystem]!,
      distances: [
        RoundDistance(
          distanceValue: distance,
          arrowsPerEnd: session.arrowsPerEnd!,
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

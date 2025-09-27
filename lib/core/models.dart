import 'package:archery_toolkit/data/scoring.dart';

class Session {
  final int id;
  final DateTime startTime;
  final RoundDetails roundDetails;
  final List<Score> scores;
  final bool isCompetition;

  const Session({
    required this.id,
    required this.startTime,
    required this.roundDetails,
    required this.scores,
    required this.isCompetition,
  });
}

class RoundDetails {
  final String displayName;
  final ScoringSystem scoringSystem;
  final List<RoundDistance> distances;

  const RoundDetails({
    required this.displayName,
    required this.scoringSystem,
    required this.distances,
  });
}

final class RoundDistance {
  final DistanceValue distanceValue;
  final int arrowsPerEnd;
  final int ends;
  final int firstArrowIndex;
  final int firstEndIndex;

  const RoundDistance({
    required this.distanceValue,
    required this.arrowsPerEnd,
    required this.ends,
    required this.firstArrowIndex,
    required this.firstEndIndex,
  });

  int get arrows => arrowsPerEnd * ends;

  int get lastArrowIndex => firstArrowIndex + arrows - 1;
}

enum DistanceUnit { metres, yards }

final class DistanceValue {
  final int value;
  final DistanceUnit unit;

  const DistanceValue(this.value, this.unit);
}

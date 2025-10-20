import 'package:archery_toolkit/core/models.dart';
import 'package:archery_toolkit/data/scoring.dart';

final class StandardRound {
  final String id;
  final String displayName;
  final ScoringSystem scoringSystem;
  final List<StandardRoundDistance> distances;

  const StandardRound({
    required this.id,
    required this.displayName,
    required this.scoringSystem,
    required this.distances,
  });
}

final class StandardRoundDistance {
  final DistanceValue distanceValue;
  final int arrows;
  final int defaultArrowsPerEnd;
  final List<int> possibleArrowsPerEnd;

  const StandardRoundDistance({
    required this.distanceValue,
    required this.arrows,
    required this.defaultArrowsPerEnd,
    required this.possibleArrowsPerEnd,
  });
}

final standardRounds = [
  StandardRound(
    id: 'portsmouth',
    displayName: 'Portsmouth',
    scoringSystem: ScoringSystems.metric,
    distances: [
      StandardRoundDistance(
        distanceValue: DistanceValue(20, DistanceUnit.yards),
        arrows: 60,
        defaultArrowsPerEnd: 3,
        possibleArrowsPerEnd: [3, 6],
      ),
    ],
  ),
  StandardRound(
    id: 'frostbite',
    displayName: 'Frostbite',
    scoringSystem: ScoringSystems.metric,
    distances: [
      StandardRoundDistance(
        distanceValue: DistanceValue(30, DistanceUnit.metres),
        arrows: 36,
        defaultArrowsPerEnd: 3,
        possibleArrowsPerEnd: [3, 6],
      ),
    ],
  ),
  StandardRound(
    id: 'short_metric_1',
    displayName: 'Short Metric I',
    scoringSystem: ScoringSystems.metric,
    distances: [
      StandardRoundDistance(
        distanceValue: DistanceValue(50, DistanceUnit.metres),
        arrows: 36,
        defaultArrowsPerEnd: 6,
        possibleArrowsPerEnd: [3, 6],
      ),
      StandardRoundDistance(
        distanceValue: DistanceValue(30, DistanceUnit.metres),
        arrows: 36,
        defaultArrowsPerEnd: 3,
        possibleArrowsPerEnd: [3, 6],
      ),
    ],
  ),
  StandardRound(
    id: 'worcester',
    displayName: 'Worcester',
    scoringSystem: ScoringSystems.worcester,
    distances: [
      StandardRoundDistance(
        distanceValue: DistanceValue(20, DistanceUnit.yards),
        arrows: 30,
        defaultArrowsPerEnd: 5,
        possibleArrowsPerEnd: [5],
      ),
      StandardRoundDistance(
        distanceValue: DistanceValue(20, DistanceUnit.yards),
        arrows: 30,
        defaultArrowsPerEnd: 5,
        possibleArrowsPerEnd: [5],
      ),
    ],
  ),
];

final standardRoundsById = {
  for (final round in standardRounds) round.id: round,
};

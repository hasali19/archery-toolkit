import 'package:archery_toolkit/core/models.dart';
import 'package:archery_toolkit/data/scoring.dart';

final standardRounds = {
  'portsmouth': RoundDetails(
    id: 'portsmouth',
    displayName: 'Portsmouth',
    scoringSystem: ScoringSystems.metric,
    distances: [
      RoundDistance(
        distanceValue: DistanceValue(20, DistanceUnit.yards),
        arrowsPerEnd: 3,
        ends: 20,
        firstArrowIndex: 0,
        firstEndIndex: 0,
      ),
    ],
  ),
  'short_metric_1': RoundDetails(
    id: 'short_metric_1',
    displayName: "Short Metric I",
    scoringSystem: ScoringSystems.metric,
    distances: [
      RoundDistance(
        distanceValue: DistanceValue(50, DistanceUnit.metres),
        arrowsPerEnd: 6,
        ends: 6,
        firstArrowIndex: 0,
        firstEndIndex: 0,
      ),
      RoundDistance(
        distanceValue: DistanceValue(30, DistanceUnit.metres),
        arrowsPerEnd: 3,
        ends: 12,
        firstArrowIndex: 3 * 12,
        firstEndIndex: 6,
      ),
    ],
  ),
};

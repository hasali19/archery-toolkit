import 'package:archery_toolkit/core/models.dart';
import 'package:archery_toolkit/data/scoring.dart';

final standardRounds = {
  'short_metric_1': RoundDetails(
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

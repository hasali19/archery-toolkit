import 'package:archery_toolkit/data/scoring.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

@freezed
abstract class Session with _$Session {
  const factory Session({
    required int id,
    required DateTime startTime,
    required RoundDetails roundDetails,
    required List<Score> scores,
    required bool isCompetition,
  }) = _Session;
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

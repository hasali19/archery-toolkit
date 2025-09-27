import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoring.freezed.dart';

class ScoringSystems {
  static final metric = ScoringSystem(
    id: 'metric',
    displayName: 'Metric (10 Zone)',
    scores: [
      Score(id: 1, label: 'X', value: 10, color: Colors.yellow),
      Score(id: 2, label: '10', value: 10, color: Colors.yellow),
      Score(id: 3, label: '9', value: 9, color: Colors.yellow),
      Score(id: 4, label: '8', value: 8, color: Colors.red),
      Score(id: 5, label: '7', value: 7, color: Colors.red),
      Score(id: 6, label: '6', value: 6, color: Colors.blue),
      Score(id: 7, label: '5', value: 5, color: Colors.blue),
      Score(id: 8, label: '4', value: 4, color: Colors.black),
      Score(id: 9, label: '3', value: 3, color: Colors.black),
      Score(id: 10, label: '2', value: 2, color: Colors.white),
      Score(id: 11, label: '1', value: 1, color: Colors.white),
      Score(id: 12, label: 'M', value: 0, color: Colors.green),
    ],
  );
}

final Map<String, ScoringSystem> scoringSystems = {
  'metric': ScoringSystem(
    id: 'metric',
    displayName: 'Metric (10 Zone)',
    scores: [
      Score(id: 1, label: 'X', value: 10, color: Colors.yellow),
      Score(id: 2, label: '10', value: 10, color: Colors.yellow),
      Score(id: 3, label: '9', value: 9, color: Colors.yellow),
      Score(id: 4, label: '8', value: 8, color: Colors.red),
      Score(id: 5, label: '7', value: 7, color: Colors.red),
      Score(id: 6, label: '6', value: 6, color: Colors.blue),
      Score(id: 7, label: '5', value: 5, color: Colors.blue),
      Score(id: 8, label: '4', value: 4, color: Colors.black),
      Score(id: 9, label: '3', value: 3, color: Colors.black),
      Score(id: 10, label: '2', value: 2, color: Colors.white),
      Score(id: 11, label: '1', value: 1, color: Colors.white),
      Score(id: 12, label: 'M', value: 0, color: Colors.green),
    ],
  ),
  'imperial': ScoringSystem(
    id: 'imperial',
    displayName: 'Imperial (5 Zone)',
    scores: [
      Score(id: 1, label: '9', value: 9, color: Colors.yellow),
      Score(id: 2, label: '7', value: 7, color: Colors.red),
      Score(id: 3, label: '5', value: 5, color: Colors.blue),
      Score(id: 4, label: '3', value: 3, color: Colors.black),
      Score(id: 5, label: '1', value: 1, color: Colors.white),
      Score(id: 6, label: 'M', value: 0, color: Colors.green),
    ],
  ),
};

final class ScoringSystem {
  final String id;
  final String displayName;
  final List<Score> scores;
  final Map<int, Score> scoresById;

  ScoringSystem({
    required this.id,
    required this.displayName,
    required this.scores,
  }) : scoresById = {for (final score in scores) score.id: score};

  Score get(int id) {
    return scoresById[id]!;
  }
}

@freezed
abstract class Score with _$Score {
  const Score._();

  const factory Score({
    required int id,
    required String label,
    required int value,
    required Color color,
  }) = _Score;

  Color get foregroundColor =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

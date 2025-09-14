import 'package:archery_toolkit/widgets/score_keyboard.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_scoring.freezed.dart';

final possibleScores = [
  Score(label: 'X', value: 10, color: Colors.yellow),
  Score(label: '10', value: 10, color: Colors.yellow),
  Score(label: '9', value: 9, color: Colors.yellow),
  Score(label: '8', value: 8, color: Colors.red),
  Score(label: '7', value: 7, color: Colors.red),
  Score(label: '6', value: 6, color: Colors.blue),
  Score(label: '5', value: 5, color: Colors.blue),
  Score(label: '4', value: 4, color: Colors.black),
  Score(label: '3', value: 3, color: Colors.black),
  Score(label: '2', value: 2, color: Colors.white),
  Score(label: '1', value: 1, color: Colors.white),
  Score(label: 'M', value: 0, color: Colors.green),
];

@freezed
abstract class Score with _$Score {
  const Score._();

  const factory Score({
    required String label,
    required int value,
    required Color color,
  }) = _Score;

  Color get foregroundColor =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

class SessionScoringPage extends StatefulWidget {
  const SessionScoringPage({super.key});

  @override
  State<SessionScoringPage> createState() => _SessionScoringPageState();
}

class _SessionScoringPageState extends State<SessionScoringPage> {
  final scores = <Score>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Free Practice')),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ScoreSheet(scores: scores),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SafeArea(
              top: false,
              child: ScoreKeyboard(
                scores: possibleScores,
                onScorePressed: (score) {
                  setState(() {
                    scores.add(score);
                  });
                },
                onBackspacePressed: () {
                  setState(() {
                    if (scores.isNotEmpty) {
                      scores.removeLast();
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSheet extends StatelessWidget {
  const _ScoreSheet({required this.scores});

  final List<Score> scores;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final (i, end) in scores.slices(6).indexed) ...[
          Divider(),
          _ScoreSheetRow(index: i + 1, scores: end),
        ],

        if (scores.isNotEmpty) Divider(),
      ],
    );
  }
}

class _ScoreSheetRow extends StatelessWidget {
  const _ScoreSheetRow({required this.index, required this.scores});

  final int index;
  final List<Score> scores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 42,
          padding: EdgeInsets.only(left: 8, right: 16),
          child: Text(
            '$index',
            textAlign: TextAlign.end,
            style: theme.textTheme.labelMedium!.copyWith(
              color: theme.textTheme.labelMedium!.color!.withAlpha(150),
            ),
          ),
        ),

        for (final score in scores)
          Container(
            width: 36,
            height: 36,
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: score.color,
            ),
            child: Center(
              child: Text(
                score.label,
                style: TextStyle(color: score.foregroundColor),
              ),
            ),
          ),

        Spacer(),

        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            scores.map((s) => s.value).sum.toString(),
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

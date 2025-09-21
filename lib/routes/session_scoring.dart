import 'dart:async';

import 'package:archery_toolkit/db/db.dart';
import 'package:archery_toolkit/widgets/score_keyboard.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column, JsonKey;
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

part 'session_scoring.freezed.dart';

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

class SessionScoringPage extends StatefulWidget {
  const SessionScoringPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionScoringPage> createState() => _SessionScoringPageState();
}

class _SessionScoringPageState extends State<SessionScoringPage> {
  late final AppDatabase db;
  late final ScrollController scrollController;

  Session? session;
  ScoringSystem? scoringSystem;
  List<Score> scores = [];

  @override
  void initState() {
    super.initState();

    db = context.read();
    scrollController = ScrollController();

    scheduleMicrotask(() async {
      final session = await (db.select(
        db.sessions,
      )..where((s) => s.id.equals(widget.sessionId))).getSingle();

      final scores =
          await (db.select(db.arrowScores)
                ..where((s) => s.sessionId.equals(widget.sessionId))
                ..orderBy([(s) => OrderingTerm(expression: s.index)]))
              .get();

      setState(() {
        this.session = session;
        scoringSystem = scoringSystems[session.scoringSystem];
        if (scoringSystem case ScoringSystem scoringSystem) {
          this.scores = scores
              .map((s) => scoringSystem.scoresById[s.scoreId]!)
              .toList();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void _addScore(Score score) async {
    scores.add(score);

    final newScoreIndex = scores.length - 1;
    await db
        .into(db.arrowScores)
        .insert(
          ArrowScoresCompanion.insert(
            sessionId: widget.sessionId,
            index: newScoreIndex,
            scoreId: score.id,
          ),
        );

    scrollController.jumpTo(0);

    setState(() {});
  }

  void _removeLastScore() async {
    if (scores.isNotEmpty) {
      scores.removeLast();

      final lastScoreIndex = scores.length;
      final query = db.delete(db.arrowScores)
        ..where(
          (s) =>
              s.sessionId.equals(widget.sessionId) &
              s.index.equals(lastScoreIndex),
        );

      await query.go();

      scrollController.jumpTo(0);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = scores.map((s) => s.value).sum;
    final average = scores.isEmpty ? 0 : total / scores.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Free Practice'),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.pop(context);
              await (db.delete(
                db.sessions,
              )..where((s) => s.id.equals(widget.sessionId))).go();
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ScoreSheet(
                  scrollController: scrollController,
                  scores: scores,
                  arrowsPerEnd: session?.arrowsPerEnd ?? 6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('${session?.distance} ${session?.distanceUnit}'),
                  Spacer(),
                  Text('Total: $total'),
                  Gap(8),
                  Text('Average: ${average.toStringAsFixed(2)}'),
                ],
              ),
            ),
            if (scoringSystem case ScoringSystem scoringSystem)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ScoreKeyboard(
                  scoringSystem: scoringSystem,
                  onScorePressed: _addScore,
                  onBackspacePressed: _removeLastScore,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Iterable<(int, List<Score>)> _reversedEnds(
  List<Score> scores,
  int arrowsPerEnd,
) {
  final ends = scores.slices(arrowsPerEnd).indexed.toList();
  return ends.reversed;
}

class _ScoreSheet extends StatelessWidget {
  const _ScoreSheet({
    required this.scrollController,
    required this.scores,
    required this.arrowsPerEnd,
  });

  final ScrollController scrollController;
  final List<Score> scores;
  final int arrowsPerEnd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      reverse: true,
      children: [
        for (final (i, end) in _reversedEnds(scores, arrowsPerEnd)) ...[
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

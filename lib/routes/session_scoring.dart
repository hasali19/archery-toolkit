import 'dart:async';

import 'package:archery_toolkit/db/db.dart';
import 'package:archery_toolkit/widgets/score_keyboard.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column, JsonKey;
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';

part 'session_scoring.freezed.dart';

final possibleScores = [
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
];

final possibleScoresById = {
  for (final score in possibleScores) score.id: score,
};

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

  Session? session;
  List<Score> scores = [];

  @override
  void initState() {
    super.initState();

    db = context.read();

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
        this.scores = scores
            .map((s) => possibleScoresById[s.scoreId]!)
            .toList();
      });
    });
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

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ScoreSheet(
                  scores: scores,
                  arrowsPerEnd: session?.arrowsPerEnd ?? 6,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SafeArea(
              top: false,
              child: ScoreKeyboard(
                scores: possibleScores,
                onScorePressed: _addScore,
                onBackspacePressed: _removeLastScore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreSheet extends StatelessWidget {
  const _ScoreSheet({required this.scores, required this.arrowsPerEnd});

  final List<Score> scores;
  final int arrowsPerEnd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final (i, end) in scores.slices(arrowsPerEnd).indexed) ...[
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

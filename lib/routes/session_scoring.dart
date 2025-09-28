import 'dart:async';
import 'dart:math';

import 'package:archery_toolkit/core/models.dart';
import 'package:archery_toolkit/core/sessions_repo.dart';
import 'package:archery_toolkit/data/scoring.dart';
import 'package:archery_toolkit/db/sessions.dart';
import 'package:archery_toolkit/widgets/score_keyboard.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class SessionScoringPage extends StatefulWidget {
  const SessionScoringPage({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionScoringPage> createState() => _SessionScoringPageState();
}

class _SessionScoringPageState extends State<SessionScoringPage> {
  late final SessionsRepo sessionsRepo;
  late final ScrollController scrollController;

  Session? session;
  List<Score> scores = [];

  @override
  void initState() {
    super.initState();

    sessionsRepo = SessionsRepo(SessionsDao(context.read()));
    scrollController = ScrollController();

    scheduleMicrotask(() async {
      final session = await sessionsRepo.getSession(widget.sessionId);

      setState(() {
        this.session = session;
        scores = session.scores;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void _addScore(Score score) async {
    final newScoreIndex = scores.length;

    scores.add(score);

    await sessionsRepo.sessionsDao.insertScore(
      widget.sessionId,
      newScoreIndex,
      score.id,
    );

    _scrollToArrow(newScoreIndex);

    setState(() {});
  }

  void _removeLastScore() async {
    if (scores.isNotEmpty) {
      final lastScoreIndex = scores.length - 1;

      scores.removeLast();

      await sessionsRepo.sessionsDao.removeScore(
        widget.sessionId,
        lastScoreIndex,
      );

      _scrollToArrow(lastScoreIndex);

      setState(() {});
    }
  }

  void _scrollToArrow(int arrowIndex) {
    final scrollPosition = scrollController.position;
    final arrowOffset = _calculateScrollOffsetForArrow(arrowIndex);

    if (arrowOffset < scrollPosition.pixels ||
        arrowOffset >
            scrollPosition.pixels + scrollPosition.viewportDimension) {
      scrollController.jumpTo(min(arrowOffset, scrollPosition.maxScrollExtent));
    }
  }

  double _calculateScrollOffsetForArrow(int arrowIndex) {
    final session = this.session;
    if (session == null) {
      throw StateError('Session is null');
    }

    final currentDistanceIndex = session.roundDetails.distances.indexWhere(
      (d) => arrowIndex >= d.firstArrowIndex && arrowIndex <= d.lastArrowIndex,
    );

    double offset = 0;
    for (int i = 0; i <= currentDistanceIndex; i++) {
      final distance = session.roundDetails.distances[i];

      // Add height of distance header
      offset += _ScoreSheet.distanceHeaderHeight;

      final ends = min(arrowIndex ~/ distance.arrowsPerEnd, distance.ends);

      // Add heights of end rows
      offset += ends * _ScoreSheetRow.height;

      // Add heights of end row dividers
      offset += (ends + 1) * _ScoreSheet.dividerHeight;

      arrowIndex -= ends * distance.arrowsPerEnd;
    }

    return offset - _ScoreSheet.dividerHeight / 2;
  }

  @override
  Widget build(BuildContext context) {
    final total = scores.map((s) => s.value).sum;
    final average = scores.isEmpty ? 0 : total / scores.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(session?.roundDetails.displayName ?? ''),
        actions: [
          IconButton(
            onPressed: () async {
              final startDate = await showDatePicker(
                context: context,
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now(),
                initialDate: session?.startTime,
              );

              if (startDate != null) {
                await sessionsRepo.sessionsDao.updateSessionStartTime(
                  widget.sessionId,
                  startDate,
                );

                setState(() {
                  session = session?.copyWith(startTime: startDate);
                });
              }
            },
            icon: Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: () async {
              Navigator.pop(context);
              await sessionsRepo.sessionsDao.removeSession(widget.sessionId);
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
                  distances: session?.roundDetails.distances ?? [],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Total: $total'),
                  Gap(8),
                  Text('Average: ${average.toStringAsFixed(2)}'),
                ],
              ),
            ),
            if (session case Session(
              roundDetails: RoundDetails(:final scoringSystem),
            ))
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

class _ScoreSheet extends StatelessWidget {
  static const distanceHeaderHeight = 36.0;
  static const dividerHeight = 16.0;

  const _ScoreSheet({
    required this.scrollController,
    required this.scores,
    required this.distances,
  });

  final ScrollController scrollController;
  final List<Score> scores;
  final List<RoundDistance> distances;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        for (int i = 0; i < distances.length; i++) _buildDistanceScores(i),
      ],
    );
  }

  Widget _buildDistanceScores(int index) {
    final distance = distances[index];

    final endOffset = distances.slice(0, index).map((d) => d.ends).sum;
    final scoreOffset = distances
        .slice(0, index)
        .map((d) => d.arrowsPerEnd * d.ends)
        .sum;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: distanceHeaderHeight,
            padding: EdgeInsets.all(8),
            child: Text(
              '${distance.distanceValue.value} ${distance.distanceValue.unit.name}',
            ),
          ),
        ),
        SliverToBoxAdapter(child: Divider()),
        SliverList.separated(
          itemCount: distance.ends,
          itemBuilder: (context, index) {
            final startIndex = scoreOffset + index * distance.arrowsPerEnd;

            final List<Score> scores;
            if (startIndex >= this.scores.length) {
              scores = [];
            } else {
              scores = this.scores.slice(
                startIndex,
                min(startIndex + distance.arrowsPerEnd, this.scores.length),
              );
            }

            return _ScoreSheetRow(index: endOffset + index + 1, scores: scores);
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
        SliverToBoxAdapter(child: Divider()),
      ],
    );
  }
}

class _ScoreSheetRow extends StatelessWidget {
  static const height = 44.0;

  const _ScoreSheetRow({required this.index, required this.scores});

  final int index;
  final List<Score> scores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Row(
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
      ),
    );
  }
}

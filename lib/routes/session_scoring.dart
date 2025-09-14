import 'package:archery_toolkit/widgets/score_keyboard.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_scoring.freezed.dart';

final possibleScores = [
  Score(label: 'X', color: Colors.yellow),
  Score(label: '10', color: Colors.yellow),
  Score(label: '9', color: Colors.yellow),
  Score(label: '8', color: Colors.red),
  Score(label: '7', color: Colors.red),
  Score(label: '6', color: Colors.blue),
  Score(label: '5', color: Colors.blue),
  Score(label: '4', color: Colors.black),
  Score(label: '3', color: Colors.black),
  Score(label: '2', color: Colors.white),
  Score(label: '1', color: Colors.white),
  Score(label: 'M', color: Colors.green),
];

@freezed
abstract class Score with _$Score {
  const Score._();

  const factory Score({required String label, required Color color}) = _Score;

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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView(
                  children: scores
                      .slices(3)
                      .map(
                        (end) => Row(
                          children: end
                              .map(
                                (score) => Container(
                                  width: 40,
                                  height: 40,
                                  margin: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: score.color,
                                  ),
                                  child: Center(
                                    child: Text(
                                      score.label,
                                      style: TextStyle(
                                        color: score.foregroundColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
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

import 'package:archery_toolkit/data/scoring.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScoreKeyboard extends StatelessWidget {
  const ScoreKeyboard({
    super.key,
    required this.scoringSystem,
    required this.onScorePressed,
    required this.onBackspacePressed,
  });

  final ScoringSystem scoringSystem;

  final void Function(Score score) onScorePressed;
  final void Function() onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minButtonWidth = 70;
        final columns = (constraints.maxWidth / minButtonWidth).floor();
        final buttonWidth = constraints.maxWidth / columns;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: scoringSystem.scores
                  .slices(columns - 1)
                  .map(
                    (row) => _KeyboardRow(
                      scores: row,
                      buttonWidth: buttonWidth,
                      onScorePressed: onScorePressed,
                    ),
                  )
                  .toList(),
            ),
            _KeyboardButton(
              width: buttonWidth,
              onPressed: onBackspacePressed,
              child: Icon(Icons.backspace),
            ),
          ],
        );
      },
    );
  }
}

class _KeyboardRow extends StatelessWidget {
  const _KeyboardRow({
    required this.scores,
    required this.buttonWidth,
    required this.onScorePressed,
  });

  final List<Score> scores;
  final double buttonWidth;
  final void Function(Score score) onScorePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: scores
          .map(
            (score) => _KeyboardScoreButton(
              score: score,
              buttonWidth: buttonWidth,
              onScorePressed: onScorePressed,
            ),
          )
          .toList(),
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({
    required this.child,
    required this.width,
    this.style,
    required this.onPressed,
  });

  final Widget child;
  final double width;
  final ButtonStyle? style;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: style,
          onPressed: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: child,
        ),
      ),
    );
  }
}

class _KeyboardScoreButton extends StatelessWidget {
  const _KeyboardScoreButton({
    required this.score,
    required this.buttonWidth,
    required this.onScorePressed,
  });

  final Score score;
  final double buttonWidth;
  final void Function(Score score) onScorePressed;

  @override
  Widget build(BuildContext context) {
    return _KeyboardButton(
      width: buttonWidth,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        backgroundColor: WidgetStateProperty.all(score.color),
        foregroundColor: WidgetStateProperty.all(score.foregroundColor),
        overlayColor: WidgetStateProperty.all(
          score.foregroundColor.withAlpha(50),
        ),
      ),
      child: Text(score.label),
      onPressed: () {
        onScorePressed(score);
      },
    );
  }
}

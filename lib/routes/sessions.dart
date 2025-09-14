import 'package:archery_toolkit/db/db.dart';
import 'package:archery_toolkit/routes/session_scoring.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stream_transform/stream_transform.dart';

final DateFormat _dateFormat = DateFormat('dd MMM y');

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late final AppDatabase db;
  late final Stream<Iterable<({Session session, int total})>> sessionsStream;

  @override
  void initState() {
    super.initState();

    db = context.read();

    sessionsStream =
        (db.select(db.sessions)
              ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
            .watch()
            .switchMap((sessions) {
              return (db.select(db.arrowScores)..where(
                    (s) =>
                        s.sessionId.isIn(sessions.map((session) => session.id)),
                  ))
                  .watch()
                  .map((arrowScores) {
                    final totals = arrowScores.groupFoldBy(
                      (score) => score.sessionId,
                      (int? a, b) =>
                          (a ?? 0) + possibleScoresById[b.scoreId]!.value,
                    );

                    return sessions.map(
                      (session) =>
                          (session: session, total: totals[session.id] ?? 0),
                    );
                  });
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sessions')),
      body: StreamBuilder(
        stream: sessionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return ListView(
              children: [
                for (final (:session, :total) in snapshot.data!)
                  ListTile(
                    title: Text('Free Practice'),
                    subtitle: Text(_dateFormat.format(session.startTime)),
                    trailing: Text(
                      total.toString(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SessionScoringPage(sessionId: session.id);
                          },
                        ),
                      );
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        clipBehavior: Clip.antiAlias,
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                                textColor: Colors.red,
                                iconColor: Colors.red,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await (db.delete(db.sessions)
                                        ..where((s) => s.id.equals(session.id)))
                                      .go();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          }

          return Text(snapshot.error.toString());
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Session',
        child: const Icon(Icons.add),
        onPressed: () async {
          final int? arrowsPerEnd = await showDialog(
            context: context,
            builder: (context) {
              return _NewSessionDialog();
            },
          );

          if (arrowsPerEnd != null) {
            final session = await db
                .into(db.sessions)
                .insertReturning(
                  SessionsCompanion.insert(arrowsPerEnd: arrowsPerEnd),
                );

            if (context.mounted) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return SessionScoringPage(sessionId: session.id);
                  },
                ),
              );
            }
          }
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _NewSessionDialog extends StatefulWidget {
  const _NewSessionDialog();

  @override
  State<_NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<_NewSessionDialog> {
  int arrowsPerEnd = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(180),
    );

    return AlertDialog(
      title: Text('New Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arrows per end', style: labelStyle),
          RadioGroup(
            groupValue: 3,
            onChanged: (value) {},
            child: Row(
              spacing: 8,
              children: [_buildChoice(3), _buildChoice(6)],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(arrowsPerEnd),
          child: Text('Ok'),
        ),
      ],
    );
  }

  Widget _buildChoice(int value) {
    return ChoiceChip(
      label: Text(value.toString()),
      selected: arrowsPerEnd == value,
      onSelected: (selected) {
        setState(() {
          arrowsPerEnd = value;
        });
      },
    );
  }
}

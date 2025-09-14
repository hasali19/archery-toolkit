import 'package:archery_toolkit/db/db.dart';
import 'package:archery_toolkit/routes/session_scoring.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column, JsonKey;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stream_transform/stream_transform.dart';

part 'sessions.freezed.dart';

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
                    title: Text(
                      'Free Practice • ${session.distance} ${session.distanceUnit}',
                    ),
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
          final _NewSessionModel? model = await showDialog(
            context: context,
            builder: (context) {
              return _NewSessionDialog();
            },
          );

          if (model != null) {
            final session = await db
                .into(db.sessions)
                .insertReturning(
                  SessionsCompanion.insert(
                    arrowsPerEnd: model.arrowsPerEnd,
                    distance: model.distance,
                    distanceUnit: model.distanceUnit,
                  ),
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

@freezed
abstract class _NewSessionModel with _$NewSessionModel {
  factory _NewSessionModel({
    required int arrowsPerEnd,
    required int distance,
    required String distanceUnit,
  }) = __NewSessionModel;
}

class _NewSessionDialog extends StatefulHookWidget {
  const _NewSessionDialog();

  @override
  State<_NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<_NewSessionDialog> {
  final _formKey = GlobalKey<FormState>();

  int arrowsPerEnd = 3;
  String distanceUnit = 'yards';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(
      color: theme.colorScheme.onSurface.withAlpha(180),
    );

    final distanceController = useTextEditingController(text: '20');

    return AlertDialog(
      title: Text('New Session'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            TextFormField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                // hintText: 'Distance',
                labelText: 'Distance',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            Row(
              spacing: 8,
              children: [
                _buildUnitsChoice('metres'),
                _buildUnitsChoice('yards'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Arrows per end', style: labelStyle),
                Row(
                  spacing: 8,
                  children: [_buildArrowsChoice(3), _buildArrowsChoice(6)],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            final distance = int.parse(distanceController.text);

            Navigator.of(context).pop(
              _NewSessionModel(
                arrowsPerEnd: arrowsPerEnd,
                distance: distance,
                distanceUnit: distanceUnit,
              ),
            );
          },
          child: Text('Ok'),
        ),
      ],
    );
  }

  Widget _buildUnitsChoice(String value) {
    return ChoiceChip(
      label: Text(value),
      selected: distanceUnit == value,
      onSelected: (selected) {
        setState(() {
          distanceUnit = value;
        });
      },
    );
  }

  Widget _buildArrowsChoice(int value) {
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

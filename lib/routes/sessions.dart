import 'package:archery_toolkit/core/models.dart';
import 'package:archery_toolkit/core/sessions_repo.dart';
import 'package:archery_toolkit/data/rounds.dart';
import 'package:archery_toolkit/data/scoring.dart';
import 'package:archery_toolkit/db/sessions.dart';
import 'package:archery_toolkit/routes/session_scoring.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

part 'sessions.freezed.dart';

final DateFormat _dateFormat = DateFormat('dd MMM y');

class SessionsModel {
  final List<Session> sessions;
  final Map<int, int> totals;
  final Set<int> pbSessions;

  SessionsModel({
    required this.sessions,
    required this.totals,
    required this.pbSessions,
  });
}

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late final SessionsRepo sessionsRepo;
  late final Stream<SessionsModel> sessionsStream;

  @override
  void initState() {
    super.initState();

    sessionsRepo = SessionsRepo(SessionsDao(context.read()));

    sessionsStream = sessionsRepo.watchSessions().map((sessions) {
      final sessionsList = sessions.toList();
      final totals = <int, int>{};
      final pbSessions = <String, Session>{};

      for (final session in sessionsList) {
        final total = session.scores.map((s) => s.value).sum;

        totals[session.id] = total;

        if (session.roundDetails.id case String roundId) {
          if (!pbSessions.containsKey(session.roundDetails.id) ||
              total > totals[pbSessions[roundId]!.id]!) {
            pbSessions[roundId] = session;
          }
        }
      }

      return SessionsModel(
        sessions: sessionsList,
        totals: totals,
        pbSessions: pbSessions.values.map((s) => s.id).toSet(),
      );
    });
  }

  void _onCreateNewSession() async {
    final _NewSessionModel? model = await showDialog(
      context: context,
      builder: (context) {
        return _NewSessionDialog();
      },
    );

    if (model != null) {
      final newSession = switch (model.roundId) {
        null => NewSession.freePractice(
          arrowsPerEnd: model.arrowsPerEnd,
          distance: model.distance,
          distanceUnit: model.distanceUnit,
          scoringSystem: model.scoringSystem,
        ),
        final roundId => NewSession.round(
          roundId: roundId,
          isCompetition: model.isCompetition,
        ),
      };

      final session = await sessionsRepo.sessionsDao.insertSession(newSession);

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SessionScoringPage(sessionId: session.id);
            },
          ),
        );
      }
    }
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
            final SessionsModel(:sessions, :totals, :pbSessions) =
                snapshot.data!;
            return ListView(
              children: [
                for (final session in sessions)
                  ListTile(
                    title: Text(session.roundDetails.displayName),
                    subtitle: Text(_dateFormat.format(session.startTime)),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          totals[session.id].toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (pbSessions.contains(session.id))
                          Text(
                            "PB",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                      ],
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
                                  await sessionsRepo.sessionsDao.removeSession(
                                    session.id,
                                  );
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
        onPressed: _onCreateNewSession,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

@freezed
abstract class _NewSessionModel with _$NewSessionModel {
  factory _NewSessionModel({
    required String? roundId,
    required int arrowsPerEnd,
    required int distance,
    required DistanceUnit distanceUnit,
    required String scoringSystem,
    required bool isCompetition,
  }) = __NewSessionModel;
}

class _NewSessionDialog extends StatefulHookWidget {
  const _NewSessionDialog();

  @override
  State<_NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<_NewSessionDialog> {
  final _formKey = GlobalKey<FormState>();

  String? roundId;
  String scoringSystem = 'metric';
  int arrowsPerEnd = 3;
  DistanceUnit distanceUnit = DistanceUnit.yards;
  bool isCompetition = false;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              DropdownMenu(
                initialSelection: roundId,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: null, label: 'Free Practice'),
                  for (final round in standardRounds)
                    DropdownMenuEntry(
                      value: round.id,
                      label: round.displayName,
                    ),
                ],
                label: Text('Round'),
                expandedInsets: EdgeInsets.zero,
                onSelected: (value) {
                  setState(() {
                    roundId = value;
                  });
                },
              ),
              if (roundId == null) ...[
                Gap(8),
                DropdownMenu(
                  initialSelection: scoringSystem,
                  dropdownMenuEntries: [
                    for (final scoringSystem in scoringSystems.values)
                      DropdownMenuEntry(
                        value: scoringSystem.id,
                        label: scoringSystem.displayName,
                      ),
                  ],
                  label: Text('Scoring'),
                  expandedInsets: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value != null) {
                      scoringSystem = value;
                    }
                  },
                ),
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
                    _buildUnitsChoice(DistanceUnit.metres),
                    _buildUnitsChoice(DistanceUnit.yards),
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
              if (roundId != null)
                Row(
                  spacing: 8,
                  children: [
                    _buildCompetitionChoice(false),
                    _buildCompetitionChoice(true),
                  ],
                ),
            ],
          ),
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
                roundId: roundId,
                arrowsPerEnd: arrowsPerEnd,
                distance: distance,
                distanceUnit: distanceUnit,
                scoringSystem: scoringSystem,
                isCompetition: isCompetition,
              ),
            );
          },
          child: Text('Ok'),
        ),
      ],
    );
  }

  Widget _buildUnitsChoice(DistanceUnit value) {
    return ChoiceChip(
      label: Text(value.name),
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

  Widget _buildCompetitionChoice(bool value) {
    return ChoiceChip(
      label: Text(value ? 'Competition' : 'Practice'),
      selected: isCompetition == value,
      onSelected: (selected) {
        setState(() {
          isCompetition = value;
        });
      },
    );
  }
}

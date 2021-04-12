import 'package:flutter/material.dart';
import 'package:scout_spirit/src/forms/initialize.dart';
import 'package:scout_spirit/src/models/objective.dart';
import 'package:scout_spirit/src/providers/reward_provider.dart';
import 'package:scout_spirit/src/services/authentication.dart';
import 'package:scout_spirit/src/services/tasks.dart';
import 'package:scout_spirit/src/themes/theme.dart';
import 'package:scout_spirit/src/utils/development_area.dart';
import 'package:scout_spirit/src/utils/objectives_icons.dart';

class InitializePage extends StatefulWidget {
  @override
  _InitializePageState createState() => _InitializePageState();
}

class _InitializePageState extends State<InitializePage> {
  late final InitializeFormBloc form;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    form = InitializeFormBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          StreamBuilder<Map<DevelopmentArea, List<Objective>>>(
              stream: form.selectedObjectivesStream,
              builder: (context, snapshot) {
                bool ready = snapshot.hasData &&
                    snapshot.data!.length == DevelopmentArea.values.length;
                return TextButton(
                    onPressed:
                        ready && !loading ? () => _initialize() : null,
                    child: Row(children: [
                      Icon(Icons.check, color: ready && !loading ? Colors.white : Colors.white.withAlpha(64)),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Guardar objetivos iniciales",
                        style: TextStyle(color: ready && !loading ? Colors.white : Colors.white.withAlpha(64)),
                      )
                    ]));
              })
        ],
      ),
      body: Container(
        color: appTheme.primaryColor,
        child: StreamBuilder<Map<DevelopmentArea, List<Objective>>>(
            stream: form.selectedObjectivesStream,
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 2,
                      children: DevelopmentArea.values.map((area) {
                        AreaDisplayData display =
                            ObjectivesDisplay.getUserAreaIconData(
                                AuthenticationService().snapAuthenticatedUser!,
                                area);
                        return TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.resolveWith(
                                  (states) => Colors.white.withAlpha(72)),
                              shape: MaterialStateProperty.resolveWith(
                                  (states) => RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero)),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) =>
                                      snapshot.data!.containsKey(area)
                                          ? display.color
                                          : display.disabledColor),
                            ),
                            onPressed: () => _initializeArea(context, area),
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(64.0),
                                  child: Column(
                                    children: [
                                      Icon(display.icon,
                                          color: Colors.white, size: 256.0),
                                      SizedBox(height: 64.0),
                                      Text(
                                        display.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 48.0,
                                            fontFamily: 'Neucha'),
                                      )
                                    ],
                                  ),
                                )));
                      }).toList(),
                    );
            }),
      ),
    );
  }

  Future<void> _initializeArea(
      BuildContext context, DevelopmentArea area) async {
    List<Objective>? old = form.value[area];
    if (old != null) {
      old = old.map((e) => e).toList();
    }
    form.initializeArea(area);
    dynamic? response = await Navigator.of(context)
        .pushNamed('/initialize/area', arguments: {'area': area, 'form': form});
    bool canceled = response == null || response.runtimeType != bool || !response;
    if (canceled) {
      if (old == null) {
        form.resetArea(area);
      } else {
        form.value[area] = old;
        form.value = form.value;
      }
    }
  }

  Future<void> _initialize() async {
    setState(() {
      loading = true;
    });
    try {
      await TasksService().initializeObjectives(form.value);
      await RewardChecker().checkForRewards(context);
    } catch (e) {
      setState(() {
        loading = false;
      });
      throw e;
    }
    Navigator.of(context).pop();
  }
}
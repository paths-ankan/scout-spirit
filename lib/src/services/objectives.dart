import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:scout_spirit/src/error/app_error.dart';
import 'package:scout_spirit/src/models/objective.dart';
import 'package:scout_spirit/src/utils/development_stage.dart';
import 'package:scout_spirit/src/utils/development_area.dart';

class ObjectivesService {
  static final ObjectivesService _instance = ObjectivesService._internal();

  factory ObjectivesService() {
    return _instance;
  }

  ObjectivesService._internal();

  Map<DevelopmentStage, List<Objective>>? cache;

  bool get initialized => cache != null;

  Future<void> preload() async {
    cache = {};
    Future.wait(DevelopmentStage.values.map((DevelopmentStage stage) async {
      // iterate stages: i.e. prepuberty and puberty
      String data = await rootBundle.loadString(
          'assets/jsons/resources/objectives/${stageToString(stage)}.json');
      Map<String, dynamic> stageLines = json.decode(data);
      cache![stage] = [];

      stageLines.forEach((String areaName, dynamic lines) {
        // iterate areas
        DevelopmentArea area = areaFromName(areaName);
        lines.asMap().forEach((int line, dynamic objectives) {
          List.castFrom<dynamic, String>(List.from(objectives))
              .asMap()
              .forEach((subline, String objectiveContent) {
            Objective objective = Objective(
                stage: stage,
                area: area,
                line: line + 1,
                subline: subline + 1,
                rawObjective: objectiveContent);
            cache![stage]!.add(objective);
          });
        });
      });
    }));
  }

  List<Objective> getAllByStage(DevelopmentStage stage) {
    if (!initialized)
      throw AppError(message: 'Trying to use uninitialized service');
    return cache![stage]!.where((objective) => objective.stage == stage).toList();
  }

  List<Objective> getAllByArea(DevelopmentStage stage, DevelopmentArea area) {
    if (!initialized)
      throw AppError(message: 'Trying to use uninitialized service');
    return cache![stage]!.where((objective) => objective.area == area).toList();
  }

  List<Objective> getAllByLine(
      DevelopmentStage stage, DevelopmentArea area, int line) {
    if (!initialized)
      throw AppError(message: 'Trying to use uninitialized service');
    return cache![stage]!
        .where((objective) => objective.area == area && objective.line == line)
        .toList();
  }

  Objective getBySubline(
      DevelopmentStage stage, DevelopmentArea area, int line, int subline) {
    if (!initialized)
      throw AppError(message: 'Trying to use uninitialized service');
    return cache![stage]!.firstWhere((element) =>
        element.stage == stage &&
        element.area == area &&
        element.line == line &&
        element.subline == subline);
  }

  Objective getByKey(String key) {
    List<String> splitted = key.split('::');
    if (splitted.length != 3)
      throw new AppError(message: 'Objective key $key must consist of 3 parts');
    List<String> lineSubline = splitted[2].split('.');
    if (lineSubline.length != 2)
      throw new AppError(message: 'Objective line ${splitted[2]} must consist of 2 parts');
    DevelopmentStage stage = stageFromName(splitted[0]);
    DevelopmentArea area = areaFromName(splitted[1]);
    int line = int.parse(lineSubline[0]);
    int subline = int.parse(lineSubline[1]);
    return getBySubline(stage, area, line, subline);
  }
}

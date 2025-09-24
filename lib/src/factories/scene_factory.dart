import '../models/scene_model.dart';
import 'scene_action_factory.dart';
import 'scene_condition_factory.dart';
import 'scene_precondition_factory.dart';

class ThingSmartSceneFactory extends ThingSmartSceneFactoryBase {
  ThingSmartSceneFactory({
    required num homeId,
    required String name,
    required List<ThingSmartSceneActionFactory> actions,
    super.preConditionions = const [],
    super.conditions = const [],
    super.showFirstPage = false,
    super.matchType = ThingSmartConditionMatchType.ThingSmartConditionMatchAny,
  }) : super(
          actions: actions,
          homeId: homeId,
          name: name,
        );
}

class ThingSmartSceneFactoryBase {
  num? homeId;
  String? name;
  String? id;
  bool? showFirstPage;
  List<ThingSmartSceneActionFactory>? actions;
  List<ThingSmartScenePreConditionFactory>? preConditionions;
  List<ThingSmartSceneConditionFactory>? conditions;
  ThingSmartConditionMatchType? matchType;

  ThingSmartSceneFactoryBase({
    this.homeId,
    this.actions,
    this.id,
    this.name,
    this.preConditionions,
    this.conditions,
    this.showFirstPage,
    this.matchType,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "homeId": homeId,
      "actions": actions?.map((e) => e.toJson()).toList(),
      "preConditions": preConditionions?.map((e) => e.toJson()).toList(),
      "conditions": conditions?.map((e) => e.toMap()).toList(),
      "showFirstPage": showFirstPage,
      "matchType": matchType?.value,
    };
  }
}

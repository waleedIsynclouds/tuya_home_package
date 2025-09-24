import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tuya_home_sdk_flutter.dart';
import '../factories/scene_factory.dart';

class ThingSmartSceneModel {
  final String id;
  final String name;
  final String? gwId;
  final String? coverIcon;
  final String? displayColor;
  final bool isEnabled;
  final bool isStickyOnTop;
  final bool isNewLocalScene;
  final bool isLocalLinkage;
  final List<String> categorys;
  final String? arrowIconUrl;
  final String? background;
  final OutOfWork outOfWork;
  final ThingSmartConditionMatchType matchType;
  final ThingSmartScenePanelType panelType;
  final ThingLocalLinkageType linkageType;
  final ThingSmartSceneRuleGenre ruleGenre;
  final List<ThingSmartSceneConditionModel> conditions;
  final List<ThingSmartSceneConditionModel> statusConditions;
  final List<ThingSmartSceneActionModel> actions;
  final List<ThingSmartScenePreConditionModel> preConditions;

  ThingSmartSceneModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        gwId = json['gwId'],
        coverIcon = json['coverIcon'],
        background = json['background'],
        displayColor = json['displayColor'],
        isEnabled = json['isEnabled'],
        isStickyOnTop = json['isStickyOnTop'],
        isNewLocalScene = json['isNewLocalScene'],
        isLocalLinkage = json['isLocalLinkage'],
        categorys = json['categorys']?.cast<String>() ?? [],
        outOfWork = OutOfWork.byValue(json['outOfWork']),
        matchType = ThingSmartConditionMatchType.byValue(json['matchType']),
        panelType = ThingSmartScenePanelType.byValue(json['panelType']),
        linkageType = ThingLocalLinkageType.byValue(json['linkageType']),
        ruleGenre = ThingSmartSceneRuleGenre.byValue(json['ruleGenre']),
        conditions = List<ThingSmartSceneConditionModel>.from(json['conditions']
                ?.map((e) => ThingSmartSceneConditionModel.fromJson(
                    e.cast<String, dynamic>())) ??
            []),
        statusConditions = List<ThingSmartSceneConditionModel>.from(
            json['statusConditions']?.map((e) =>
                    ThingSmartSceneConditionModel.fromJson(
                        e.cast<String, dynamic>())) ??
                []),
        actions = List.from(json['actions'].map((e) =>
            ThingSmartSceneActionModel.fromJson(e.cast<String, dynamic>()))),
        preConditions = List.from(json['preConditions']?.map((e) =>
                ThingSmartScenePreConditionModel.fromJson(
                    e.cast<String, dynamic>())) ??
            []),
        arrowIconUrl = json['arrowIconUrl'];

  /// Removes a scene with the specified scene ID from the specified home.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'removeScene' method, passing the provided [homeId] and [sceneId] as
  /// parameters. It expects a boolean value as a result, indicating whether the
  /// scene was successfully removed or not. If the scene removal fails or an
  /// error occurs during the method call, `false` is returned.
  ///
  /// Parameters:
  /// - [homeId] (required): The ID of the home from which to remove the scene.
  ///   Must be greater than 0.
  /// - [sceneId] (required): The ID of the scene to be removed. Must not be
  ///   empty.
  ///
  /// Returns:
  /// - A boolean value indicating whether the scene was successfully removed or
  ///   not. If the scene removal fails or an error occurs, `false` is returned.
  Future<bool> removeScene({
    required num homeId,
  }) async {
    assert(homeId > 0, "homeId must be greater than 0");

    try {
      var res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMethod<bool>('removeScene', {"sceneId": id, "homeId": homeId});
      return res ?? false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> editScene({
    String? name,
    bool? showFirstPage,
    List<ThingSmartSceneActionFactory>? actions,
    List<ThingSmartScenePreConditionFactory>? preConditionions,
    List<ThingSmartSceneConditionFactory>? conditions,
    ThingSmartConditionMatchType? matchType,
  }) async {
    var sceneFactory = ThingSmartSceneFactoryBase(
      actions: actions,
      conditions: conditions,
      matchType: matchType,
      name: name,
      preConditionions: preConditionions,
      showFirstPage: showFirstPage,
      id: this.id,
    );

    try {
      final res =
          await TuyaHomeSdkFlutter.instance.methodChannel.invokeMethod<bool>(
        'editScene',
        sceneFactory.toMap(),
      );
      if (res == null) return false;
      return res;
    } catch (e) {
      return false;
    }
  }

  /// Runs a scene with the specified scene ID.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'runScene' method, passing the provided [sceneId] as a parameter.
  /// It expects a boolean value as a result, indicating whether the scene was
  /// successfully run or not. If the scene running fails or an error occurs
  /// during the method call, `false` is returned.
  ///
  /// Parameters:
  /// - [sceneId] (required): The ID of the scene to be run. Must not be
  ///   empty.
  ///
  /// Returns:
  /// - A boolean value indicating whether the scene was successfully run or
  ///   not. If the scene running fails or an error occurs, `false` is returned.
  Future<bool> runScene() async {
    try {
      var res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMethod<bool>('runScene', {"sceneId": id});
      return res ?? false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// Only automation scenes can be enabled or disabled.
  Future<bool> enableAutomation() async {
    try {
      var res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMethod<bool>('changeAutomation', {
        "sceneId": id,
        "status": true,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// Only automation scenes can be enabled or disabled.
  Future<bool> disableAutomation() async {
    try {
      var res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMethod<bool>('changeAutomation', {
        "sceneId": id,
        "status": false,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

enum OutOfWork {
  /// Normal state
  ThingSmartSceneWorkingStatusFine(0),

  /// Invalid status, scenario cannot be executed successfully
  ThingSmartSceneWorkingStatusInvalid(1),

  /// An abnormal state indicates that a device is offline, but the scenario can still be executed
  ThingSmartSceneWorkingStatusException(2);

  final int value;
  const OutOfWork(this.value);
  static OutOfWork byValue(int value) =>
      OutOfWork.values.firstWhere((e) => e.value == value);
}

/// The two types of condition match. Provides any and all types.
enum ThingSmartConditionMatchType {
  ThingSmartConditionMatchNone(0),

  /// The condition match any type, it means any one condition in the scene is be matched, it will be executed.
  ThingSmartConditionMatchAny(1),

  /// The condition match all type, it means all conditions in the scene is be matched, it will be executed.
  ThingSmartConditionMatchAll(2);

  final int value;
  const ThingSmartConditionMatchType(this.value);
  static ThingSmartConditionMatchType byValue(int value) =>
      ThingSmartConditionMatchType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => ThingSmartConditionMatchType.ThingSmartConditionMatchNone,
      );
}

/// The two types of device list on the panel when creating scene.
enum ThingSmartScenePanelType {
  /// The non all device panel type, indicates you can only add zigbee device in the scene action.
  ThingSmartScenePanelTypeNonAllDevevice(0),

  /// The all device panel type, indicates you can add zigbee device and wifi device in the scene action.
  ThingSmartScenePanelTypeAllDevices(1);

  final int value;
  const ThingSmartScenePanelType(this.value);
  static ThingSmartScenePanelType byValue(int value) =>
      ThingSmartScenePanelType.values.firstWhere((e) => e.value == value);
}

/// Describes the linkage types
enum ThingLocalLinkageType {
  /// The unknow linkage type.
  ThingLinkageTypeUnknow(0),

  /// The local linkage type, indicates only one gateway.
  ThingLinkageTypeLocal(1),

  /// The lan linkage type, allows devices to be controlled across multiple gateways without a network or router.
  ThingLinkageTypeLan(2);

  final int value;
  const ThingLocalLinkageType(this.value);
  static ThingLocalLinkageType byValue(int value) =>
      ThingLocalLinkageType.values.firstWhere((e) => e.value == value);
}

enum ThingSmartSceneRuleGenre {
  ThingSmartSceneRuleGenreNone(0),

  /// Tap-to-run
  ThingSmartSceneRuleGenreManual(1),

  /// Automation
  ThingSmartSceneRuleGenreAuto(2);

  final int value;
  const ThingSmartSceneRuleGenre(this.value);
  static ThingSmartSceneRuleGenre byValue(int value) =>
      ThingSmartSceneRuleGenre.values.firstWhere((e) => e.value == value);
}

class ThingSmartSceneConditionModel {
  final ThingConditionAutoType entityType;
  final String entityId;
  final List<List<String>> expr;
  final String id;
  final String? entityName;
  final String? exprDisplay;
  final CondType condType;
  final Map<String, dynamic> extraInfo;
  ThingSmartSceneConditionModel.fromJson(Map<String, dynamic> json)
      : entityType = ThingConditionAutoType.byValue(json['entityType']),
        entityId = json['entityId'],
        expr = (json['expr'] as List<Object?>).cast<List<String>>(),
        id = json['id'],
        entityName = json['entityName'],
        exprDisplay = json['exprDisplay'],
        condType = CondType.byValue(json['condType']),
        extraInfo = Map.from(json['extraInfo'] ?? {});
}

/// The condition auto type.
enum ThingConditionAutoType {
  /// The device auto type.
  AutoTypeDevice(1),

  /// The whether auto type.
  AutoTypeWhether(3),

  /// The timer auto type.
  AutoTypeTimer(6),

  /// The pir sensor auto type.
  AutoTypePir(7),

  /// The face recognition auto type.
  AutoTypeFaceRecognition(9),

  /// The geo auto type.
  AutoTypeGeofence(10),

  /// The lock member go home auto type.
  AutoTypeLockMemberGoHome(11),

  /// The security type.
  AutoTypeArmed(12),

  /// The condition calculate auto type. As a bd last x hours.
  AutoTypeConditionCalculate(13),

  /// The sun set od rise timer auto type. As x minutes before sunrise.
  AutoTypeSunsetriseTimer(16),

  /// Energy MiniApp
  AutoTypeConditionEnergy(28),

  /// The device struct dp condition type.
  AutoTypeStruct(30),

  /// The disaster weather conditon type.
  AutoTypeDisasterWeather(31),

  /// The manual auto type. This type of condition should not be saved to server, and server will not return this type of condition neither.
  AutoTypeManual(99);

  final int value;
  const ThingConditionAutoType(this.value);
  static ThingConditionAutoType byValue(int value) =>
      ThingConditionAutoType.values.firstWhere((e) => e.value == value);
}

enum CondType {
  None(0),
  MatchAgainstExpressions(1),
  SimpleMatch(2);

  final int value;
  const CondType(this.value);
  static CondType byValue(int value) =>
      CondType.values.firstWhere((e) => e.value == value);
}

class ThingSmartSceneActionModel {
  String? id;
  String? entityName;
  String? pid;
  String? productId;
  String? actionDisplay;
  String? entityId;
  String? productPic;
  String? uiid;
  Map<String, dynamic>? executorProperty;

  ThingSmartSceneActionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        entityName = json['entityName'],
        pid = json['pid'],
        productId = json['productId'],
        actionDisplay = json['actionDisplay'],
        entityId = json['entityId'],
        productPic = json['productPic'],
        uiid = json['uiid'],
        executorProperty = Map.from(json['executorProperty'] ?? {});
}

class ThingSmartScenePreConditionModel {
  final String id;
  final String? conditionId;
  final String condType;
  final Map<String, dynamic>? expr;
  ThingSmartScenePreConditionModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        conditionId = json['conditionId'],
        condType = json['condType'],
        expr = Map.from(json['expr']);
}

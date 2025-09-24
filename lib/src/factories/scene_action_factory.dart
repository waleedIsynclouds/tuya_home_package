// scene_action.dart

/// Matches the Objective‑C `AutoSwitchType` enum.
enum AutoSwitchType {
  enable, // kAutoSwitchTypeEnable = 0
  disable; // kAutoSwitchTypeDisable = 1
}

/// A generic model that represents every kind of action the factory can create.
///
/// Only the fields relevant for the chosen [kind] need to be populated.
class ThingSmartSceneActionFactory {
  const ThingSmartSceneActionFactory._({
    required this.kind,
    this.devId,
    this.devName,
    this.groupId,
    this.groupName,
    this.sceneId,
    this.sceneName,
    this.executerProperty,
    this.extraProperty,
    this.autoSwitchType,
    this.delayHours,
    this.delayMinutes,
    this.delaySeconds,
  });

  factory ThingSmartSceneActionFactory.createDeviceDpAction({
    required String devId,
    required String devName,
    required Map<String, dynamic> executerProperty,
    Map<String, dynamic>? extraProperty,
  }) =>
      ThingSmartSceneActionFactory._(
        kind: SceneActionKind.deviceDp,
        devId: devId,
        devName: devName,
        executerProperty: executerProperty,
        extraProperty: extraProperty,
      );

  factory ThingSmartSceneActionFactory.createGroupDpAction({
    required String groupId,
    required String groupName,
    required Map<String, dynamic> executerProperty,
    Map<String, dynamic>? extraProperty,
  }) =>
      ThingSmartSceneActionFactory._(
        kind: SceneActionKind.groupDp,
        groupId: groupId,
        groupName: groupName,
        executerProperty: executerProperty,
        extraProperty: extraProperty,
      );

  factory ThingSmartSceneActionFactory.createTriggerSceneAction({
    required String sceneId,
    required String sceneName,
  }) =>
      ThingSmartSceneActionFactory._(
        kind: SceneActionKind.triggerScene,
        sceneId: sceneId,
        sceneName: sceneName,
      );

  factory ThingSmartSceneActionFactory.createSwitchAutoAction({
    required String sceneId,
    required String sceneName,
    required AutoSwitchType type,
  }) =>
      ThingSmartSceneActionFactory._(
        kind: SceneActionKind.switchAutomation,
        sceneId: sceneId,
        sceneName: sceneName,
        autoSwitchType: type,
      );

  factory ThingSmartSceneActionFactory.createDelayAction({
    required String hours,
    required String minutes,
    required String seconds,
  }) =>
      ThingSmartSceneActionFactory._(
        kind: SceneActionKind.delay,
        delayHours: hours,
        delayMinutes: minutes,
        delaySeconds: seconds,
      );

  factory ThingSmartSceneActionFactory.createSendNotificationAction() =>
      ThingSmartSceneActionFactory._(kind: SceneActionKind.sendNotification);

  factory ThingSmartSceneActionFactory.createCallAction() =>
      ThingSmartSceneActionFactory._(kind: SceneActionKind.call);

  factory ThingSmartSceneActionFactory.createSmsAction() =>
      ThingSmartSceneActionFactory._(kind: SceneActionKind.sms);

  /// Identifies which static factory produced this instance.
  final SceneActionKind kind;

  // Device / group
  final String? devId;
  final String? devName;
  final String? groupId;
  final String? groupName;

  // Scene
  final String? sceneId;
  final String? sceneName;

  // DP execution
  final Map<String, dynamic>? executerProperty;
  final Map<String, dynamic>? extraProperty;

  // Enable / disable automation
  final AutoSwitchType? autoSwitchType;

  // Delay
  final String? delayHours; // Keep as String to match iOS API: "0"‑"5"
  final String? delayMinutes; // "0"‑"59"
  final String? delaySeconds; // "0"‑"59"

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        if (devId != null) 'devId': devId,
        if (devName != null) 'devName': devName,
        if (groupId != null) 'groupId': groupId,
        if (groupName != null) 'groupName': groupName,
        if (sceneId != null) 'sceneId': sceneId,
        if (sceneName != null) 'sceneName': sceneName,
        if (executerProperty != null) 'executerProperty': executerProperty,
        if (extraProperty != null) 'extraProperty': extraProperty,
        if (autoSwitchType != null) 'autoSwitchType': autoSwitchType!.index,
        if (delayHours != null) 'delayHours': delayHours,
        if (delayMinutes != null) 'delayMinutes': delayMinutes,
        if (delaySeconds != null) 'delaySeconds': delaySeconds,
      };
}

/// Matches the “createXXXAction” factory methods in the Obj‑C header.
enum SceneActionKind {
  deviceDp,
  groupDp,
  triggerScene,
  switchAutomation,
  delay,
  sendNotification,
  call,
  sms,
}

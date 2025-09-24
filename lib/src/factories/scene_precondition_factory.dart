/// Matches the Obj‑C factory methods in `ThingSmartScenePreConditionFactory`.
enum ScenePreConditionKind { allDay, daytime, night, customTime }

class ThingSmartScenePreConditionFactory {
  // ────────────────────────────────────────────────────────────────────
  // Private constructor (can only be called from static helpers)
  // ────────────────────────────────────────────────────────────────────
  const ThingSmartScenePreConditionFactory._({
    required this.kind,
    this.sceneId,
    this.conditionId,
    this.loops = '111111',
    required this.timeZoneId,
    this.cityId,
    this.cityName,
    this.beginTime,
    this.endTime,
  });

  // ────────────────────────────────────────────────────────────────────
  // Public factory helpers that replicate the iOS API
  // ────────────────────────────────────────────────────────────────────
  factory ThingSmartScenePreConditionFactory.allDay({
    String? sceneId,
    String? conditionId,
    String? loops,
    String? timeZoneId,
  }) =>
      ThingSmartScenePreConditionFactory._(
        kind: ScenePreConditionKind.allDay,
        sceneId: sceneId,
        conditionId: conditionId,
        loops: loops,
        timeZoneId: timeZoneId ?? DateTime.now().timeZoneName,
      );

  factory ThingSmartScenePreConditionFactory.daytime({
    String? sceneId,
    String? conditionId,
    String? loops,
    required String cityId,
    required String cityName,
    required String timeZoneId,
  }) =>
      ThingSmartScenePreConditionFactory._(
        kind: ScenePreConditionKind.daytime,
        sceneId: sceneId,
        conditionId: conditionId,
        loops: loops,
        cityId: cityId,
        cityName: cityName,
        timeZoneId: timeZoneId,
      );

  factory ThingSmartScenePreConditionFactory.night({
    String? sceneId,
    String? conditionId,
    String? loops,
    required String cityId,
    required String cityName,
    required String timeZoneId,
  }) =>
      ThingSmartScenePreConditionFactory._(
        kind: ScenePreConditionKind.night,
        sceneId: sceneId,
        conditionId: conditionId,
        loops: loops,
        cityId: cityId,
        cityName: cityName,
        timeZoneId: timeZoneId,
      );

  factory ThingSmartScenePreConditionFactory.customTime({
    String? sceneId,
    String? conditionId,
    String? loops,
    required String cityId,
    required String cityName,
    required String timeZoneId,
    required String beginTime, // "HH:mm"
    required String endTime, // "HH:mm"
  }) =>
      ThingSmartScenePreConditionFactory._(
        kind: ScenePreConditionKind.customTime,
        sceneId: sceneId,
        conditionId: conditionId,
        loops: loops,
        cityId: cityId,
        cityName: cityName,
        timeZoneId: timeZoneId,
        beginTime: beginTime,
        endTime: endTime,
      );

  // ────────────────────────────────────────────────────────────────────
  // Fields (all final – model is immutable)
  // ────────────────────────────────────────────────────────────────────
  final ScenePreConditionKind kind;

  final String? sceneId;
  final String? conditionId;

  /// Seven‑character string, Sunday→Saturday, '1' = valid, '0' = invalid.
  final String? loops;

  /// IANA timezone ID – e.g. "Asia/Shanghai".
  final String timeZoneId;

  /// Only for sunrise/sunset/custom‑time kinds
  final String? cityId;
  final String? cityName;

  /// Only for custom‑time kind
  final String? beginTime;
  final String? endTime;

  /// Convert to a map that can be sent over the method channel.
  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        if (sceneId != null) 'sceneId': sceneId,
        if (conditionId != null) 'conditionId': conditionId,
        'loops': loops ?? '1111111',
        'timeZoneId': timeZoneId,
        if (cityId != null) 'cityId': cityId,
        if (cityName != null) 'cityName': cityName,
        if (beginTime != null) 'beginTime': beginTime,
        if (endTime != null) 'endTime': endTime,
      };
}

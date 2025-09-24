import 'scene_expr_factory.dart';

/// Matches every static constructor in the Obj‑C
/// `ThingSmartSceneConditionFactory`.
enum SceneConditionKind {
  device,
  pir,
  weather,
  timer,
  sunTimer,
  geoFence,
  manual,
  calculateDuration,
  memberBackHome,
}

enum GeoFenceType {
  /// The geo fence reach type.
  kGeoFenceTypeReach,

  /// The geo fence exit type.
  kGeoFenceTypeExit,

  /// The geo fence not set type.
  kGeoFenceTypeNotSet,

  /// The geo fence in type.
  kGeoFenceTypeIn,

  /// The geo fence out type.
  kGeoFenceTypeOut
}

/// Immutable DTO sent over the method channel.
class ThingSmartSceneConditionFactory {
  const ThingSmartSceneConditionFactory._({
    required this.kind,
    this.deviceId,
    this.dpModelId,
    this.expr,
    this.city,
    this.geoType,
    this.latitude,
    this.longitude,
    this.radius,
    this.geoTitle,
    this.durationSeconds,
    this.entitySubIds,
    this.memberIds,
    this.memberNames,
  });

  // ────────────────────────────────────────────────────────────────────
  // Public helpers (one per Obj‑C constructor)
  // ────────────────────────────────────────────────────────────────────

  /// Generic “device datapoint” condition.
  static ThingSmartSceneConditionFactory device({
    required String deviceId,
    required int dpModelId,
    required ThingSmartSceneExprFactory expr,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.device,
        deviceId: deviceId,
        dpModelId: dpModelId,
        expr: expr,
      );

  /// PIR *timed* condition (“no movement for 5 min”).
  static ThingSmartSceneConditionFactory pir({
    required String deviceId,
    required int dpModelId,
    required ThingSmartSceneExprFactory expr,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.pir,
        deviceId: deviceId,
        dpModelId: dpModelId,
        expr: expr,
      );

  /// Weather (city‑based) condition.
  static ThingSmartSceneConditionFactory weather({
    required ThingSmartCityFactory city,
    required int dpModelId,
    required ThingSmartSceneExprFactory expr,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.weather,
        city: city,
        dpModelId: dpModelId,
        expr: expr,
      );

  /// Plain timer condition.
  static ThingSmartSceneConditionFactory timer({
    required ThingSmartSceneExprFactory expr,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.timer,
        expr: expr,
      );

  /// Sunrise / sunset timer condition.
  static ThingSmartSceneConditionFactory sunTimer({
    required ThingSmartCityFactory city,
    required ThingSmartSceneExprFactory expr,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.sunTimer,
        city: city,
        expr: expr,
      );

  /// Geo‑fence (reach / leave) condition.
  static ThingSmartSceneConditionFactory geoFence({
    required GeoFenceType geoType, // 0 = enter, 1 = leave (GeoFenceType)
    required double latitude,
    required double longitude,
    required double radius,
    required String geoTitle,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.geoFence,
        geoType: geoType,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        geoTitle: geoTitle,
      );

  /// Manual execute.
  static ThingSmartSceneConditionFactory manual() =>
      const ThingSmartSceneConditionFactory._(kind: SceneConditionKind.manual);

  /// Calculate‑duration (“state lasts N s”).
  static ThingSmartSceneConditionFactory calculateDuration({
    required String deviceId,
    required int dpModelId,
    required ThingSmartSceneExprFactory expr,
    required int durationSeconds,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.calculateDuration,
        deviceId: deviceId,
        dpModelId: dpModelId,
        expr: expr,
        durationSeconds: durationSeconds,
      );

  /// Member back home.
  static ThingSmartSceneConditionFactory memberBackHome({
    required String deviceId,
    required String entitySubIds,
    required String memberIds,
    required String memberNames,
  }) =>
      ThingSmartSceneConditionFactory._(
        kind: SceneConditionKind.memberBackHome,
        deviceId: deviceId,
        entitySubIds: entitySubIds,
        memberIds: memberIds,
        memberNames: memberNames,
      );

  // ────────────────────────────────────────────────────────────────────
  // Fields
  // ────────────────────────────────────────────────────────────────────
  final SceneConditionKind kind;

  // Device / dp
  final String? deviceId;
  final int? dpModelId;

  // Generic expr
  final ThingSmartSceneExprFactory? expr;

  // City
  final ThingSmartCityFactory? city;

  // Geo‑fence
  final GeoFenceType? geoType;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? geoTitle;

  // Duration
  final int? durationSeconds;

  // Member home
  final String? entitySubIds;
  final String? memberIds;
  final String? memberNames;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        if (deviceId != null) 'deviceId': deviceId,
        if (dpModelId != null) 'dpModelId': dpModelId,
        if (expr != null) 'expr': expr!.toMap(),
        if (city != null) 'city': city!.toMap(),
        if (geoType != null) 'geoType': geoType!.index,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
        if (geoTitle != null) 'geoTitle': geoTitle,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (entitySubIds != null) 'entitySubIds': entitySubIds,
        if (memberIds != null) 'memberIds': memberIds,
        if (memberNames != null) 'memberNames': memberNames,
      };
}

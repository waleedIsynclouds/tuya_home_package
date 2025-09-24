// ──────────────────────────────────────────────────────────────────────────
// Enumerations that match the native SDK
// ──────────────────────────────────────────────────────────────────────────
enum SceneExprKind {
  boolValue,
  enumValue,
  compareValue,
  raw,
  timer,
  sunTimer,
  geofence,
  calculate,
  memberBackHome,
}

enum ExprEntityType {
  /// The whether expr model type
  kExprTypeWhether,

  /// The device expr model type
  kExprTypeDevice
} // matches `ExprType`

enum SunType {
  /// The sun not determine type
  kSunTypeNotDetermin,

  /// The sun rise
  kSunTypeRise,

  /// The sun set type
  kSunTypeSet
} // matches `SunType`

enum GeoType {
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
} // matches `GeoFenceType`

// ──────────────────────────────────────────────────────────────────────────
// Simple DTO for a city (mirrors ThingSmartCityModel)
// ──────────────────────────────────────────────────────────────────────────
class ThingSmartCityFactory {
  const ThingSmartCityFactory({
    required this.cityId,
    required this.city,
    this.area,
    this.pinyin,
    this.province,
    this.latitude,
    this.longitude,
  });

  final int cityId;
  final String city;
  final String? area;
  final String? pinyin;
  final String? province;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toMap() => {
        'cityId': cityId,
        'city': city,
        if (area != null) 'area': area,
        if (pinyin != null) 'pinyin': pinyin,
        if (province != null) 'province': province,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

// ──────────────────────────────────────────────────────────────────────────
// Expression factory (private ctor + public helpers)
// ──────────────────────────────────────────────────────────────────────────
class ThingSmartSceneExprFactory {
  const ThingSmartSceneExprFactory._({
    required this.kind,
    this.type,
    this.exprType,
    this.isTrue,
    this.chooseValue,
    this.compareOperator,
    this.timeZoneId,
    this.loops,
    this.date,
    this.time,
    this.city,
    this.sunType,
    this.deltaMinutes,
    this.geoFenceType,
    this.dpId,
    this.dpType,
    this.selectedValue,
    this.memberIds,
  });

  // ───── Bool ─────
  static ThingSmartSceneExprFactory boolExpr({
    required String type,
    required bool isTrue,
    required ExprEntityType exprType,
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.boolValue,
        type: type,
        isTrue: isTrue,
        exprType: exprType,
      );

  // ───── Enum ─────
  static ThingSmartSceneExprFactory enumExpr({
    required String type,
    required String chooseValue,
    required ExprEntityType exprType,
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.enumValue,
        type: type,
        chooseValue: chooseValue,
        exprType: exprType,
      );

  // ───── Numeric compare ─────
  static ThingSmartSceneExprFactory createValueExpr({
    required String type,
    required String compareOperator, // "<=", ">=", "=="
    required int chooseValue,
    required ExprEntityType exprType,
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.compareValue,
        type: type,
        compareOperator: compareOperator,
        chooseValue: chooseValue,
        exprType: exprType,
      );

  // ───── Raw ─────
  static ThingSmartSceneExprFactory rawExpr({
    required String type,
    required ExprEntityType exprType,
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.raw,
        type: type,
        exprType: exprType,
      );

  // ───── Timer ─────
  static ThingSmartSceneExprFactory timerExpr({
    required String timeZoneId,
    required String loops, // "0111110"
    required String date, // "yyyyMMdd"
    required String time, // "HH:mm"
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.timer,
        timeZoneId: timeZoneId,
        loops: loops,
        date: date,
        time: time,
      );

  // ───── Sunrise / sunset timer ─────
  static ThingSmartSceneExprFactory sunTimerExpr({
    required ThingSmartCityFactory city,
    required SunType sunType,
    required int deltaMinutes, // -300 … +300
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.sunTimer,
        city: city,
        sunType: sunType,
        deltaMinutes: deltaMinutes,
      );

  // ───── Geofence ─────
  static ThingSmartSceneExprFactory geofenceExpr({
    required GeoType type,
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.geofence,
        geoFenceType: type,
      );

  // ───── Calculate ─────
  static ThingSmartSceneExprFactory calculateExpr({
    required String dpId,
    required String dpType, // "bool" | "enum"
    required Object selectedValue, // bool or String
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.calculate,
        dpId: dpId,
        dpType: dpType,
        selectedValue: selectedValue,
      );

  // ───── Member back home ─────
  static ThingSmartSceneExprFactory memberBackHomeExpr({
    required String memberIds, // comma‑separated
  }) =>
      ThingSmartSceneExprFactory._(
        kind: SceneExprKind.memberBackHome,
        memberIds: memberIds,
      );

  // ────────────────────────────────────────────────────────────────────
  // Fields
  // ────────────────────────────────────────────────────────────────────
  final SceneExprKind kind;
  final String? type;
  final ExprEntityType? exprType;
  final bool? isTrue;

  final String? compareOperator;
  final dynamic chooseValue;

  // Timer
  final String? timeZoneId;
  final String? loops;
  final String? date;
  final String? time;

  // Sun timer
  final ThingSmartCityFactory? city;
  final SunType? sunType;
  final int? deltaMinutes;

  // Geofence
  final GeoType? geoFenceType;

  // Calculate
  final String? dpId;
  final String? dpType;
  final Object? selectedValue;

  // Member back home
  final String? memberIds;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        if (type != null) 'type': type,
        if (exprType != null) 'exprType': exprType!.index,
        if (isTrue != null) 'isTrue': isTrue,
        if (chooseValue != null) 'chooseValue': chooseValue,
        if (compareOperator != null) 'compareOperator': compareOperator,
        if (timeZoneId != null) 'timeZoneId': timeZoneId,
        if (loops != null) 'loops': loops,
        if (date != null) 'date': date,
        if (time != null) 'time': time,
        if (city != null) 'city': city!.toMap(),
        if (sunType != null) 'sunType': sunType!.index,
        if (deltaMinutes != null) 'deltaMinutes': deltaMinutes,
        if (geoFenceType != null) 'geoFenceType': geoFenceType!.index,
        if (dpId != null) 'dpId': dpId,
        if (dpType != null) 'dpType': dpType,
        if (selectedValue != null) 'selectedValue': selectedValue,
        if (memberIds != null) 'memberIds': memberIds,
      };
}

import '../tuya_home_sdk_flutter.dart';
import 'room_model.dart';
import 'schema_model.dart';

class ThingSmartDeviceModel {
  /// The unique identifier of the device.
  final String uuid;

  /// The identifier of the product that this device belongs to.
  final String productId;

  /// The URL of the device icon.
  final String iconUrl;

  /// The name of the device.
  final String name;

  /// The device's schema in JSON string format.
  final String? schema;

  /// The device's schema in parsed array format.
  final List<ThingSmartSchemaModel>? schemaArr;

  /// The local key of the device.
  final String? localKey;

  /// The longitude of the device's geographical location.
  final String? longitude;

  /// The access type of the device.
  final int? accessType;

  /// Whether the device is currently upgrading.
  final bool upgrading;

  /// The low power value of the device.
  final double? lpv;

  /// The identifier of the device.
  final String? devId;

  /// Whether the device is currently online.
  final bool isOnline;

  /// The last active time of the device.
  final double? activeTime;

  /// The id of the room that this device belongs to.
  final int? roomId;

  /// The id of the home that this device belongs to.
  final int? homeId;

  /// Whether the device's Mesh BLE is online.
  final bool isMeshBleOnline;

  /// Whether the device is a standard device.
  final bool standard;

  /// The capability of the device.
  final int? capability;

  /// Whether the device is currently online on the cloud.
  final bool isCloudOnline;

  /// The latitude of the device's geographical location.
  final String? latitude;

  /// The time the device was shared.
  final int? sharedTime;

  /// Whether the device is currently online locally.
  final bool isLocalOnline;

  /// The current DPS of the device.
  Map? dps;

  /// The product version of the device.
  final String? pv;

  /// Whether the device is shared.
  final bool isShare;

  /// The display order of the device in the home.
  final int? homeDisplayOrder;

  /// The timezone of the device.
  final String? timezoneId;

  /// The key of the device.
  final String? devKey;

  /// Whether the device supports group control.
  final bool supportGroup;

  /// The category of the device.
  final String? category;

  /// The category code of the device.
  final String? categoryCode;

  /// The customized attribute of the device.
  final String? cadv;

  /// The DP name of the device.
  final Map? dpName;

  /// The product version of the device.
  final String? productVer;

  /// The UI ID of the device.
  final String? uiId;

  /// The vendor information of the device.
  final String? vendorInfo;

  /// Mac address of the device
  final String? mac;

  ThingSmartDeviceModel.fromJson(Map<String, dynamic> json)
      : localKey = json["localKey"],
        longitude = json["longitude"],
        accessType = json["accessType"],
        upgrading = json["upgrading"] ?? false,
        lpv = json["lpv"],
        devId = json["devId"],
        isOnline = json["isOnline"] ?? false,
        uuid = json["uuid"],
        activeTime = json["activeTime"],
        roomId = json["roomId"],
        homeId = json["homeId"],
        isMeshBleOnline = json["isMeshBleOnline"] ?? false,
        standard = json["standard"] ?? false,
        capability = json["capability"],
        isCloudOnline = json["isCloudOnline"] ?? false,
        latitude = json["latitude"],
        sharedTime = json["sharedTime"],
        isLocalOnline = json["isLocalOnline"] ?? false,
        dps = json["dps"],
        pv = json["pv"]?.toString(),
        iconUrl = json["iconUrl"],
        isShare = json["isShare"] ?? false,
        homeDisplayOrder = json["homeDisplayOrder"],
        timezoneId = json["timezoneId"],
        devKey = json["devKey"],
        productId = json["productId"],
        mac = json["mac"],
        supportGroup = json["supportGroup"] ?? false,
        name = json["name"],
        schema = json["schema"],
        category = json["category"],
        cadv = json['cadv'],
        dpName = json['dpName'],
        categoryCode = json["categoryCode"],
        schemaArr = json["schema"] == null
            ? null
            : thingSmartSchemaModelFromJson(json["schema"]),
        uiId = json["uiId"],
        vendorInfo = json["vendorInfo"],
        productVer = json["productVer"];

  /// ToJson
  ///
  /// This function returns a map that can be serialized to JSON.
  /// The map contains all the information about the device that
  /// is known to the SDK.
  Map<String, dynamic> toJson() => {
        /// The localKey of the device
        "localKey": localKey,

        /// The longitude of the device
        "longitude": longitude,

        /// The accessType of the device
        ///
        /// See [THETING_ACCESS_TYPE] for possible values
        "accessType": accessType,

        /// Whether the device is being upgraded
        "upgrading": upgrading,

        /// The lpv of the device
        "lpv": lpv,

        /// The device ID of the device
        "devId": devId,

        /// Whether the device is online
        "isOnline": isOnline,

        /// The UUID of the device
        "uuid": uuid,

        /// The last time the device was active
        "activeTime": activeTime,

        /// The room ID of the device
        "roomId": roomId,

        /// The home ID of the device
        "homeId": homeId,

        /// Whether the device is online (using mesh)
        "isMeshBleOnline": isMeshBleOnline,

        /// Whether the device supports standard functionality
        "standard": standard,

        /// The capabilities of the device
        "capability": capability,

        /// Whether the device is online (using Tuya Cloud)
        "isCloudOnline": isCloudOnline,

        /// The latitude of the device
        "latitude": latitude,

        /// The time the device was shared
        "sharedTime": sharedTime,

        /// Whether the device is online (using local network)
        "isLocalOnline": isLocalOnline,

        /// The DPS of the device
        "dps": dps,

        /// The PV of the device
        "pv": pv,

        /// The icon URL of the device
        "iconUrl": iconUrl,

        /// Whether the device is shared
        "isShare": isShare,

        /// The order in the home of the device
        "homeDisplayOrder": homeDisplayOrder,

        /// The time zone ID of the device
        "timezoneId": timezoneId,

        /// The developer key of the device
        "devKey": devKey,

        /// The product ID of the device
        "productId": productId,

        /// Whether the device supports group functions
        "supportGroup": supportGroup,

        /// The name of the device
        "name": name,

        /// The schema of the device
        "schema": schema,

        /// The category of the device
        "category": category,

        /// The cadv of the device
        "cadv": cadv,

        /// The dpName of the device
        "dpName": dpName,

        /// The category code of the device
        "categoryCode": categoryCode,

        /// The UI ID of the device
        "uiId": uiId,

        /// The vendor info of the device
        "vendorInfo": vendorInfo,

        /// The product version of the device
        "productVer": productVer,

        /// Mac address of the device
        "mac": mac,
      };

  /// Remove this device from the home.
  ///
  /// Returns whether the device was removed successfully.
  ///
  /// See also:
  ///  * [TuyaHomeSdkFlutter.removeDevice]
  Future<bool> remove() async {
    final res = await TuyaHomeSdkFlutter.instance.removeDevice(
      deviceId: devId!,
    );
    return res;
  }

  /// Renames this device.
  ///
  /// This method sends a request to rename the device with the given [name].
  /// It returns a [Future] that completes with a [bool] value indicating whether
  /// the renaming was successful or not.
  ///
  /// Throws:
  /// - [AssertionError] if [name] is empty.
  /// - [PlatformException] if an error occurs during the renaming process.
  ///

  Future<bool> renameDevice({required String name}) =>
      TuyaHomeSdkFlutter.instance.renameDevice(deviceId: devId!, name: name);

  Future<ThingSmartRoomModel?> getRoom() async {
    try {
      if (roomId == null || roomId == 0) {
        return null;
      }
      final res = await TuyaHomeSdkFlutter.instance.getHomeRooms(
        homeId: homeId!,
      );

      return res.firstWhere((room) => room.id == roomId);
    } on Exception {
      return null;
    }
  }

  /// Publishes the specified DPS (Data Point Set) to the device.
  ///
  /// This method sends the provided DPS to the device identified by [devId].
  /// The DPS is a map of key-value pairs, where the key represents the
  /// data point identifier and the value represents the new value to be set.
  /// The DPS is used to control various aspects of the device, such as turning
  /// on/off lights, adjusting temperature, etc.
  ///
  /// Example usage:
  /// ```dart
  /// publishDps(dps: {
  ///   '1': true, // Turn on the light
  ///   '2': 25,   // Set temperature to 25 degrees
  /// });
  /// ```
  ///
  /// Throws an exception if the operation fails.
  ///
  /// See also:
  ///  * [TuyaHomeSdkFlutter.instance.publishDps], the method used to publish DPS.
  ///  * [onDeviceDpsUpdated], a method to listen for updates to the device's DPS.
  ///  * [remove], a method to remove the device from the home.
  ///  * [TuyaHomeSdkFlutter], the class representing the Tuya Home SDK Flutter.
  ///  * [devId], the unique identifier of the device.
  ///  * [dps], the map of DPS to be published to the device.
  void publishDps({required Map<String, dynamic> dps}) async {
    await TuyaHomeSdkFlutter.instance.publishDps(deviceId: devId!, dps: dps);
  }

  /// Returns a stream that emits dynamic values whenever the DPS (Data Point Set) of the device with the specified [devId] is updated.
  ///
  /// This stream can be used to listen for updates to the device's DPS, which represents the current state of the device and can be used to control various aspects of the device.
  ///
  /// Example usage:
  /// ```dart
  /// final stream = onDeviceDpsUpdated();
  /// stream.listen((dps) {
  ///   // Handle updated DPS values
  ///   print('Updated DPS: $dps');
  /// });
  /// ```
  ///
  /// See also:
  ///  * [TuyaHomeSdkFlutter.instance.onDeviceDpsUpdated], the method used to create the stream.
  ///  * [devId], the unique identifier of the device.
  ///  * [Stream], the class representing a stream of values in Dart.
  ///  * [listen], a method to subscribe to the stream and handle emitted values.
  ///  * [cancel], a method to cancel the subscription to the stream.
  ///  * [TuyaHomeSdkFlutter], the class representing the Tuya Home SDK Flutter.
  ///  * [deviceId], the unique identifier of the device.
  ///  * [dps], the map of DPS values representing the updated state of the device.
  Stream<dynamic> onDeviceDpsUpdated() {
    return TuyaHomeSdkFlutter.instance.onDeviceDpsUpdated(deviceId: devId!);
  }
}

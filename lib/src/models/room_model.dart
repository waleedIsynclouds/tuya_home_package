import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../tuya_home_sdk_flutter.dart';

class ThingSmartRoomModel {
  /// The ID of the room.
  int id;

  /// The name of the room.
  String name;

  num? _homeId;

  ThingSmartRoomModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _homeId = json['homeId'],
        name = json['name'];

  /// Updates the room with the specified new name.
  ///
  /// Makes an asynchronous call to the platform channel to invoke the 'updateRoom'
  /// method, passing the [id] and [newName] as parameters. It expects a boolean
  /// value as a result. If the result is null, returns false. If any error occurs
  /// during the method call, it is logged using the [debugPrint] method and false
  /// is returned.
  ///
  /// Parameters:
  /// - [newName]: The new name of the room.
  ///
  /// Returns:
  /// - A boolean value indicating whether the room was updated successfully.
  ///   If the room could not be updated or an error occurs, returns false.
  ///
  /// Throws:
  /// - None.
  Future<bool> updateRoom({required String newName}) async {
    try {
      final res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMethod<bool>('updateRoom',
              {'roomId': id, 'roomName': newName, 'homeId': _homeId});
      return res ?? false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

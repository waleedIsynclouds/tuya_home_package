import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class TuyaHomeSdkFlutter {
  final methodChannel = const MethodChannel('tuya_home_sdk_flutter');
  final _deviceEvent =
      const EventChannel('tuya_home_sdk_flutter_device_dps_event');
  final _deviceDiscoveryEvent =
      const EventChannel('tuya_home_sdk_flutter_device_discovery_event');
  static const tag = "Tuya";

  TuyaHomeSdkFlutter._();

  static TuyaHomeSdkFlutter? _singleton;

  static TuyaHomeSdkFlutter get instance {
    return _singleton ??= TuyaHomeSdkFlutter._();
  }

  /// Initializes the Tuya Home SDK with the provided app key and app secret.
  ///
  /// The [appKey] is used to authenticate the Tuya Home SDK.
  /// The [appSecret] is used to authenticate the Tuya Home SDK.
  /// The [isDebug] flag indicates whether the SDK should run in debug mode. It defaults to the value of [kDebugMode].
  ///
  /// Example Usage:
  /// ```dart
  /// await initSdk('your_app_key', 'your_app_secret');
  /// ```
  ///
  /// Throws an [AssertionError] if the [appKey] is empty or contains whitespace characters.
  /// Throws an [AssertionError] if the [appSecret] is empty or contains whitespace characters.
  ///
  /// Logs a message indicating that the Tuya SDK has been started.
  /// Prints a debug message indicating that the Tuya SDK has been started.
  Future<void> initSdk(String appKey, String appSecret, String key,
      {bool isDebug = kDebugMode}) async {
    assert(
      appKey.isNotEmpty || appKey.contains(" "),
      "AppKey can't be empty or contains whitespaces",
    );
    assert(
      appSecret.isNotEmpty || appSecret.contains(" "),
      "AppSecret can't be empty or contains whitespaces",
    );
    var res = await methodChannel.invokeMethod<bool>('initSDK', {
      'appKey': appKey.trim(),
      'appSecret': appSecret.trim(),
      'isDebug': isDebug,
      'key': key
    });
    if (res == true) {
      debugPrint("Tuya Started");
    }
  }

  /// Sends a verification code to a user's username with the specified country code and type.
  ///
  /// Example Usage:
  /// ```dart
  /// bool result = await sendVerifyCodeWithUserName(username: 'john', countryCode: '+1', type: 2);
  /// print(result); // true or false
  /// ```
  ///
  /// Inputs:
  /// - `username` (required): a string representing the user's username
  /// - `countryCode` (required): a string representing the country code
  /// - `type` (required): an integer representing the type of verification code
  ///
  /// Flow:
  /// 1. The method checks if the `countryCode` and `username` are not empty and if the `type` is between 1 and 3.
  /// 2. If the assertions pass, the method invokes the `sendVerifyCodeWithUserName` method on the `methodChannel` with the provided parameters.
  /// 3. The method waits for the result and returns it.
  /// 4. If an exception occurs during the method invocation, it is logged and `false` is returned.
  ///
  /// Outputs:
  /// - Returns a boolean value indicating whether the verification code was successfully sent or not.
  Future<bool> sendVerifyCodeWithUserName(
      {required String username,
      required String countryCode,
      required int type}) async {
    assert(countryCode.isNotEmpty);
    assert(username.isNotEmpty);
    assert(type > 0 && type <= 3);
    try {
      var res =
          await methodChannel.invokeMethod<bool>('sendVerifyCodeWithUserName', {
        'username': username.trim(),
        'country_code': countryCode.trim(),
        'type': type,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Checks a verification code with a given username, country code, code, and type.
  ///
  /// The method invokes a method on a `methodChannel` object to perform the check and returns a boolean result.
  ///
  /// Example Usage:
  /// ```dart
  /// bool result = await checkCodeWithUserName(
  ///   username: "john@example.com",
  ///   countryCode: "+1",
  ///   code: "123456",
  ///   type: 1,
  /// );
  /// print(result); // true or false
  /// ```
  ///
  /// Inputs:
  /// - `username` (required): a string representing the username or email address.
  /// - `countryCode` (required): a string representing the country code.
  /// - `code` (required): a string representing the verification code.
  /// - `type` (required): an integer representing the type of verification code.
  ///
  /// Flow:
  /// 1. The method checks if the `countryCode`, `username`, `type`, and `code` inputs are not empty or null.
  /// 2. It invokes the `invokeMethod` method on the `methodChannel` object with the method name `'checkCodeWithUserName'` and a map of parameters including the `username`, `countryCode`, `code`, and `type`.
  /// 3. If the invocation is successful, it returns the result as a boolean value.
  /// 4. If an exception occurs during the invocation, it logs the exception and returns false.
  ///
  /// Outputs:
  /// - The method returns a boolean value indicating whether the verification code is valid or not.
  Future<bool> checkCodeWithUserName({
    required String username,
    required String countryCode,
    required String code,
    required int type,
  }) async {
    assert(countryCode.isNotEmpty);
    assert(username.isNotEmpty);
    assert(type > 0 && type <= 3);
    assert(code.isNotEmpty && code.length == 6);
    try {
      var res =
          await methodChannel.invokeMethod<bool>('checkCodeWithUserName', {
        'username': username.trim(),
        'country_code': countryCode.trim(),
        'code': code.trim(),
        'type': type,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Registers a user by username.
  ///
  /// This method registers a user using the provided username, country code, verification code, and password.
  /// It performs the following steps:
  /// 1. Checks if the country code, username, password, and verification code are not empty.
  /// 2. Checks if the verification code has a length of 6 characters.
  /// 3. Invokes the 'registerByUserName' method on the 'methodChannel' with the provided parameters.
  /// 4. Returns the result of the method invocation.
  /// 5. If an error occurs during the method invocation, logs the error and returns false.
  ///
  /// Parameters:
  /// - [username]: The username of the user to register.
  /// - [countryCode]: The country code of the user's phone number.
  /// - [code]: The verification code received by the user.
  /// - [password]: The password for the user's account.
  ///
  /// Returns:
  /// - A [Future] that completes with a [bool] indicating whether the registration was successful.
  ///   Returns true if the registration was successful, false otherwise.
  ///
  /// Throws:
  /// - Throws an [AssertionError] if the country code, username, password, or verification code is empty.
  /// - Throws an [AssertionError] if the verification code does not have a length of 6 characters.
  /// - Throws a [PlatformException] if an error occurs during the method invocation.
  ///
  /// Example usage:
  /// ```dart
  /// bool registrationResult = await registerByUserName(
  ///   username: 'john_doe',
  ///   countryCode: '+1',
  ///   code: '123456',
  ///   password: 'password123',
  /// );
  /// ```
  ///

  Future<bool> registerByUserName(
      {required String username,
      required String countryCode,
      required String code,
      required String password}) async {
    assert(countryCode.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);
    assert(code.isNotEmpty && code.length == 6);
    try {
      var res = await methodChannel.invokeMethod<bool>('registerByUserName', {
        'username': username.trim(),
        'country_code': countryCode.trim(),
        'code': code.trim(),
        'password': password,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Registers a user by phone.
  ///
  /// This method registers a user using the provided username, country code, verification code, and password.
  /// It performs the following steps:
  /// 1. Checks if the country code, username, password, and verification code are not empty.
  /// 2. Checks if the verification code has a length of 6 characters.
  /// 3. Invokes the 'registerByUserName' method on the 'methodChannel' with the provided parameters.
  /// 4. Returns the result of the method invocation.
  /// 5. If an error occurs during the method invocation, logs the error and returns false.
  ///
  /// Parameters:
  /// - [phone]: The phone of the user to register.
  /// - [countryCode]: The country code of the user's phone number.
  /// - [code]: The verification code received by the user.
  /// - [password]: The password for the user's account.
  ///
  /// Returns:
  /// - A [Future] that completes with a [bool] indicating whether the registration was successful.
  ///   Returns true if the registration was successful, false otherwise.
  ///
  /// Throws:
  /// - Throws an [AssertionError] if the country code, username, password, or verification code is empty.
  /// - Throws an [AssertionError] if the verification code does not have a length of 6 characters.
  /// - Throws a [PlatformException] if an error occurs during the method invocation.
  ///
  /// Example usage:
  /// ```dart
  /// bool registrationResult = await registerByUserName(
  ///   username: '12345678',
  ///   countryCode: '+1',
  ///   code: '123456',
  ///   password: 'password123',
  /// );
  /// ```
  ///

  Future<bool> registerByPhone(
      {required String phone,
      required String countryCode,
      required String code,
      required String password}) async {
    assert(countryCode.isNotEmpty);
    assert(phone.isNotEmpty);
    assert(password.isNotEmpty);
    assert(code.isNotEmpty && code.length == 6);
    try {
      var res = await methodChannel.invokeMethod<bool>('registerByPhone', {
        'username': phone.trim(),
        'country_code': countryCode.trim(),
        'code': code.trim(),
        'password': password,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Logs in a user with the provided username, country code, and password.
  ///
  /// The [username] parameter is the username of the user.
  /// The [countryCode] parameter is the country code of the user's phone number.
  /// The [password] parameter is the password of the user.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the login was successful or not.
  /// If the login is successful, the value is true. Otherwise, the value is false.
  /// If an error occurs during the login process, the error is logged and the value is false.
  ///
  /// Throws an [AssertionError] if the [countryCode], [username], or [password] is empty.
  ///
  /// Example usage:
  /// ```dart
  /// bool success = await loginWithUserName(username: 'john', countryCode: '+1', password: 'password123');
  /// if (success) {
  ///   print('Login successful');
  /// } else {
  ///   print('Login failed');
  /// }
  /// ```
  ///
  Future<bool> loginWithUserName(
      {required String username,
      required String countryCode,
      required String password}) async {
    assert(countryCode.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);

    try {
      var res = await methodChannel.invokeMethod<bool>('loginWithUserName', {
        'username': username.trim(),
        'country_code': countryCode.trim(),
        'password': password,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Logs in a user with the provided phone, country code, and password.
  ///
  /// The [phone] parameter is the username of the user.
  /// The [countryCode] parameter is the country code of the user's phone number.
  /// The [password] parameter is the password of the user.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the login was successful or not.
  /// If the login is successful, the value is true. Otherwise, the value is false.
  /// If an error occurs during the login process, the error is logged and the value is false.
  ///
  /// Throws an [AssertionError] if the [countryCode], [phone], or [password] is empty.
  ///
  /// Example usage:
  /// ```dart
  /// bool success = await loginWithUserName(phone: '12345678', countryCode: '+1', password: 'password123');
  /// if (success) {
  ///   print('Login successful');
  /// } else {
  ///   print('Login failed');
  /// }
  /// ```
  ///
  Future<bool> loginWithPhonePassword(
      {required String phone,
      required String countryCode,
      required String password}) async {
    assert(countryCode.isNotEmpty);
    assert(phone.isNotEmpty);
    assert(password.isNotEmpty);

    try {
      var res =
          await methodChannel.invokeMethod<bool>('loginWithPhonePassword', {
        'username': phone.trim(),
        'country_code': countryCode.trim(),
        'password': password,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Logs in a user with the provided phone, country code, and code.
  ///
  /// The [phone] parameter is the username of the user.
  /// The [countryCode] parameter is the country code of the user's phone number.
  /// The [code] parameter is the otp code of the user.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the login was successful or not.
  /// If the login is successful, the value is true. Otherwise, the value is false.
  /// If an error occurs during the login process, the error is logged and the value is false.
  ///
  /// Throws an [AssertionError] if the [countryCode], [phone], or [code] is empty.
  ///
  /// Example usage:
  /// ```dart
  /// bool success = await loginWithUserName(phone: '12345678', countryCode: '+1', code: '6123');
  /// if (success) {
  ///   print('Login successful');
  /// } else {
  ///   print('Login failed');
  /// }
  /// ```
  ///
  Future<bool> loginWithPhoneCode(
      {required String phone,
      required String countryCode,
      required String code}) async {
    assert(countryCode.isNotEmpty);
    assert(phone.isNotEmpty);
    assert(code.isNotEmpty);

    try {
      var res = await methodChannel.invokeMethod<bool>('loginWithPhoneCode', {
        'username': phone.trim(),
        'country_code': countryCode.trim(),
        'code': code,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Logs in with an authorization token.
  ///
  /// The [type] parameter is a two-character string indicating the type third party login ex: ap (apple) , gg (google), fb (facebook).
  /// The [countryCode] parameter is the country code of the user's phone number.
  /// The [accessToken] parameter is the authorization token to use for login.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the login was successful or not.
  /// If the login is successful, the value is true. Otherwise, the value is false.
  /// If an error occurs during the login process, the error is logged and the value is false.
  ///
  /// Throws an [AssertionError] if the [countryCode], [type], or [accessToken] is empty.
  ///
  Future<bool> loginByAuth2(
      {required String type,
      required String countryCode,
      required String accessToken}) async {
    assert(countryCode.isNotEmpty);
    assert(
        type.isNotEmpty && type.length == 2 && (type == "ap" || type == "gg"));
    assert(accessToken.isNotEmpty);

    try {
      var res = await methodChannel.invokeMethod<bool>('loginByAuth2', {
        'type': type.trim(),
        'country_code': countryCode.trim(),
        'access_token': accessToken,
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Resets a user's password with the provided username, country code, code, and password.
  ///
  /// The [username] parameter is the username of the user.
  /// The [countryCode] parameter is the country code of the user's phone number.
  /// The [code] parameter is the verification code sent to the user's phone number.
  /// The [password] parameter is the new password of the user.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the password was successfully reset or not.
  /// If the password was successfully reset, the value is true. Otherwise, the value is false.
  /// If an error occurs during the password reset process, the error is logged and the value is false.
  ///
  /// Throws an [AssertionError] if the [countryCode], [username], [code], or [password] is empty.
  ///
  /// Example usage:
  ///
  Future<bool> resetPasswordByEmail(
      {required String username,
      required String countryCode,
      required String code,
      required String password}) async {
    assert(countryCode.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);
    assert(code.isNotEmpty && code.length == 6);

    try {
      var res = await methodChannel.invokeMethod<bool>('resetPasswordByEmail', {
        'username': username.trim(),
        'country_code': countryCode.trim(),
        'password': password,
        'code': code
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Retrieves the user information from the Tuya Home SDK.
  ///
  /// This method makes an asynchronous call to the `getUserInfo` method of the `methodChannel` to retrieve the user information.
  /// It returns a `Future` that resolves to a `ThingSmartUserModel` object representing the user information.
  /// If the call is successful, the user information is parsed from the response using the `ThingSmartUserModel.fromJson` method.
  /// If an error occurs during the call, the error is logged using the `_log` method and `null` is returned.
  ///
  /// Returns:
  /// - A `Future` that resolves to a `ThingSmartUserModel` object representing the user information.
  ///   Returns `null` if an error occurs during the call.
  ///
  /// Example usage:
  /// ```dart
  /// ThingSmartUserModel? userInfo = await getUserInfo();
  /// if (userInfo != null) {
  ///   // Use the user information
  /// } else {
  ///   // Handle the error
  /// }
  /// ```
  ///
  Future<ThingSmartUserModel?> getUserInfo() async {
    try {
      var res = await methodChannel.invokeMethod('getUserInfo');
      return ThingSmartUserModel.fromJson(res.cast<String, dynamic>());
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Updates the user icon with the provided [icon].
  ///
  /// Returns a [Future] that completes with a [ThingSmartUserModel] if the icon update is successful,
  /// or `null` if the update fails.
  ///
  /// If the update is successful, the method also calls [getUserInfo] to retrieve the updated user information.
  ///
  /// If an error occurs during the update, the error is logged using [_log] and `null` is returned.
  ///
  /// The [icon] parameter is optional. If not provided, the user icon will not be updated.
  ///
  /// Throws a [PlatformException] if there is an error during the method invocation.
  ///
  /// Example usage:
  /// ```dart
  /// ThingSmartUserModel? updatedUser = await updateUserIcon(icon: 'iconData');
  /// ```
  ///
  /// Note: This method should be called after the user is logged in.
  ///
  /// See also:
  ///
  /// - [getUserInfo], which retrieves the user information after the icon update.
  /// - [_log], which logs any errors that occur during the update.
  /// - [PlatformException], which is thrown if there is an error during the method invocation.
  @Deprecated(
      'Deprecated from Tuya, Will be removed in the future, please maintain user avatar by yourself')
  Future<ThingSmartUserModel?> updateUserIcon({
    String? icon,
  }) async {
    try {
      var res = await methodChannel
          .invokeMethod('updateUserIcon', {'iconData': icon});
      if (res) {
        return getUserInfo();
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Updates the nickname of the user.
  ///
  /// This method updates the nickname of the user with the provided [nickname].
  /// If the [nickname] is null, then null is returned.
  ///
  /// Returns:
  /// - [ThingSmartUserModel] if the nickname is updated successfully.
  /// - null if the [nickname] is null or the update fails.
  ///
  /// Throws:
  /// - [PlatformException] if an error occurs during the update process.
  /// - [Exception] if an unknown error occurs.
  ///
  /// Example usage:
  /// ```dart
  /// ThingSmartUserModel? user = await updateUserNickName(nickname: "John Doe");
  /// if (user != null) {
  ///   print("Nickname updated successfully");
  /// } else {
  ///   print("Failed to update nickname");
  /// }
  ///
  Future<ThingSmartUserModel?> updateUserNickName({
    String? nickname,
  }) async {
    if (nickname == null) {
      return null;
    }
    try {
      var res = await methodChannel.invokeMethod('updateUserNickName', {
        'nickname': nickname,
      });
      if (res) {
        return getUserInfo();
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Assigns a device to a room in the Tuya Home SDK.
  ///
  /// If the [roomId] is less than or equal to 0, the device will not be assigned to any room.
  /// Otherwise, the [deviceId], [homeId], and [roomId] are passed to the `assignDeviceToRoom` method of the [methodChannel].
  /// The result of the method call is returned as a boolean value.
  /// If an error occurs during the method call, the error is logged and false is returned.
  ///
  /// Returns true if the device is successfully assigned to the room, false otherwise.
  /// Throws a [PlatformException] if an error occurs during the method call.

  Future<bool> assignDeviceToRoom({
    required String deviceId,
    required num homeId,
    required num roomId,
  }) async {
    // client choose to assign device to home
    if (roomId <= 0) {
      return true;
    }
    try {
      var res = await methodChannel.invokeMethod(
        'assignDeviceToRoom',
        {
          'deviceId': deviceId,
          'homeId': homeId,
          'roomId': roomId,
        },
      );
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Adds a home with the specified name, geographical name, rooms, latitude, and longitude.
  ///
  /// Example Usage:
  /// ```dart
  /// TuyaHomeSdkFlutter tuyaSdk = TuyaHomeSdkFlutter.instance;
  /// String name = "My Home";
  /// String geoName = "My Geo";
  /// List<String> rooms = ["Living Room", "Bedroom"];
  /// Double latitude = 37.7749;
  /// Double longitude = -122.4194;
  ///
  /// var result = await tuyaSdk.addHomeWithName(
  ///   name: name,
  ///   geoName: geoName,
  ///   rooms: rooms,
  ///   latitude: latitude,
  ///   longitude: longitude,
  /// );
  /// print(result);
  /// ```
  ///
  /// Inputs:
  /// - `name` (String): The name of the home to be added.
  /// - `geoName` (String): The geographical name of the home.
  /// - `rooms`: The list of rooms in the home.
  /// - `latitude` (Double): The latitude coordinate of the home's location.
  /// - `longitude` (Double): The longitude coordinate of the home's location.
  ///
  /// Outputs:
  /// - The result of the native method call, which can be of any type.
  ///
  /// Throws:
  /// - [PlatformException] if an error occurs while invoking the native platform method.
  ///
  Future<num?> addHomeWithName({
    required String name,
    required String geoName,
    List<String> rooms = const [''],
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    try {
      var res = await methodChannel.invokeMethod<num>('addHomeWithName', {
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "geoName": geoName,
        "rooms": rooms,
      });
      return res;
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Updates a home with the specified parameters.
  ///
  /// - [homeId]: The ID of the home to update.
  /// - [name]: The new name of the home.
  /// - [geoName]: The new geo name of the home.
  /// - [rooms]: The new list of rooms in the home.
  /// - [latitude]: The new latitude of the home. Defaults to 0.0.
  /// - [longitude]: The new longitude of the home. Defaults to 0.0.
  ///
  /// Returns `true` if the home is updated successfully, `false` otherwise.
  /// If an error occurs during the update, the error is logged and `false` is returned.
  Future<bool> updateHome({
    required num homeId,
    required String name,
    required String geoName,
    required List<String> rooms,
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    try {
      var res = await methodChannel.invokeMethod<bool>('updateHome', {
        "name": name,
        "homeId": homeId,
        "latitude": latitude,
        "longitude": longitude,
        "geoName": geoName,
        "rooms": rooms,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Removes a home with the specified home ID.
  ///
  /// Returns `true` if the home is successfully removed, otherwise `false`.
  ///
  /// Throws a [PlatformException] if an error occurs during the removal process.
  ///
  /// Example usage:
  /// ```dart
  /// bool result = await removeHome(homeId: 123);
  /// ```
  ///
  /// Note: The [homeId] parameter is required and must be a non-negative number.

  Future<bool> removeHome({
    required num homeId,
  }) async {
    try {
      var res = await methodChannel.invokeMethod<bool>('removeHome', {
        "homeId": homeId,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Retrieves a list of ThingSmartHomeModel objects representing the homes associated with the user.
  ///
  /// Returns a Future that resolves to a List of ThingSmartHomeModel objects. If no homes are found, an empty List is returned.
  ///
  /// Throws a PlatformException if an error occurs during the method invocation.
  /// If an error occurs, the method logs the error using the _log() method and returns an empty List.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// List<ThingSmartHomeModel> homes = await getHomeList();
  /// homes.forEach((home) {
  ///   print(home.name);
  /// });
  /// ```
  ///
  /// Note: This method should be called after initializing the TuyaHomeSdkFlutter instance and logging in the user.
  ///
  /// See also:
  ///
  /// - ThingSmartHomeModel: A model class representing a smart home.
  /// - _log(): A private method used to log errors.

  Future<List<ThingSmartHomeModel>> getHomeList() async {
    try {
      var res = await methodChannel.invokeMethod<List<dynamic>>('getHomeList');
      if (res == null) return [];
      return List<ThingSmartHomeModel>.from(res
          .map((e) => ThingSmartHomeModel.fromJson(e.cast<String, dynamic>())));
    } on PlatformException catch (e) {
      _log(e);
      return [];
    }
  }

  /// Retrieves the list of rooms in a home.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke the 'getHomeRooms' method,
  /// passing the [homeId] as a parameter. It expects a list of dynamic objects as a result, which is then
  /// converted into a list of [ThingSmartRoomModel] objects using the `fromJson` method. If the result is null,
  /// an empty list is returned. If any error occurs during the method call, it is logged using the [_log] method
  /// and an empty list is returned.
  ///
  /// Parameters:
  /// - [homeId]: The ID of the home for which to retrieve the rooms.
  ///
  /// Returns:
  /// - A list of [ThingSmartRoomModel] objects representing the rooms in the home. If no rooms are found or an error occurs,
  ///   an empty list is returned.
  ///
  /// Throws:
  /// - None.
  Future<List<ThingSmartRoomModel>> getHomeRooms({
    required num homeId,
  }) async {
    try {
      var res =
          await methodChannel.invokeMethod<List<dynamic>>('getHomeRooms', {
        "homeId": homeId,
      });
      if (res == null) return [];
      return List<ThingSmartRoomModel>.from(res.map((e) {
        var roomJson = e.cast<String, dynamic>();
        roomJson['homeId'] = homeId;
        return ThingSmartRoomModel.fromJson(roomJson);
      }));
    } on PlatformException catch (e) {
      _log(e);
      return [];
    }
  }

  /// Retrieves the token for a specific home ID.
  ///
  /// This method makes an asynchronous call to the `getToken` method of the `methodChannel` to retrieve the token associated with the specified home ID.
  ///
  /// Parameters:
  /// - `homeId` (required): The ID of the home for which the token is to be retrieved.
  ///
  /// Returns:
  /// - A `Future` that resolves to a `String` representing the token for the specified home ID.
  /// - If an error occurs during the retrieval process, the method logs the error using the `_log` method and returns `null`.
  Future<String?> getToken({required num homeId}) async {
    try {
      var res = await methodChannel.invokeMethod<String>('getToken', {
        "homeId": homeId,
      });
      return res;
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Starts the configuration process for a BLE WiFi device.
  ///
  /// This method is used to start the configuration process for a BLE WiFi device. It takes the following parameters:
  /// - `ssid` (required): The SSID of the WiFi network to connect the device to.
  /// - `password` (required): The password of the WiFi network.
  /// - `homeId` (required): The ID of the home where the device is located.
  /// - `deviceUuid` (required): The UUID of the device.
  /// - `deviceProductId` (required): The product ID of the device.
  /// - `timeout` (optional): The timeout value for the configuration process, in milliseconds. Default is 100 milliseconds.
  ///
  /// Returns a [ThingSmartDeviceModel] object representing the configured device, or `null` if an error occurred during the configuration process.
  /// If an error occurs, it will be logged using the `_log` method.
  ///
  /// Example usage:
  /// ```dart
  /// var device = await startConfigBLEWifiDevice(
  ///   ssid: 'MyWiFiNetwork',
  ///   password: 'MyPassword',
  ///   homeId: 123,
  ///   deviceUuid: 'abcd1234',
  ///   deviceProductId: 'xyz789',
  ///   timeout: 200,
  /// );
  /// if (device != null) {
  ///   // Device configuration successful
  /// } else {
  ///   // Error occurred during device configuration
  /// }
  /// ```
  /// Note: This method should be called after initializing the TuyaHomeSdkFlutter instance using the `initSdk` method.
  ///
  Future<ThingSmartDeviceModel?> startConfigBLEWifiDevice({
    required String ssid,
    required String password,
    required num homeId,
    required String deviceUuid,
    required String deviceProductId,
    int timeout = 3000,
  }) async {
    try {
      var res = await methodChannel
          .invokeMethod<dynamic>('startConfigBLEWifiDevice', {
        "ssid": ssid,
        "password": password,
        "homeId": homeId,
        "timeout": timeout,
        "uuid": deviceUuid,
        "productId": deviceProductId
      });
      _log(res);
      return ThingSmartDeviceModel.fromJson(res.cast<String, dynamic>());
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Starts the configuration process for a  WiFi device.
  ///
  /// This method is used to start the configuration process for a WiFi device known as a Access Point. It takes the following parameters:
  /// - `ssid` (required): The SSID of the WiFi network to connect the device to.
  /// - `password` (required): The password of the WiFi network.
  /// - `homeId` (required): The ID of the home where the device is located.

  /// - `timeout` (optional): The timeout value for the configuration process, in milliseconds. Default is 100 milliseconds.
  ///
  /// Returns a [ThingSmartDeviceModel] object representing the configured device, or `null` if an error occurred during the configuration process.
  /// If an error occurs, it will be logged using the `_log` method.
  ///
  /// Example usage:
  /// ```dart
  /// var device = await startConfigWifiDevice(
  ///   ssid: 'MyWiFiNetwork',
  ///   password: 'MyPassword',
  ///   homeId: 123,

  /// );
  /// if (device != null) {
  ///   // Device configuration successful
  /// } else {
  ///   // Error occurred during device configuration
  /// }
  /// ```
  /// Note: This method should be called after initializing the TuyaHomeSdkFlutter instance using the `initSdk` method.
  ///
  Future<ThingSmartDeviceModel?> startConfigWiFiDevice({
    required String ssid,
    required String password,
    required String token,
    int timeout = 3000,
  }) async {
    try {
      var res =
          await methodChannel.invokeMethod<dynamic>('startConfigWiFiDevice', {
        "ssid": ssid,
        "password": password,
        "token": token,
        "timeout": timeout,
      });
      _log(res);
      return ThingSmartDeviceModel.fromJson(res.cast<String, dynamic>());
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Starts the configuration process for a wired device.
  ///
  /// This method is used to start the configuration process for a wired device. It takes the following parameters:
  /// - `token` (required): The token to be used for the configuration process.
  /// - `timeout` (optional): The timeout value for the configuration process, in milliseconds. Default is 3000 milliseconds.
  ///
  /// If the configuration is successful, the method returns a `ThingSmartDeviceModel` object representing the configured device.
  /// If an error occurs, it will be logged using the `_log` method and `null` is returned.
  ///
  /// Example usage:
  ///
  Future<ThingSmartDeviceModel?> startConfigWiredDevice({
    required String token,
    int timeout = 3000,
  }) async {
    try {
      var res =
          await methodChannel.invokeMethod<dynamic>('startConfigWiredDevice', {
        "token": token,
        "timeout": timeout,
      });
      _log(res);
      return ThingSmartDeviceModel.fromJson(res.cast<String, dynamic>());
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  Future<ThingSmartDeviceModel?> startConfigSubDevice({
    required String devId,
    int timeout = 3000,
  }) async {
    try {
      var res =
          await methodChannel.invokeMethod<dynamic>('startConfigSubDevice', {
        "devId": devId,
        "timeout": timeout,
      });
      _log(res);
      return ThingSmartDeviceModel.fromJson(res.cast<String, dynamic>());
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  Future<String?> requestHomeToken({
    required num homeId,
  }) async {
    try {
      var res = await methodChannel.invokeMethod<dynamic>('requestHomeToken', {
        "homeId": homeId,
      });
      _log(res);
      return res;
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Discovers device information.
  ///
  /// This method invokes the `discoverDevices` method on the `methodChannel` to discover device information.
  /// It returns a `ThingSmartDeviceModel` object if the result is not null, otherwise it returns null.
  /// If an exception occurs during the process, it logs the exception and returns null.
  ///
  /// Returns:
  /// - A `ThingSmartDeviceModel` object if the result is not null.
  /// - Null if the result is null or an exception occurs.
  ///
  /// Throws:
  /// - A `PlatformException` if an exception occurs during the process.
  @Deprecated("Use discoverDevices() instead always return null")
  Future<ThingSmartDeviceModel?> discoverDeviceInfo() async {
    try {
      var res = await methodChannel.invokeMethod<dynamic>('discoverDevices');
      return res == null
          ? null
          : ThingSmartDeviceModel.fromJson(res.cast<String, dynamic>());
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Starts the discovery of Tuya Bluetooth smart devices and returns a stream of discovered devices.
  ///
  /// to a [ThingSmartDeviceModel] instance.
  ///
  /// Returns a [Stream] of [ThingSmartDeviceModel] representing the discovered devices.

  Stream<ThingSmartDeviceModel> discoverDevices() {
    methodChannel.invokeMethod<dynamic>('discoverDevices');
    return _deviceDiscoveryEvent.receiveBroadcastStream().map((dynamic event) =>
        ThingSmartDeviceModel.fromJson(event.cast<String, dynamic>()));
  }

  /// Retrieves a list of devices associated with a specific home ID.
  ///
  /// Example Usage:
  /// ```dart
  /// List<ThingSmartDeviceModel> devices = await getHomeDevices(homeId: 123);
  /// ```
  ///
  /// Inputs:
  /// - `homeId` (required): The ID of the home for which to retrieve the devices.
  ///
  /// Outputs:
  /// - A list of `ThingSmartDeviceModel` objects representing the devices associated with the specified home ID. If there are no devices or an error occurs, an empty list is returned.
  Future<List<ThingSmartDeviceModel>> getHomeDevices({
    required num homeId,
  }) async {
    try {
      assert(homeId > 0, "homeId must be greater than 0");
      var res =
          await methodChannel.invokeListMethod<dynamic>('getHomeDevices', {
        "homeId": homeId,
      });
      if (res == null) return [];
      return List<ThingSmartDeviceModel>.from(
        res.map(
            (e) => ThingSmartDeviceModel.fromJson(e.cast<String, dynamic>())),
      );
    } on PlatformException catch (e) {
      _log(e);
      return [];
    }
  }

  /// Retrieves the SSID (Service Set Identifier) of the currently connected Wi-Fi network.
  ///
  /// Returns the SSID as a [String] if successful, or `null` if an error occurs.
  /// Throws a [PlatformException] if there is an error invoking the native method.
  ///
  Future<String?> getWifiSsid() async {
    try {
      var res = await methodChannel.invokeMethod<String>('getWifiSsid');
      return res;
    } on PlatformException catch (e) {
      _log(e);
      return null;
    }
  }

  /// Removes a device with the specified device ID.
  ///
  /// This method sends a request to remove a device with the given device ID. It returns a [Future] that completes with a [bool] value indicating whether the device was successfully removed or not.
  ///
  /// Parameters:
  /// - [deviceId]: The ID of the device to be removed. Must not be empty.
  ///
  /// Returns:
  /// - A [Future] that completes with a [bool] value indicating whether the device was successfully removed or not.
  ///
  /// Throws:
  /// - [AssertionError] if the [deviceId] is empty.
  /// - [PlatformException] if an error occurs during the removal process.
  ///
  /// Example usage:
  /// ```dart
  /// bool removed = await removeDevice(deviceId: 'device123');
  /// if (removed) {
  ///   print('Device removed successfully');
  /// } else {
  ///   print('Failed to remove device');
  /// }
  /// ```
  ///
  Future<bool> removeDevice({required String deviceId}) async {
    assert(deviceId.isNotEmpty);
    try {
      var res = await methodChannel.invokeMethod<bool>('removeDevice', {
        "deviceId": deviceId.trim(),
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Renames a device with the specified device ID.
  ///
  /// This method sends a request to rename the device with the given device ID to the provided name.
  ///
  /// Parameters:
  /// - [deviceId]: The ID of the device to be renamed. Must not be empty.
  /// - [name]: The new name for the device. Must not be empty.
  ///
  /// Returns:
  /// - A [Future] that completes with a [bool] value indicating whether the device was successfully renamed or not.
  ///
  /// Throws:
  /// - [AssertionError] if the [deviceId] or [name] is empty.
  /// - [PlatformException] if an error occurs during the renaming process.
  ///
  /// Example usage:
  /// ```dart
  /// bool renamed = await renameDevice(deviceId: 'device123', name: 'New Device Name');
  /// if (renamed) {
  ///   print('Device renamed successfully');
  /// } else {
  ///   print('Failed to rename device');
  /// }
  /// ```

  Future<bool> renameDevice({
    required String deviceId,
    required String name,
  }) async {
    assert(deviceId.isNotEmpty);
    try {
      var res = await methodChannel.invokeMethod<bool>('renameDevice', {
        "deviceId": deviceId.trim(),
        "name": name.trim(),
      });
      return res!;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Publishes device data points to a specific device using the Tuya Home SDK Flutter.
  ///
  /// The [publishDps] method takes a [deviceId] and a map of [dps] (device data points) as inputs and returns a [ThingSmartDeviceModel] object representing the updated device information.
  ///
  /// Example Usage:
  /// ```dart
  /// String deviceId = "123456789";
  /// Map<String, dynamic> dps = {
  ///   "power": true,
  ///   "brightness": 50,
  /// };
  ///
  /// ThingSmartDeviceModel? result = await publishDps(deviceId: deviceId, dps: dps);
  /// ```
  ///
  /// Inputs:
  /// - [deviceId] (required): A string representing the unique identifier of the device.
  /// - [dps] (required): A map of string keys and dynamic values representing the device data points to be published.
  ///
  /// Flow:
  /// 1. The method is called with the [deviceId] and [dps] as inputs.
  /// 2. The method invokes the `invokeMethod` function of the `methodChannel` with the method name `'publishDps'` and a map containing the [deviceId] and [dps].
  /// 3. The result of the method invocation is stored in the [res] variable.
  /// 4. If the method invocation is successful, the [res] is casted to a `Map<String, dynamic>` and used to create a [ThingSmartDeviceModel] object.
  /// 5. The [ThingSmartDeviceModel] object is returned as the result of the method.
  /// 6. If an exception of type `PlatformException` is thrown during the method invocation, the exception is logged using the `_log` method and `null` is returned.
  ///
  /// Outputs:
  /// - [ThingSmartDeviceModel?]: The updated device information represented as a [ThingSmartDeviceModel] object. It contains the device ID, name, status, and other relevant information. If an exception occurs, `null` is returned.
  Future<bool> publishDps({
    required String deviceId,
    required Map<String, dynamic> dps,
  }) async {
    assert(deviceId.isNotEmpty, "Device ID can't be empty");
    assert(dps.isNotEmpty, "DPS can't be empty");
    try {
      var res = await methodChannel.invokeMethod<bool>('publishDps', {
        "deviceId": deviceId.trim(),
        "dps": dps,
      });
      if (res == null) {
        return false;
      }
      return true;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Listens for device DPS updates.
  ///
  /// This method sets up a listener for DPS (Data Point State) updates for a specific device.
  /// It takes the [deviceId] as a required parameter and invokes the "listenForDevice" method on the [methodChannel].
  /// The [methodChannel] is responsible for communicating with the native platform.
  /// Once the listener is set up, it returns a [Stream] that will receive the broadcasted DPS updates.
  /// The updates can be of any type, hence the return type of [dynamic] for the stream.
  ///
  /// Example usage:
  /// ```dart
  /// Stream<dynamic> dpsStream = onDeviceDpsUpdated(deviceId: 'device123');
  /// dpsStream.listen((data) {
  ///   // Handle DPS update
  ///   print('DPS update received: $data');
  /// });
  /// ```
  ///
  /// Note: Make sure to import the necessary dependencies and initialize the [methodChannel] and [_deviceEvent] before using this method.
  ///
  /// Returns:
  /// - A [Stream] that receives the broadcasted DPS updates for the specified device.
  ///
  /// Throws:
  /// - None.
  Stream<dynamic> onDeviceDpsUpdated({
    required String deviceId,
  }) {
    methodChannel.invokeMethod("listenForDevice", {
      "deviceId": deviceId,
    });
    return _deviceEvent.receiveBroadcastStream();
  }

  /// Logs out the user from the Tuya Home SDK.
  ///
  /// Returns a bool indicating whether the logout was successful or not.
  Future<bool> logout() async {
    var res = await methodChannel.invokeMethod<bool>('logout');
    return res!;
  }

  /// Retrieves a list of scenes associated with a specific home ID.
  ///
  /// passing the [homeId] as a parameter. It expects a list of map objects as a result, which are then
  /// converted into a list of [ThingSmartSceneModel] objects using the `fromJson` method. If the result is null
  /// or empty, an empty list is returned. If any error occurs during the method call, it is logged using the [_log] method.
  ///
  /// Parameters:
  /// - [homeId]: The ID of the home for which to retrieve the scenes. Must be greater than 0.
  ///
  /// Returns:
  /// - A list of [ThingSmartSceneModel] objects representing the scenes in the home. If no scenes are found or an error
  Future<List<ThingSmartSceneModel>> getSceneList({required num homeId}) async {
    assert(homeId > 0, "homeId must be greater than 0");
    try {
      var res = await methodChannel
          .invokeListMethod<Map<Object?, Object?>>('getSceneList', {
        "homeId": homeId,
      });
      if (res == null || res.isEmpty) return [];
      _log(res);
      return List<ThingSmartSceneModel>.from(
        res.map(
            (e) => ThingSmartSceneModel.fromJson(e.cast<String, dynamic>())),
      );
    } on PlatformException catch (e) {
      _log(e);
      return [];
    }
  }

  /// Retrieves the details of a specific scene.
  ///
  /// passing the [sceneId], [homeId], [supportHome], and [ruleGenre] as parameters. It expects a map object as a result,
  /// which is then converted into a [ThingSmartSceneModel] object using the `fromJson` method. If the result is null
  /// or an error occurs during the method call, `null` is returned.
  ///
  /// Parameters:
  /// - [sceneId] (required): The ID of the scene for which to retrieve the details.
  /// - [homeId] (required): The ID of the home that the scene belongs to. Must be greater than 0.
  /// - [ruleGenre] (required): The genre of the scene rule.
  /// - [supportHome] (optional): Whether the scene supports a home. Defaults to `false`.
  ///
  /// Returns:
  /// - A [ThingSmartSceneModel] object representing the scene details. If no scene is found or an error occurs, `null` is returned.
  Future<ThingSmartSceneModel?> fetchSceneDetail({
    required String sceneId,
    required num homeId,
    required ThingSmartSceneRuleGenre ruleGenre,
    bool supportHome = false,
  }) async {
    assert(homeId > 0, "homeId must be greater than 0");
    try {
      final res = await methodChannel
          .invokeMapMethod<String, dynamic>('fetchSceneDetail', {
        "sceneId": sceneId,
        "homeId": homeId,
        "supportHome": supportHome,
        "ruleGenre": ruleGenre.value,
      });
      if (res == null) return null;
      return ThingSmartSceneModel.fromJson(res);
    } catch (e) {
      _log(e);
      return null;
    }
  }

  /// Adds a new scene using the provided [sceneFactory].
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'addScene' method, passing the serialized [sceneFactory] as a parameter.
  /// It expects a map object as a result, which is then converted into a
  /// [ThingSmartSceneModel] object using the `fromJson` method. If the result
  /// is null or an error occurs during the method call, `null` is returned.
  ///
  /// Parameters:
  /// - [sceneFactory] (required): The factory object containing the scene
  ///   configuration to be added.
  ///
  /// Returns:
  /// - A [ThingSmartSceneModel] object representing the added scene. If the scene
  ///   creation fails or an error occurs, `null` is returned.

  Future<ThingSmartSceneModel?> addScene({
    required ThingSmartSceneFactory sceneFactory,
  }) async {
    assert(sceneFactory.homeId! > 0, "homeId must be greater than 0");
    try {
      final res = await methodChannel.invokeMapMethod<String, dynamic>(
        'addScene',
        sceneFactory.toMap(),
      );
      if (res == null) return null;
      return ThingSmartSceneModel.fromJson(res);
    } catch (e) {
      _log(e);
      return null;
    }
  }

  /// Adds a new member to the home specified by [homeId] with the given [name],
  /// [autoAccept], [countryCode], [account], and [role].
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'addMember' method, passing the provided parameters as a map object.
  /// It expects a map object as a result, which is then converted into a
  /// [ThingSmartHomeMemberModel] object using the `fromJson` method. If the result
  /// is null or an error occurs during the method call, `null` is returned.
  ///
  /// Parameters:
  /// - [homeId] (required): The ID of the home to which the member should be
  ///   added. Must be greater than 0.
  /// - [name] (required): The name of the member to be added.
  /// - [autoAccept] (optional, default `true`): Whether the member should be
  ///   automatically accepted when the home owner receives the request.
  /// - [countryCode] (required): The country code of the member to be added.
  /// - [account] (required): The account of the member to be added.
  /// - [role] (optional, default `HomeMemberRole.member`): The role of the
  ///   member to be added.
  ///
  /// Returns:
  /// - A [String] representing the added member. If the
  ///   member addition fails or an error occurs, `null` is returned.
  Future<String?> addHomeMember({
    required num homeId,
    required String name,
    bool autoAccept = true,
    String? countryCode,
    String? account,
    Role role = Role.member,
  }) async {
    try {
      final res = await methodChannel.invokeMethod(
        'addMember',
        {
          "homeId": homeId,
          "name": name,
          "autoAccept": autoAccept,
          "countryCode": countryCode,
          "account": account,
          "role": role.toJson(),
        },
      );
      if (res == null) return null;
      return res;
    } catch (e) {
      _log(e);
      return null;
    }
  }

  /// Retrieves a list of members in a home.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'queryMemberList' method, passing the [homeId] as a parameter. It expects
  /// a list of dynamic objects as a result, which is then converted into a list of
  /// [ThingSmartHomeMemberModel] objects using the `fromJson` method. If the result
  /// is null or an error occurs during the method call, an empty list is returned.
  ///
  /// Parameters:
  /// - [homeId] (required): The ID of the home for which to retrieve the members.
  ///
  /// Returns:
  /// - A list of [ThingSmartHomeMemberModel] objects representing the members in
  ///   the home. If no members are found or an error occurs, an empty list is
  ///   returned.
  ///
  /// Throws:
  /// - None.
  Future<List<ThingSmartHomeMemberModel>> queryMemberList({
    required num homeId,
  }) async {
    try {
      final res = await methodChannel.invokeListMethod(
        'queryMemberList',
        {
          "homeId": homeId,
        },
      );
      if (res == null) return [];
      return List<ThingSmartHomeMemberModel>.from(
        res.map((e) =>
            ThingSmartHomeMemberModel.fromJson(e.cast<String, dynamic>())),
      );
    } catch (e) {
      _log(e);
      return [];
    }
  }

  /// Removes a member from the home using the specified [memberId].
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'removeMember' method, passing the [memberId] as a parameter. It expects
  /// a boolean value as a result, indicating whether the member was successfully
  /// removed or not. If the member removal fails or an error occurs during the
  /// method call, `false` is returned.
  ///
  /// Parameters:
  /// - [memberId] (required): The ID of the member to be removed.
  ///
  /// Returns:
  /// - A boolean value indicating whether the member was successfully removed or
  ///   not. If the member removal fails or an error occurs, `false` is returned.
  ///
  /// Throws:
  /// - None.

  Future<bool> removeMember({
    required num memberId,
  }) async {
    try {
      var res = await methodChannel.invokeMethod<bool>('removeMember', {
        "memberId": memberId,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Modifies the details of a home member using the specified parameters.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'modifyMember' method, passing the [memberId], [name], and [role] as
  /// parameters. It expects a boolean value as a result, indicating whether
  /// the member modification was successful. If the modification fails or an
  /// error occurs during the method call, `false` is returned.
  ///
  /// Parameters:
  /// - [memberId] (required): The ID of the member to be modified.
  /// - [name] (optional): The new name for the member.
  /// - [role] (optional): The new role for the member.
  ///
  /// Returns:
  /// - A boolean value indicating whether the member was successfully modified
  ///   or not. If the modification fails or an error occurs, `false` is returned.
  ///
  /// Throws:
  /// - None.

  Future<bool> modifyMember({
    required num memberId,
    String? name,
    Role? role,
  }) async {
    assert(memberId > 0);
    try {
      var res = await methodChannel.invokeMethod<bool>('modifyMember',
          {"memberId": memberId, "name": name, "role": role?.toJson()});
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Joins a home using the provided [invitationCode].
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'joinHome' method, passing the [invitationCode] as a parameter. It
  /// expects a boolean value as a result, indicating whether the operation was
  /// successful. If an error occurs during the method call, `false` is returned.
  ///
  /// Parameters:
  /// - [invitationCode] (required): The invitation code to join the home.
  ///
  /// Returns:
  /// - A boolean value indicating whether the join operation was successful or
  ///   not. If the operation fails or an error occurs, `false` is returned.

  Future<bool> joinHome({
    required String invitationCode,
  }) async {
    assert(invitationCode.isNotEmpty);
    try {
      var res = await methodChannel.invokeMethod<bool>('joinHome', {
        "code": invitationCode,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Cancels an invitation using the specified [invitationCode].
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'cancelInvitation' method, passing the [invitationCode] as a parameter.
  /// It expects a boolean value as a result, indicating whether the cancellation
  /// was successful. If the cancellation fails or an error occurs during the
  /// method call, `false` is returned.
  ///
  /// Parameters:
  /// - [invitationCode] (required): The code of the invitation to be canceled.
  ///
  /// Returns:
  /// - A boolean value indicating whether the invitation was successfully canceled
  ///   or not. If the cancellation fails or an error occurs, `false` is returned.
  ///
  /// Throws:
  /// - None.

  Future<bool> cancelInvitation({
    required int invitationCode,
  }) async {
    assert(invitationCode > 0);
    try {
      var res = await methodChannel.invokeMethod<bool>('cancelInvitation', {
        "invitationID": invitationCode,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Accepts or rejects a home invitation using the specified [homeId] and
  /// [accept] values.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'acceptOrRejectInvitation' method, passing the [homeId] and [accept] as
  /// parameters. It expects a boolean value as a result, indicating whether the
  /// operation was successful. If an error occurs during the method call, `false`
  /// is returned.
  ///
  /// Parameters:
  /// - [homeId] (required): The ID of the home to accept or reject the
  ///   invitation for.
  /// - [accept] (required): A boolean indicating whether to accept or reject
  ///   the invitation.
  ///
  /// Returns:
  /// - A boolean value indicating whether the invitation was successfully
  ///   accepted or rejected. If an error occurs, `false` is returned.
  ///
  /// Throws:
  /// - None.
  Future<bool> acceptOrRejectInvitation({
    required num homeId,
    required bool accept,
  }) async {
    assert(homeId > 0);
    try {
      var res =
          await methodChannel.invokeMethod<bool>('acceptOrRejectInvitation', {
        "homeId": homeId,
        "accept": accept,
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// Retrieves a list of invitations for a specified home.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'queryInvitations' method, passing the [homeId] as a parameter. It
  /// expects a list of dynamic objects as a result, which is then converted into
  /// a list of [ThingSmartInvitationModel] objects using the `fromJson` method.
  /// If the result is null or an error occurs during the method call, an empty
  /// list is returned.
  ///
  /// Parameters:
  /// - [homeId] (required): The ID of the home for which to retrieve the
  ///   invitations.
  ///
  /// Returns:
  /// - A list of [ThingSmartInvitationModel] objects representing the invitations
  ///   for the home. If no invitations are found or an error occurs, an empty
  ///   list is returned.
  ///
  /// Throws:
  /// - None.

  Future<List<ThingSmartInvitationModel>> queryInvitationList({
    required num homeId,
  }) async {
    assert(homeId > 0);
    try {
      var res = await methodChannel
          .invokeListMethod('queryInvitations', {"homeId": homeId});
      if (res == null) return [];
      return List<ThingSmartInvitationModel>.from(res.map((e) =>
          ThingSmartInvitationModel.fromJson(e.cast<String, dynamic>())));
    } on PlatformException catch (e) {
      _log(e);
      return [];
    }
  }

  /// Modifies the invitation information in a home.
  ///
  /// This method makes an asynchronous call to the platform channel to invoke
  /// the 'modifyInvitation' method, passing the [invitationID], [memberName], and
  /// [role] as parameters. It expects a boolean value as a result, indicating
  /// whether the modification of the invitation was successful or not. If the
  /// result is null or an error occurs during the method call, false is returned.
  ///
  /// Parameters:
  /// - [invitationID] (required): The ID of the invitation to modify.
  /// - [memberName] (required): The new name of the member.
  /// - [role] (required): The new role of the member.
  ///
  /// Returns:
  /// - A boolean value indicating whether the modification of the invitation was
  ///   successful or not. If no invitations are found or an error occurs, false
  ///   is returned.
  ///
  /// Throws:
  /// - None.
  Future<bool> modifyInvitation(
      {required num invitationID,
      required String memberName,
      required Role role}) async {
    assert(invitationID > 0);
    assert(memberName.isNotEmpty);
    try {
      var res = await methodChannel.invokeMethod<bool>('modifyInvitation', {
        "invitationId": invitationID,
        "name": memberName,
        "role": role.toJson()
      });
      return res ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    }
  }

  /// This is a private method `_log` that logs the provided data using the `log` function from the `dart:developer` library. The logged data is converted to a string and prefixed with the value of the `tag` constant.
  void _log(data) {
    log("$data", name: tag);
  }
}

# Tuya Home SDK Flutter Plugin

<img src="https://seeklogo.com/images/T/tuya-logo-13829BDDB2-seeklogo.com.png" width="50">

[![Pub Version](https://img.shields.io/pub/v/tuya_home_sdk_flutter)](https://pub.dev/packages/tuya_home_sdk_flutter)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Table of Contents
1. [Initialization](#initialization)
2. [Authentication](#authentication)
3. [User Management](#user-management)
4. [Home Management](#home-management)
5. [Device Management](#device-management)
6. [Device Control](#device-control)
7. [Scene Management](#scene-management)
8. [Member Management](#member-management)
9. [License Key](#purchasing-a-license-key)

## Initialization

### Prerequisites

- Flutter SDK (version 3.3.0 or higher)
- Tuya Developer Account
- Android Studio/Xcode (for platform-specific setup)

### Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  tuya_home_sdk_flutter:
```

Run `flutter pub get` to install the package.

### Platform Configuration

#### Android

1. **Download the SDK**:

   - Go to the [Get SDK](https://platform.tuya.com/oem/sdkList) tab on the Tuya Developer Platform.
   - Select one or more required SDKs or BizBundles.
   - Download the App SDK for Android.
   - Extract the downloaded package and put `security-algorithm.aar` in the `libs` directory of your project.

2. **Add the following permissions to `AndroidManifest.xml` (Optional, as needed)**:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

3. **Update `build.gradle`**:

```groovy
android {
    defaultConfig {
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a"
        }
    }
    packagingOptions {
      pickFirst 'lib/*/libc++_shared.so' // An Android Archive (AAR) file contains an Android library. If the .so file exists in multiple AAR files, select the first AAR file.
   }
}

dependencies {
    implementation fileTree(include: ['*.aar'], dir: 'libs')
}
```

4. **Add ProGuard Rules**:

Add the following rules to your `proguard-rules.pro` file:

```proguard
## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

#fastJson
-keep class com.alibaba.fastjson.**{*;}
-dontwarn com.alibaba.fastjson.**

#mqtt
-keep class com.thingclips.smart.mqttclient.mqttv3.** { *; }
-dontwarn com.thingclips.smart.mqttclient.mqttv3.**

#OkHttp3
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class okio.** { *; }
-dontwarn okio.**

-keep class com.thingclips.**{*;}
-dontwarn com.thingclips.**

# Matter SDK
-keep class chip.** { *; }
-dontwarn chip.**
```

#### iOS

1. **Build and Download the SDK**:

   - Log in to the [Tuya Developer Platform](https://platform.tuya.com/oem/sdkList).
   - Select the required SDKs or UI BizBundles of v5.x.x.
   - Build the SDK and download the package.
   - Extract `ios_core_sdk.tar.gz` to get the following files:
     - `Build`: Stores the security SDK exclusive to your app. Keep this file secure.
     - `ThingSmartCryption.podspec`: Used to reference and integrate with App SDK v5.0.
   - Store both files in a directory alongside your `Podfile` for easy reference.

2. **Add the following keys to `Info.plist` (Optional, as needed)**:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need access to Bluetooth for device setup</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>We need access to Bluetooth for device setup</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need access to location for device discovery</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need access to location for device discovery</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need access to location for device discovery</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need access to the microphone for voice control</string>
<key>NSCameraUsageDescription</key>
<string>We need access to the camera for device setup</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to the photo library for device setup</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to the photo library for device setup</string>
<key>UIBackgroundModes</key>
	<array>
		<string>bluetooth-central</string>
		<string>bluetooth-peripheral</string>
		<string>fetch</string>
		
	</array>
```

Add the following to your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/SSpecs.git'
source 'https://github.com/TuyaInc/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

platform :ios, '12.0'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  pod "ThingSmartCryption", :path =>'./ios_core_sdk'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

Run `pod install` to install the dependencies.

### SDK Initialization

```dart
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

void main() async {
  await TuyaHomeSdkFlutter.instance.initSdk(
    'your_app_key',
    'your_app_secret',
    'your_key',
    isDebug: true
  );
  print('SDK initialized successfully');
}
```

## Authentication

### Login with OAuth

Authenticates using third-party OAuth providers.

Key parameters:
- `type`: Provider type ('ap' for Apple, 'gg' for Google, 'fb' for Facebook)
- `countryCode`: Country code
- `accessToken`: OAuth token

Example:
```dart
final bool success = await TuyaHomeSdkFlutter.instance.loginByAuth2(
  type: 'gg',
  countryCode: '+1',
  accessToken: 'oauthToken123'
);

if (success) {
  print('Login successful');
} else {
  print('Login failed');
}
```

## User Management

### Get User Info

Retrieves current user information.

Example:
```dart
final user = await TuyaHomeSdkFlutter.instance.getUserInfo();
if (user != null) {
  print('User email: ${user.email}');
}
```

### Update User Profile

Updates user profile information.

Methods:
```dart
// Update nickname
await updateUserNickName(nickname: 'New Name');

// Update avatar
await updateUserIcon(icon: 'base64ImageData');
```

### Logout

Terminates the current session.

Example:
```dart
final bool success = await TuyaHomeSdkFlutter.instance.logout();
if (success) {
  print('Logged out successfully');
}
```

### User Registration

Use this method to register a new user with a verified code.

Key parameters:
- `username`: The user's phone number or email
- `countryCode`: The country code for phone numbers
- `code`: The verification code
- `password`: The user's password

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.registerByUserName(
  username: 'user@example.com',
  countryCode: '+1',
  code: '123456',
  password: 'securePassword123'
);

if (success) {
  print('User registered successfully');
} else {
  print('User registration failed');
}
```

### Login with Username

Use this method to authenticate a user with their username and password.

Key parameters:
- `username`: The user's phone number or email
- `countryCode`: The country code for phone numbers
- `password`: The user's password

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.loginWithUserName(
  username: 'user@example.com',
  countryCode: '+1',
  password: 'securePassword123'
);

if (success) {
  print('Login successful');
} else {
  print('Login failed');
}
```

### Third-party Login

Use this method to authenticate a user using a third-party provider (e.g., Google or Apple).

Key parameters:
- `type`: The type of third-party provider ('ap' for Apple, 'gg' for Google)
- `countryCode`: The country code for phone numbers
- `accessToken`: The access token from the third-party provider

Here's a complete example:

```dart
final bool success = await TuYaHomeSdkFlutter.instance.loginByAuth2(
  type: 'gg',
  countryCode: '+1',
  accessToken: 'googleAccessToken'
);

if (success) {
  print('Login successful');
} else {
  print('Login failed');
}
```

### Send Verification Code

Use this method to send a verification code to a user's phone or email.

Key parameters:
- `username`: The user's phone number or email
- `countryCode`: The country code for phone numbers
- `type`: The type of verification code (1: register, 2: login, 3: reset password)

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.sendVerifyCodeWithUserName(
  username: 'user@example.com',
  countryCode: '+1',
  type: 1
);

if (success) {
  print('Verification code sent successfully');
} else {
  print('Failed to send verification code');
}
```

### Check Verification Code

Use this method to verify a code sent to a user's phone or email.

Key parameters:
- `username`: The user's phone number or email
- `countryCode`: The country code for phone numbers
- `code`: The verification code to check
- `type`: The type of verification code (1: register, 2: login, 3: reset password)

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.checkCodeWithUserName(
  username: 'user@example.com',
  countryCode: '+1',
  code: '123456',
  type: 1
);

if (success) {
  print('Verification code is valid');
} else {
  print('Invalid verification code');
}
```

### Reset Password

Use this method to reset a user's password using a verified code.

Key parameters:
- `username`: The user's phone number or email
- `countryCode`: The country code for phone numbers
- `code`: The verification code
- `password`: The new password

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.resetPasswordByEmail(
  username: 'user@example.com',
  countryCode: '+1',
  code: '123456',
  password: 'newPassword123'
);

if (success) {
  print('Password reset successful');
} else {
  print('Password reset failed');
}
```

## Home Management

### Create Home

Creates a new home location.

Key parameters:
- `name`: Home name
- `geoName`: Geographic location
- `rooms`: List of rooms

Example:
```dart
final home = await TuyaHomeSdkFlutter.instance.addHomeWithName(
  name: 'My Home',
  geoName: 'New York',
  rooms: ['Living Room', 'Bedroom']
);
```

### Get Home List

Retrieves all homes for current user.

Example:
```dart
final homes = await TuyaHomeSdkFlutter.instance.getHomeList();
homes.forEach((home) => print(home.name));
```

### Get Home Token

Requests an access token for a specific home.

Example:
```dart
final token = await TuyaHomeSdkFlutter.instance.requestHomeToken(
  homeId: 123
);
```

### Update Home

Use this method to update an existing home's information.

Key parameters:
- `homeId`: The ID of the home to update
- `name`: New name for the home
- `geoName`: New geographic location name
- `rooms`: Updated list of rooms
- `latitude`: Optional latitude coordinate
- `longitude`: Optional longitude coordinate

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.updateHome(
  homeId: 123,
  name: 'Updated Home Name',
  geoName: 'New York',
  rooms: ['Living Room', 'Bedroom', 'Kitchen'],
  latitude: 40.7128,
  longitude: -74.0060
);

if (success) {
  print('Home updated successfully');
} else {
  print('Failed to update home');
}
```

### Remove Home

Use this method to remove a home.

Key parameters:
- `homeId`: The ID of the home to remove

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.removeHome(
  homeId: 'home123'
);

if (success) {
  print('Home removed successfully');
}
```

### Get Home Token

Use this method to retrieve an access token for a specific home.

Key parameters:
- `homeId`: The ID of the home

Here's a complete example:

```dart
final String? token = await TuyaHomeSdkFlutter.instance.getToken(
  homeId: 123
);

if (token != null) {
  print('Home token: $token');
} else {
  print('Failed to get home token');
}
```

### Get Home Rooms
Use this method to retrieve a list of rooms for a specific home.

Key parameters:
- `homeId`: The ID of the home to retrieve rooms for

Here's a complete example:

```dart
final List<ThingSmartRoomModel> rooms = await TuyaHomeSdkFlutter.instance.getHomeRooms(
  homeId: 123
);

if (rooms.isNotEmpty) {
  for (final room in rooms) {
    print('Room: ${room.name}, ID: ${room.roomId}');
  }
} else {
  print('No rooms found');
}
```

### Add Home Room
Use this method to add a room to a specific home.

Key parameters:
- `roomName`: The name of the room to add
Here's a complete example:
```dart
  final res = await home.addRoom(
    roomName: 'New Room',
  );

  if (res != null) {
    print('Room added successfully');
  }
```
### Remove Home Room
Use this method to remove a room from a specific home.

Key parameters:
- `roomId`: The ID of the room to remove

Here's a complete example:

```dart
final bool success = await home.removeRoom(
  roomId: 123
);

if (success) {
  print('Room removed successfully');
}
```
  


## Device Management

### Device Discovery

Use this method to discover nearby Tuya devices.

Key parameters:
- None

Here's a complete example:

```dart
TuyaHomeSdkFlutter.instance.discoverDevices().listen(
      (device) {
        debugPrint("Discovered Device: ${device.name}");
      },
      onError: (error) {
        debugPrint("Error discovering devices: $error");
      },
    );
```


### Device Configuration

The Tuya Home SDK provides various methods to configure different types of devices. Here's an overview of the available configuration methods:

#### Configure BLE WiFi Device

Use this method to configure a BLE WiFi device.

Key parameters:
- `ssid`: The WiFi network name
- `password`: The WiFi password
- `homeId`: The home ID where the device will be added
- `deviceUuid`: The device's unique identifier
- `deviceProductId》: The device's product ID
- `timeout`: Configuration timeout in milliseconds (default: 3000)

Here's a complete example:

```dart
final device = await TuyaHomeSdkFlutter.instance.startConfigBLEWifiDevice(
  ssid: 'MyWiFi',
  password: 'securePassword123',
  homeId: 123,
  deviceUuid: 'abcd1234',
  deviceProductId: 'xyz789',
  timeout: 5000
);

if (device != null) {
  print('Device configured successfully: ${device.name}');
} else {
  print('Failed to configure device');
}
```

#### Configure WiFi Device

Use this method to configure a WiFi-only device.

Key parameters:
- `ssid`: The WiFi network name
- `password`: The WiFi password
- `token`: The configuration token
- `timeout`: Configuration timeout in milliseconds (default: 3000)

Here's a complete example:

```dart
final device = await TuyaHomeSdkFlutter.instance.startConfigWiFiDevice(
  ssid: 'MyWiFi',
  password: 'securePassword123',
  token: 'homeToken123',
  timeout: 5000
);

if (device != null) {
  print('Device configured successfully: ${device.name}');
} else {
  print('Failed to configure device');
}
```

#### Configure Wired Device

Use this method to configure a wired device.

Key parameters:
- `token`: The configuration token
- `timeout`: Optional timeout in milliseconds (default: 3000)

Here's a complete example:

```dart
final ThingSmartDeviceModel? device = await TuyaHomeSdkFlutter.instance.startConfigWiredDevice(
  token: 'homeToken123',
  timeout: 5000
);

if (device != null) {
  print('Device configured successfully: ${device.name}');
} else {
  print('Failed to configure device');
}
```

#### Configure Sub-Device

Use this method to configure a sub-device.

Key parameters:
- `devId`: The device ID of the sub-device
- `timeout`: Optional timeout in milliseconds (default: 3000)

Here's a complete example:

```dart
final ThingSmartDeviceModel? device = await TuyaHomeSdkFlutter.instance.startConfigSubDevice(
  devId: 'device123',
  timeout: 5000
);

if (device != null) {
  print('Sub-device configured successfully: ${device.name}');
} else {
  print('Failed to configure sub-device');
}
```

#### Assign Device to Room

Use this method to assign a device to a specific room in a home.

Key parameters:
- `deviceId`: The ID of the device
- `homeId`: The ID of the home
- `roomId`: The ID of the room (0 to unassign from any room)

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.assignDeviceToRoom(
  deviceId: 'device123',
  homeId: 123,
  roomId: 456
);

if (success) {
  print('Device assigned to room successfully');
} else {
  print('Failed to assign device to room');
}
```

### Get Home Devices

Use this method to retrieve all devices in a specific home.

Key parameters:
- `homeId`: The ID of the home

Here's a complete example:

```dart
final List<ThingSmartDeviceModel> devices = await TuyaHomeSdkFlutter.instance.getHomeDevices(
  homeId: 123
);

if (devices.isNotEmpty) {
  for (final device in devices) {
    print('Device: ${device.name}, ID: ${device.devId}');
  }
} else {
  print('No devices found in home');
}
```

### Remove Device

Use this method to remove a device from the Tuya ecosystem.

Key parameters:
- `deviceId`: The ID of the device to remove

Here's a complete example:

```dart
final bool success = await TuyaHomeSdkFlutter.instance.removeDevice(
  deviceId: 'device123'
);

if (success) {
  print('Device removed successfully');
} else {
  print('Failed to remove device');
}
```

## Device Control

### Event Listening

#### Receive Device Updates

Subscribe to real-time device status changes. Returns a stream of DPS updates.

Key parameters:
- `deviceId`: The device to monitor

Example:
```dart
final subscription = TuyaHomeSdkFlutter.instance
  .onDeviceDpsUpdated(deviceId: 'device123')
  .listen((update) {
    print('Device update received:');
    update.forEach((key, value) {
      print('  $key: $value');
    });
  });

// Remember to cancel when done
subscription.cancel();
```

Typical DPS updates include:
- Power state changes
- Brightness adjustments
- Temperature updates
- Other device-specific metrics

### Get WiFi SSID

Use this method to get the SSID of the currently connected WiFi network.

Returns:
- `String?`: The SSID if available, or null if not connected

Here's a complete example:

```dart
final String? ssid = await TuyaHomeSdkFlutter.instance.getWifiSsid();

if (ssid != null) {
  print('Connected to WiFi network: $ssid');
} else {
  print('Not connected to WiFi or SSID unavailable');
}
```

### Publish Device Data Points

Use this method to publish data points (DPS) for a Tuya device.

Key parameters:
- `deviceId`: The ID of the device
- `dps`: Map of data points (numeric keys recommended)

Here's a complete example:

```dart
final device = await TuyaHomeSdkFlutter.instance.publishDps(
  deviceId: 'device123',
  dps: {'1': true, '2': 50}  // DPS 1 = power, DPS 2 = brightness
);

if (device != null) {
  print('DPS published successfully. Device status: ${device.status}');
} else {
  print('Failed to publish DPS');
}
```

## Scene Management

### Create new Scene

Use this method to create a new scene in the specified home.

Key parameters:
- `homeId`: The ID of the home
- `name`: The name of the scene
- `matchType`: The match type for the scene
- `showFirstPage`: Whether to show the first page of the scene
- `actions`: List of actions
- `preConditionions`: List of pre-conditions
- `conditions`: List of conditions

Here's a complete example:
```dart
final created = await TuyaHomeSdkFlutter.instance.addScene(
      sceneFactory: ThingSmartSceneFactory(
        homeId: home!.homeId,
        name: "Test flutter",
        matchType: ThingSmartConditionMatchType.ThingSmartConditionMatchAny,
        showFirstPage: false,
        actions: [ThingSmartSceneActionFactory.createSendNotificationAction()],
        preConditionions: [
          ThingSmartScenePreConditionFactory.allDay(
            loops: "1111111",
            timeZoneId: "Asia/Shanghai",
          ),
        ],
        conditions: [
          ThingSmartSceneConditionFactory.device(
            deviceId: 'eb13b17e6a127b0552oa3e',
            dpModelId: 10,
            expr: ThingSmartSceneExprFactory.createValueExpr(
              type: "8",
              compareOperator: '==',
              chooseValue: 99,
              exprType: ExprEntityType.kExprTypeDevice,
            ),
          ),
        ],
      ),
    );
```

### Delete Scene

Delete a scene with the specified scene ID from the specified home.

- `sceneId`: The ID of the scene
- `homeId`: The ID of the home

Here's a complete example:
```dart
  final res = await scene?.removeScene(homeId: home!.homeId);
  debugPrint(res.toString());
```

### Fetch Scene List
Fetch Scene List
--------------

Use this method to fetch the scene list for the specified home.

- `homeId`: The ID of the home

The response will be a list of `ThingSmartScene` objects. Each object contains the following properties:
- `id`: The ID of the scene
- `name`: The name of the scene
- `gwId`: The ID of the gateway
- `coverIcon`: The URL of the cover icon
- `background`: The URL of the background image
- `displayColor`: The color used to display the scene
- `isEnabled`: Whether the scene is enabled
- `isStickyOnTop`: Whether the scene is sticky on top
- `isNewLocalScene`: Whether the scene is a new local scene
- `isLocalLinkage`: Whether the scene is a local linkage
- `linkageType`: The linkage type of the scene
- `arrowIconUrl`: The URL of the arrow icon
- `outOfWork`: Whether the scene is out of work
- `conditions`: List of `ThingSmartSceneCondition` objects
- `actions`: List of `ThingSmartSceneAction` objects
- `preConditionions`: List of `ThingSmartScenePreCondition` objects

Here's a complete example:
```dart
  final scens = await TuyaHomeSdkFlutter.instance.getSceneList(
      homeId: home!.homeId,
    );
    
  for (var e in scens) {
      debugPrint(e.name);
    }
```
#### Run Scene
```dart
  final res = await scene?.runScene();
  debugPrint(res.toString());
```
#### Enable Automation
```dart
  final res = await scene?.enableAutomation();
  debugPrint(res.toString());
```
#### Disable Automation
```dart
  final res = await scene?.disableAutomation();
  debugPrint(res.toString());
```

## Member Management

### Add Member

Use this method to add a member to the specified home.

- `name`: The name of the member

The response will be a `Member ID` object. The object contains the following 

Here's a complete example:
```dart
  final res = await home?.addMember(name: "member");
  debugPrint(res.toString());
```
### Query Member List


Use this method to query the member list for the specified home.

The response will be a list of `ThingSmartMember` objects. Each object contains the following properties:
- `memberId`: The ID of the member
- `name`: The name of the member
- `homeId`: The ID of the home
- `role`: The role of the member
- `mobile`: The mobile phone number of the member
- `userName`: The username of the member
- `uid`: The user ID of the member
- `memberStatus`: The status of the member

Here's a complete example:
```dart
  final res = await home?.queryMemberList();
  debugPrint(res.toString());
```
### Remove Member
```dart
  final res = await member?.remove();
  debugPrint(res.toString());
```

### `Future<bool> modifyMember({ required num memberId, String? name, Role? role })`

Modifies the details of a home member.

#### Parameters:
- `memberId` (**required**): ID of the member to modify.
- `name` (*optional*): New name of the member.
- `role` (*optional*): New role assigned to the member.

#### Returns:
- `true` if modification was successful, otherwise `false`.

#### Throws:
- None.

---

### `Future<bool> joinHome({ required String invitationCode })`

Joins a home using the provided invitation code.

#### Parameters:
- `invitationCode` (**required**): The invitation code used to join.

#### Returns:
- `true` if the operation was successful, otherwise `false`.

#### Throws:
- None.

---

### `Future<bool> cancelInvitation({ required int invitationCode })`

Cancels a home invitation using the provided invitation code.

#### Parameters:
- `invitationCode` (**required**): The ID of the invitation to cancel.

#### Returns:
- `true` if the cancellation was successful, otherwise `false`.

#### Throws:
- None.

---

### `Future<bool> acceptOrRejectInvitation({ required num homeId, required bool accept })`

Accepts or rejects an invitation to join a home.

#### Parameters:
- `homeId` (**required**): ID of the home related to the invitation.
- `accept` (**required**): `true` to accept, `false` to reject.

#### Returns:
- `true` if the operation was successful, otherwise `false`.

#### Throws:
- None.

---

### `Future<List<ThingSmartInvitationModel>> queryInvitationList({ required num homeId })`

Retrieves a list of active invitations for a home.

#### Parameters:
- `homeId` (**required**): The ID of the home.

#### Returns:
- A list of `ThingSmartInvitationModel` objects. Empty list if an error occurs or no invitations exist.

#### Throws:
- None.

---

### `Future<bool> modifyInvitation({ required num invitationID, required String memberName, required Role role })`

Modifies the invitation's details including member name and role.

#### Parameters:
- `invitationID` (**required**): The ID of the invitation to modify.
- `memberName` (**required**): New name for the member.
- `role` (**required**): New role to assign.

#### Returns:
- `true` if the modification was successful, otherwise `false`.

#### Throws:
- None.
## Purchasing a License Key

To purchase and manage your license keys, please contact our finance team at [Mail](mailto:finance@premierank.com).

We’re currently offering an exclusive limited-time promotion—don’t miss the opportunity to take advantage of our special rates!# tuya_home
# tuya_home_package

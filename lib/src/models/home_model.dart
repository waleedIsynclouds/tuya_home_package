import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

/// The role of a member in a home.
///
/// Used to determine the level of access a member has to the home.
enum Role {
  /// The member's role is unknown.
  ///
  /// This is usually returned when the member's role has not yet been set.
  unknown,

  /// The member has a custom role.
  ///
  /// This role is not one of the standard roles and is determined by the home
  /// owner.
  custom,

  /// The member is a standard member.
  ///
  /// This role gives the member basic access to the home but not the ability to
  /// manage other members or make changes to the home's settings.
  member,

  /// The member is an administrator.
  ///
  /// This role gives the member full access to the home and the ability to
  /// manage other members and make changes to the home's settings.
  admin,

  /// The member is the owner of the home.
  ///
  /// This role gives the member full access to the home and the ability to
  /// manage other members and make changes to the home's settings. Additionally,
  /// the owner has the ability to delete the home.
  owner,
}

/// Converts the [Role] enum value to its corresponding JSON representation.
///
/// Returns an integer value representing the JSON representation of the [Role] enum.
/// The mapping is as follows:
///   - [Role.unknown] maps to -999
///   - [Role.custom] maps to -1
///   - [Role.member] maps to 0
///   - [Role.admin] maps to 1
///   - [Role.owner] maps to 2
/// If the [Role] value does not match any of the above cases, -999 is returned.
///
/// Usage:
/// ```dart
/// Role role = Role.admin;
/// int jsonValue = role.toJson(); // Returns 1
/// ```
///
/// See also:
///   - [RoleExtension.fromJson], which converts a JSON value to its corresponding [Role] enum value.
extension RoleExtension on Role {
  /// Converts the [Role] enum value to its corresponding JSON representation.
  ///
  /// Returns an integer value representing the JSON representation of the [Role] enum.
  /// The mapping is as follows:
  ///   - [Role.unknown] maps to -999
  ///   - [Role.custom] maps to -1
  ///   - [Role.member] maps to 0
  ///   - [Role.admin] maps to 1
  ///   - [Role.owner] maps to 2
  ///
  /// If the [Role] value does not match any of the above cases, -999 is returned.
  int toJson() {
    // Maps the Role enum value to its corresponding JSON representation.
    switch (this) {
      // If the role is unknown, return -999.
      case Role.unknown:
        return -999;

      // If the role is custom, return -1.
      case Role.custom:
        return -1;

      // If the role is member, return 0.
      case Role.member:
        return 0;

      // If the role is admin, return 1.
      case Role.admin:
        return 1;

      // If the role is owner, return 2.
      case Role.owner:
        return 2;
    }
  }

  /// Converts the given [value] to its corresponding [Role] enum value.
  ///
  /// The JSON representation of the [Role] enum is an integer value. The
  /// mapping is as follows:
  ///   - -999 maps to [Role.unknown]
  ///   - -1 maps to [Role.custom]
  ///   - 0 maps to [Role.member]
  ///   - 1 maps to [Role.admin]
  ///   - 2 maps to [Role.owner]
  ///
  /// If the [value] does not match any of the above cases, [Role.unknown] is
  /// returned.
  static Role fromJson(int value) {
    // Maps the given JSON value to its corresponding Role enum value.
    switch (value) {
      // If the value is -999, return Role.unknown.
      case -999:
        return Role.unknown;

      // If the value is -1, return Role.custom.
      case -1:
        return Role.custom;

      // If the value is 0, return Role.member.
      case 0:
        return Role.member;

      // If the value is 1, return Role.admin.
      case 1:
        return Role.admin;

      // If the value is 2, return Role.owner.
      case 2:
        return Role.owner;

      // If the value does not match any of the above cases, return Role.unknown.
      default:
        return Role.unknown;
    }
  }
}

/// Represents the possible statuses for a ThingHome.
///
/// The ThingHomeStatus enum defines three possible statuses:
///   - pending: Indicates that the ThingHome is in a pending state.
///   - accept: Indicates that the ThingHome has been accepted.
///   - reject: Indicates that the ThingHome has been rejected.
///
/// Usage:
/// ```dart
/// ThingHomeStatus status = ThingHomeStatus.accept;
/// ```
///
enum ThingHomeStatus {
  pending,
  accept,
  reject,
}

extension ThingHomeStatusExtension on ThingHomeStatus {
  /// Returns the integer representation of this [ThingHomeStatus].
  ///
  /// The possible integer values are:
  ///   - 1: Indicates that the [ThingHome] is in a pending state.
  ///   - 2: Indicates that the [ThingHome] has been accepted.
  ///   - 3: Indicates that the [ThingHome] has been rejected.
  ///
  /// Returns 1 by default.
  ///

  int toJson() {
    switch (this) {
      /// Indicates that the [ThingHome] is in a pending state.
      case ThingHomeStatus.pending:
        return 1;

      /// Indicates that the [ThingHome] has been accepted.
      case ThingHomeStatus.accept:
        return 2;

      /// Indicates that the [ThingHome] has been rejected.
      case ThingHomeStatus.reject:
        return 3;
    }
  }

  /// Creates a [ThingHomeStatus] from an integer representation.
  ///
  /// The possible integer values are:
  ///   - 1: Indicates that the [ThingHome] is in a pending state.
  ///   - 2: Indicates that the [ThingHome] has been accepted.
  ///   - 3: Indicates that the [ThingHome] has been rejected.
  ///
  /// Returns [ThingHomeStatus.pending] by default.
  ///
  /// [value]: The integer representation of the [ThingHomeStatus].
  static ThingHomeStatus fromJson(int value) {
    switch (value) {
      case 1:
        return ThingHomeStatus.pending;
      case 2:
        return ThingHomeStatus.accept;
      case 3:
        return ThingHomeStatus.reject;
      default:
        return ThingHomeStatus.pending;
    }
  }
}

class ThingSmartHomeModel {
  /// The latitude of the home location.
  double latitude;

  /// The ID of the home.
  num homeId;

  /// The role of the current user in the home.
  Role role;

  /// The longitude of the home location.
  double longitude;

  /// The URL of the background image of the home.
  String? backgroundUrl;

  /// The status of the home invitation.
  ThingHomeStatus thingHomeStatus;

  /// Whether the current user is the manager of the home.
  bool managementStatus;

  /// The name of the home.
  String name;

  /// The name of the region where the home is located.
  String geoName;

  ThingSmartHomeModel({
    required this.latitude,
    required this.homeId,
    required this.role,
    required this.longitude,
    this.backgroundUrl,
    required this.thingHomeStatus,
    required this.managementStatus,
    required this.name,
    required this.geoName,
  });

  factory ThingSmartHomeModel.fromJson(Map<String, dynamic> json) {
    return ThingSmartHomeModel(
      latitude: json['latitude'],
      homeId: json['homeId'],
      role: RoleExtension.fromJson(json['role']),
      longitude: json['longitude'],
      backgroundUrl: json['backgroundUrl'],
      thingHomeStatus: ThingHomeStatusExtension.fromJson(json['dealStatus']),
      managementStatus: json['managementStatus'],
      name: json['name'],
      geoName: json['geoName'],
    );
  }

  /// Adds a room with the specified [roomName] to the home.
  ///
  /// Throws a [PlatformException] if an error occurs while invoking the native
  /// platform method.
  ///
  /// Returns a [ThingSmartRoomModel] representing the added room. If the room
  /// could not be added, returns `null`.
  Future<ThingSmartRoomModel?> addRoom({required String roomName}) async {
    try {
      final res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMapMethod<String, dynamic>(
        'addRoom',
        {'homeId': this.homeId, 'roomName': roomName},
      );
      if (res == null) return null;
      res['homeId'] = this.homeId;
      return ThingSmartRoomModel.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  /// Removes the room with the specified [roomId] from the home.
  ///
  /// Throws a [PlatformException] if an error occurs while invoking the native
  /// platform method.
  ///
  /// Returns a boolean indicating whether the room was successfully removed.
  /// If the room could not be removed, returns `false`.
  Future<bool> removeRoom({required int roomId}) async {
    try {
      final res = await TuyaHomeSdkFlutter.instance.methodChannel
          .invokeMethod<bool>(
              'removeRoom', {'roomId': roomId, 'homeId': homeId});
      return res ?? false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return false;
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
  Future<String?> addMember({
    required String name,
    bool autoAccept = true,
    String? countryCode,
    String? account,
    Role role = Role.member,
  }) =>
      TuyaHomeSdkFlutter.instance.addHomeMember(
          homeId: homeId,
          name: name,
          countryCode: countryCode,
          autoAccept: autoAccept,
          role: role,
          account: account);

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
  Future<List<ThingSmartHomeMemberModel>> queryMemberList() =>
      TuyaHomeSdkFlutter.instance.queryMemberList(homeId: homeId);

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'homeId': homeId,
      'role': role.toJson(),
      'longitude': longitude,
      'backgroundUrl': backgroundUrl,
      'dealStatus': thingHomeStatus.toJson(),
      'managementStatus': managementStatus,
      'name': name,
      'geoName': geoName,
    };
  }
}

import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class ThingSmartInvitationModel {
  final num invitationID;
  final String invitationCode;
  final String name;
  final Role role;
  final MemberStatus dealStatus;
  final Duration validTime;

  ThingSmartInvitationModel.fromJson(Map<String, dynamic> json)
      : invitationID = json['invitationID'],
        invitationCode = json['invitationCode'],
        name = json['name'],
        role = RoleExtension.fromJson(json['role']),
        dealStatus = MemberStatus.values.firstWhere(
          (e) => e.value == json["dealStatus"],
          orElse: () => MemberStatus.pending,
        ),
        validTime = Duration(hours: json['validTime']);
}

import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class ThingSmartHomeMemberModel {
  final num memberId;
  final String name;
  final num homeId;
  final Role role;
  final String? mobile, userName, uid;
  final MemberStatus status;

  ThingSmartHomeMemberModel.fromJson(Map<String, dynamic> json)
      : memberId = json["memberId"],
        name = json["name"],
        homeId = json["homeId"],
        role = RoleExtension.fromJson(json["role"]),
        mobile = json["mobile"],
        userName = json["userName"],
        status = MemberStatus.values.firstWhere(
          (e) => e.value == json["memberStatus"],
          orElse: () => MemberStatus.pending,
        ),
        uid = json["uid"];

  /// Remove this member from the home.
  ///
  /// Returns whether the member was removed successfully.
  Future<bool> remove() =>
      TuyaHomeSdkFlutter.instance.removeMember(memberId: memberId);

  /// Modify the member's name or role in the home.
  ///
  /// [name] is the new name for the member. If [name] is null, the member's name
  /// will not be modified.
  ///
  /// [role] is the new role for the member. If [role] is null, the member's role
  /// will not be modified.
  ///
  /// Returns whether the member was modified successfully.
  Future<bool> modify({String? name, Role? role}) => TuyaHomeSdkFlutter.instance
      .modifyMember(memberId: memberId, name: name, role: role);
}

enum MemberStatus {
  pending(1),
  accept(2),
  reject(3),
  invalid(4);

  final int value;
  const MemberStatus(this.value);
}

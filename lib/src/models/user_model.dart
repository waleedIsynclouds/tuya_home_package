class ThingSmartUserModel {
  /// The user's username.
  final String username;

  /// The user's country code.
  final String countryCode;

  /// The user's email.
  final String email;

  /// The user's ecode.
  final String ecode;

  /// The user's phone number.
  final String phoneNumber;

  /// The user's partner identity.
  final String partnerIdentity;

  /// The user's nickname.
  final String nickname;

  /// The user's head icon URL.
  ///
  /// This is null if the user has not set a head icon.
  final String? headIconUrl;

  /// The user's session ID.
  final String sid;

  /// Whether the user is logged in or not.
  final bool isLogin;

  ThingSmartUserModel.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        countryCode = json['country_code'],
        email = json['email'],
        ecode = json['ecode'],
        phoneNumber = json['phone_number'],
        partnerIdentity = json['partner_identity'],
        nickname = json['nickname'],
        headIconUrl = json['head_icon_url'].toString().isEmpty
            ? null
            : json['head_icon_url'].toString().startsWith('http')
                ? json['head_icon_url']
                : 'https://images.tuyaeu.com/${json['head_icon_url']}',
        sid = json['sid'],
        isLogin = json['is_login'];
}

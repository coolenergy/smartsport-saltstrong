import 'package:purchases_flutter/purchases_flutter.dart';

import 'access_keys_query.dart';

class UserData {
  static final UserData _userData = UserData._internal();

  String appUserID = '';
  GetAccessKeyResponse? accessData;
  EntitlementInfo? entitlement;

  factory UserData() => _userData;

  UserData._internal();

  bool get hasAccessKeys => userData.accessData != null && !userData.accessData!.isError;

  bool get entitlementIsActive => entitlement?.isActive ?? false;
}

final userData = UserData();

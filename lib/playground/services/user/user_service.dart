import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/models/user/registration_query.dart';
import 'package:salt_strong_poc/playground/modelsV2/user/user_login_response.dart';
import 'package:salt_strong_poc/playground/services/storage/storage_service.dart';

import '../../models/user/access_keys_query.dart';
import '../../models/user/login_query.dart';
import '../../models/user/membership_query.dart';
import '../../modelsV2/user/delete_account_request.dart';
import '../../modelsV2/user/delete_account_response.dart';
import '../http/http_service.dart';
import 'http_user_service.dart';

final userServiceProvider = Provider<UserService>((ref) => HttpUserService(
      httpService: ref.watch(httpServiceProvider),
      storageService: ref.watch(storageServiceProvider),
    ));

abstract class UserService {
  Future<UserLoginResponse> login(UserLoginRequest request);
  Future<UserLoginResponse> retryLogin( );
  Future<void> clearLogin();

  Future<void> logout();
  Future<DeleteAccountResponse> deleteAccount(DeleteAccountRequest request);

  Future<GetAccessKeyResponse> getAccessKey();

  Future<UserValidationResponse> checkUserMembership(UserValidationRequest request);

  Future<UserRegistrationResponse> register(UserRegistrationRequest request);
  Future<void> renew(UserRenewalRequest request);

  const UserService();
}




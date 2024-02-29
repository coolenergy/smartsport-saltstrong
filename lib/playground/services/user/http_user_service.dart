import 'dart:convert';

import 'package:salt_strong_poc/playground/models/user/registration_query.dart';
import 'package:salt_strong_poc/playground/modelsV2/user/delete_account_response.dart';
import 'package:salt_strong_poc/playground/modelsV2/user/user_login_response.dart';
import 'package:salt_strong_poc/playground/services/http/http_service.dart';
import 'package:salt_strong_poc/playground/services/storage/storage_service.dart';
import 'package:salt_strong_poc/playground/services/user/user_service.dart';

import '../../models/user/access_keys_query.dart';
import '../../models/user/login_query.dart';
import '../../models/user/membership_query.dart';
import '../../modelsV2/user/delete_account_request.dart';

class HttpUserService extends UserService {
  final HttpService httpService;
  final StorageService storageService;

  const HttpUserService({
    required this.httpService,
    required this.storageService,
  });

  @override
  Future<UserLoginResponse> login(UserLoginRequest request) {
    return httpService
        .request<UserLoginResponse>(
      request,
      converter: (resp) => UserLoginResponse.fromMap(resp),
    )
        .then((value) async {
      await storageService.setValue(key: StorageKeys.login, data: jsonEncode(request.toMap()));
      return value;
    });
  }

  @override
  Future<UserLoginResponse> retryLogin( ) {
    final request = UserLoginRequest.fromMap(jsonDecode(storageService.getValue(StorageKeys.login) ?? '{}'));

    return httpService.request<UserLoginResponse>(
      request,
      converter: (resp) => UserLoginResponse.fromMap(resp),
    );
  }

  @override
  Future<void> clearLogin() {
    return storageService.deleteValue(StorageKeys.login);
  }

  @override
  Future<void> logout() async {
    await clearLogin();
  }

  @override
  Future<GetAccessKeyResponse> getAccessKey() async {
    return httpService.request<GetAccessKeyResponse>(
      GetAccessKeyRequest(),
      converter: (resp) => GetAccessKeyResponse.fromMap(resp),
    );
  }

  @override
  Future<UserValidationResponse> checkUserMembership(UserValidationRequest request) async {
    return httpService.request<UserValidationResponse>(
      request,
      converter: (resp) => UserValidationResponse.fromMap(resp),
    );
  }

  @override
  Future<UserRegistrationResponse> register(UserRegistrationRequest request) async {
    return httpService.request<UserRegistrationResponse>(
      request,
      converter: (resp) => UserRegistrationResponse.fromMap(resp),
    );
  }

  @override
  Future<DeleteAccountResponse> deleteAccount(DeleteAccountRequest request) async {
    return httpService
        .request<DeleteAccountResponse>(
      request,
      converter: (resp) => DeleteAccountResponse.fromMap(resp),
    )
        .then((value) {
      clearLogin();
      return value;
    });
  }

  @override
  Future<void> renew(UserRenewalRequest request) {
    return httpService.request(request, converter: defaultConverter);
  }
}

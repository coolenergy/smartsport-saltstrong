import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user/login_query.dart';
import '../storage/storage_service.dart';

// provide old token and get new token
// using family to prevent same call happening twice at the same time
final tokenRefreshProvider = FutureProvider.family<String, String>((ref, token) async {
  final request = UserLoginRequest.fromMap(
      jsonDecode(ref.read(storageServiceProvider).getValue(StorageKeys.login) ?? '{}'));

  final loginResponse = await Dio().post("https://ssapi.saltstrong.com/login",
      data: FormData.fromMap(request.toMap()),
      options: Options(contentType: Headers.multipartFormDataContentType));
  return loginResponse.data["token"];
});

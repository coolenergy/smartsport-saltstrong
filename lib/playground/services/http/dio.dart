import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:salt_strong_poc/playground/services/http/http_service.dart';
import 'package:salt_strong_poc/playground/services/http/token_refresh.dart';
import 'package:salt_strong_poc/playground/services/storage/storage_service.dart';
import 'package:salt_strong_poc/playground/services/user/http_user_service.dart';
import 'package:salt_strong_poc/playground/services/user/user_service.dart';
import 'package:salt_strong_poc/routing/router.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/logger.dart';

//for debug only
final currentRequestsProvider = StateProvider<Map<String, RequestOptions>>((ref) => {});
const uuid = Uuid();

class DioHttpService extends HttpService {
  final ProviderRef ref;
  final dio = Dio();
  String token = '';

  DioHttpService(this.ref) {
    dio.options.baseUrl = '';

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (r, h) {
        r.headers["id"] = uuid.v4();

        r.headers["auth"] = token;

        return h.next(r);
      }, onResponse: (r, h) {
        if (r.data is String) {
          r.data = jsonDecode(r.data);
        }
        if (r.data is Map) {
          if (r.data.containsKey("token")) {
            token = r.data["token"];
          }

          try {
            if (r.data.containsKey("result")) {
              if (r.data["result"].containsKey("token")) {
                token = r.data["result"]["token"];
              }
            }
          } catch (e) {}
        }

        return h.next(r);
      }, onError: (e, h) async {
        if (e.response?.statusCode == 401 && !e.requestOptions.path.contains("login")) {
          if (SimpleNavigationObserver.currentRoute != RoutePaths.welcomeBack) {
            router.pushReplacement(RoutePaths.welcomeBack, extra: Exception("You are logged in on another device"));
          }

          // try {
          //   token = await ref.read(tokenRefreshProvider(token).future);
          //
          //   final newRequest = e.requestOptions;
          //   newRequest.headers["auth"] = token;
          //   FormData formData = FormData();
          //   formData.fields.addAll(e.requestOptions.data.fields);
          //
          //   final resp = await Dio().request("https://ssapi.saltstrong.com" + newRequest.path,
          //       data: formData,
          //       options: Options(
          //           method: newRequest.method, headers: newRequest.headers, contentType: newRequest.contentType));
          //
          //   return h.resolve(resp);
          // } catch (e) {
          //   router.pushReplacement(RoutePaths.welcomeBack, extra: e);
          //
          //   logger.shout("failed to refresh token because of $e");
          // }
        }

        return h.next(e);
      }),
    );

    // dio.interceptors.add(DioLoggerInterceptor());
  }

  @override
  Future<T> request<T>(BaseHttpRequest request,
      {required T Function(Map<String, dynamic> response) converter, CancelToken? cancelToken}) async {
    late Map<String, dynamic> value;

    switch (request.requestType) {
      case RequestType.get:
        value = await _get(request, cancelToken);
        break;
      case RequestType.post:
        value = await _post(request, cancelToken);
    }

    return converter(value);
  }

  Future<Map<String, dynamic>> _post(BaseHttpRequest request, CancelToken? cancelToken) async {
    dynamic data = request.toMap();
    if (request.contentType == Headers.multipartFormDataContentType) {
      data = FormData.fromMap(data);
    }

    final resp = await dio.post(request.endpoint,
        data: data, options: Options(contentType: request.contentType), cancelToken: cancelToken);
    return resp.data;
  }

  Future<Map<String, dynamic>> _get(BaseHttpRequest request, CancelToken? cancelToken) async {
    final resp = await dio.get(request.endpoint, queryParameters: request.toMap(), cancelToken: cancelToken);

    return resp.data;
  }
}

class DioLoggerInterceptor implements Interceptor {
  ///
  /// METHODS
  ///

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) => handler.next(options);

  @override
  void onError(DioException exception, ErrorInterceptorHandler handler) {
    final endpoint = '${exception.requestOptions.baseUrl}${exception.requestOptions.path}';
    final httpMethod = exception.requestOptions.method;
    final statusCode = '${exception.response?.statusCode}';
    final error = exception.message;
    final responseError = '${exception.response?.data}';
    final requestData = '${exception.requestOptions.data}';

    logger
      ..severe('❌ ERROR FETCHING RESPONSE ❌')
      ..severe('--------------------')
      ..severe('Endpoint: $endpoint')
      ..severe('HTTP Method: $httpMethod')
      ..severe('Status code: $statusCode')
      ..severe('Error: $error')
      ..severe('ResponseError: $responseError')
      ..severe('Request:')
      ..severe(requestData)
      ..severe('--------------------\n');

    return handler.next(exception);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final endpoint = '${response.requestOptions.baseUrl}${response.requestOptions.path}';
    final httpMethod = response.requestOptions.method;
    final statusCode = '${response.statusCode}';
    final requestData = '${response.requestOptions.data}';
    final jsonResponse = jsonEncode(response.data);

    logger
      ..info('✅ RESPONSE SUCCESSFULLY FETCHED ✅')
      ..info('--------------------')
      ..info('Endpoint: $endpoint')
      ..info('HTTP Method: $httpMethod')
      ..info('Status code: $statusCode')
      ..info('Request:')
      ..info(requestData)
      ..info('Response:')
      ..info(jsonResponse)
      ..info('--------------------\n');

    return handler.next(response);
  }
}

extension ErrorMessageConverter on DioException {
  bool isCaseOfEmailNotRegistered() {
    if (!userIsUnauthorized()) return false;
    final message = (response?.data['message'] ?? '') as String;
    return message == 'Credentials not found';
  }

  bool isCaseOfWrongPassword() {
    if (!userIsUnauthorized()) return false;
    final message = (response?.data['message'] ?? '') as String;
    return message.contains('Credentials') && message.contains('not valid');
  }

  bool userIsUnauthorized() {
    return response?.statusCode == 401;
  }
}

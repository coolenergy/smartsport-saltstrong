import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/services/http/dio.dart';

/// This is the provider for the [HttpService] class.
/// Cancel Token is used to cancel previous <get some type of layer> request
/// but can be reused for anything else, just call ref.refresh(httpCancelTokenProvider)
/// and pass is to the used request.

final httpServiceProvider = Provider<HttpService>((ref) => DioHttpService(ref));

final httpCancelTokenProvider = Provider.family<CancelToken, Object>((ref, Object key) {
  final token = CancelToken();
  ref.onDispose(() {
    token.cancel();
  });
  return token;
});

abstract class HttpService {
  Future<T> request<T>(

      /// [request] is the request object that extends [BaseHttpRequest],
      /// it contains the endpoint and the request type (get, post, etc.)
      BaseHttpRequest request,
      {
      /// [converter] is the function that converts the response to the desired type
      required T Function(Map<String, dynamic> response,) converter,

      /// [cancelToken] is the cancel token that can be used to cancel the request
      CancelToken? cancelToken});
}

Map<String, dynamic> defaultConverter(Map<String, dynamic> c) {
  return c;
}

enum RequestType { get, post }

abstract class BaseHttpRequest {
  final String endpoint;
  final RequestType requestType;
  final String contentType;
  Map<String, dynamic> toMap();

  const BaseHttpRequest({
    required this.endpoint,
    required this.requestType,
    this.contentType = Headers.multipartFormDataContentType,
  });
}

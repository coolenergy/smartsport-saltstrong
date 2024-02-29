import '../../services/http/http_service.dart';

class GetAccessKeyRequest extends BaseHttpRequest {
  GetAccessKeyRequest() : super(endpoint: '/getIfsAck', requestType: RequestType.post);

  static const _key = 'aah2mhcbabrj1nxwj34wmb8f933ty5gwmzrfp1sntkdwhkmj6q135s6as9nkgsn1';

  @override
  Map<String, dynamic> toMap() => {'key': _key};
}

class GetAccessKeyResponse {
  final String status;
  final String? accessKey1;
  final String? accessKey2;
  final String? errorMessage;

  const GetAccessKeyResponse({
    required this.status,
    this.accessKey1,
    this.accessKey2,
    this.errorMessage,
  });

  bool get isError => accessKey1 == null || accessKey2 == null || status == 'error';

  factory GetAccessKeyResponse.fromMap(Map<String, dynamic> map) => GetAccessKeyResponse(
        status: map['status'],
        accessKey1: map['ack1'],
        accessKey2: map['ack2'],
        errorMessage: map['message'],
      );
}

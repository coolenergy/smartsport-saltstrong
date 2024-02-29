import '../../services/http/http_service.dart';

class DeleteAccountRequest extends BaseHttpRequest {
  final String email;
  final String accessKey;
  final String revSubId;

  DeleteAccountRequest({
    required this.email,
    required this.accessKey,
    required this.revSubId,
  }) : super(
    endpoint: '/cancelUserIfs',
    requestType: RequestType.post,
  );

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'ack': accessKey,
      'rev_sub_id': revSubId,
    };
  }

  factory DeleteAccountRequest.fromMap(Map<String, dynamic> map) {
    return DeleteAccountRequest(
      email: map['email'],
      accessKey: map['ack'],
      revSubId: map['rev_sub_id'],
    );
  }
}
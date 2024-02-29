import '../../../playground/services/http/http_service.dart';

class ForgotPasswordRequest extends BaseHttpRequest {
  final String email;

  ForgotPasswordRequest({required this.email}) //
      : super(requestType: RequestType.post, endpoint: '/forgotPassword');

  @override
  Map<String, dynamic> toMap() => {'email': email};
}

class ForgotPasswordResponse {
  final String status;
  final String message;
  final int timeStampSec;

  const ForgotPasswordResponse({
    required this.status,
    required this.message,
    required this.timeStampSec,
  });

  factory ForgotPasswordResponse.fromMap(Map<String, dynamic> map) {
    return ForgotPasswordResponse(
      status: map['status'],
      message: map['message'],
      timeStampSec: map['timeStampSec'],
    );
  }

  @override
  String toString() {
    return 'ForgotPasswordResponse(\n'
        '\tstatus: $status,\n'
        '\tmessage: $message,\n'
        '\ttimeStampSec: $timeStampSec,\n'
        ')';
  }
}

import '../../services/http/http_service.dart';

class UserRegistrationRequest extends BaseHttpRequest {
  UserRegistrationRequest({
    required this.revenueCatId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.accessKey,
  }) : super(endpoint: '/addIfsUser', requestType: RequestType.post);

  final String email;
  final String firstName;
  final String lastName;
  final String accessKey;
  final String revenueCatId;

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'rev_sub_id': revenueCatId,
        'ack': accessKey,
        'first_name': firstName,
        'last_name': lastName,
      };
}


class UserRenewalRequest extends BaseHttpRequest {
  UserRenewalRequest({
    required this.revenueCatId,

    required this.email,
    required this.accessKey,
  }) : super(endpoint: '/renewUserIfs', requestType: RequestType.post);

  final String email;
   final String accessKey;
  final String revenueCatId;

  @override
  Map<String, dynamic> toMap() => {
    'email': email,
    'rev_sub_id': revenueCatId,
    'ack': accessKey,
   };
}


class UserRegistrationResponse {
  const UserRegistrationResponse({required this.status, this.data, this.message});

  final String status;
  final String? message;
  final UserRegistrationData? data;

  factory UserRegistrationResponse.fromMap(Map<String, dynamic> map) => UserRegistrationResponse(
        status: map['status'],
        data: map['result'] != null //
            ? UserRegistrationData.fromMap(map['result'] as Map<String, dynamic>)
            : null,
        message: map['message'],
      );

  @override
  String toString() {
    return 'UserRegistrationResponse(\n\tstatus: $status \n\tmessage: $message\n\tdata: $data\n)';
  }
}

class UserRegistrationData {
  final String? status;
  final String? message;
  final String token;

  UserRegistrationData({required this.token, this.status, this.message});

  factory UserRegistrationData.fromMap(Map<String, dynamic> map) => UserRegistrationData(
        status: map['status'],
        message: map['message'],
        token: map['token'],
      );

  @override
  String toString() {
    return 'UserRegistrationData(\n'
        '\tstatus: $status, \n'
        '\tmessage: $message, \n'
        '\ttoken: $token, \n'
        ')';
  }
}

import '../../services/http/http_service.dart';

class UserLoginRequest extends BaseHttpRequest {
  final String email;
  final String password;

  UserLoginRequest({
    required this.email,
    required this.password,
  }) : super(
          endpoint: '/login',
          requestType: RequestType.post,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory UserLoginRequest.fromMap(Map<String, dynamic> map) {
    return UserLoginRequest(
      email: map['email'],
      password: map['password'],
    );
  }
}

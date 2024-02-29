class UserLoginResponse {
  final String token;

  const UserLoginResponse({
    required this.token,
  });

  factory UserLoginResponse.fromMap(Map<String, dynamic> map) {
    return UserLoginResponse(
      token: map['token'],
    );
  }
}

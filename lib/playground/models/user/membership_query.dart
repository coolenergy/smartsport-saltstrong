import '../../services/http/http_service.dart';

class UserValidationRequest extends BaseHttpRequest {
  UserValidationRequest({required this.email, required this.accessKey}) //
      : super(endpoint: '/checkIfsUser', requestType: RequestType.post);

  final String email;
  final String accessKey;

  @override
  Map<String, dynamic> toMap() => {'email': email, 'ack': accessKey};
}

class UserValidationResponse {
  const UserValidationResponse({
    required this.status,
    this.membershipData,
  });

  final String status;
  final UserMembershipRecord? membershipData;

  bool get hasMembership => membershipData != null;

  factory UserValidationResponse.fromMap(Map<String, dynamic> map) => UserValidationResponse(
        status: map['status'],
        membershipData: map['ifsUserRecord'] != null //
            ? UserMembershipRecord.fromMap(map['ifsUserRecord'])
            : null,
      );

  @override
  String toString() {
    return 'UserMembershipRecord(\n\tstatus: $status, \n\tmembershipData: $membershipData,\n)';
  }
}

class UserMembershipRecord {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> groups;

  UserMembershipRecord({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.groups,
  });

  factory UserMembershipRecord.fromMap(Map<String, dynamic> map) => UserMembershipRecord(
        id: map['Id'],
        email: map['Email'],
        firstName: map['FirstName'],
        lastName: map['LastName'],
        groups: (map['Groups'] as List<dynamic>).map((e) => e.toString()).toList(),
      );

  @override
  String toString() {
    return 'UserMembershipRecord(\n'
        '\temail: $email, \n'
        '\tname: $firstName $lastName, \n'
        '\tid: $id, \n'
        '\tgroups: $groups, \n'
        ')';
  }
}

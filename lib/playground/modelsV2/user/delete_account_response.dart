class DeleteAccountResponse {
  final String status;

  const DeleteAccountResponse({
    required this.status,
  });

  factory DeleteAccountResponse.fromMap(Map<String, dynamic> map) {
    return DeleteAccountResponse(
      status: map['status'],
    );
  }
}
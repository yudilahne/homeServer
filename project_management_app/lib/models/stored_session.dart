class StoredSession {
  const StoredSession({
    required this.baseUrl,
    required this.token,
    required this.userName,
    required this.userEmail,
  });

  final String baseUrl;
  final String token;
  final String userName;
  final String userEmail;
}

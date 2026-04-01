import '../models/stored_session.dart';
import 'api_client.dart';

class AuthService {
  Future<StoredSession> login({
    required String baseUrl,
    required String email,
    required String password,
  }) async {
    final normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    final client = ApiClient(baseUrl: normalizedBaseUrl);
    final payload = <String, dynamic>{
      'email': email.trim(),
      'password': password,
      'device_name': 'android-project-pulse',
    };
    final response = await client.post('/api/v1/auth/login', payload);

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final token = data['token']?.toString() ?? '';

    if (token.isEmpty) {
      throw ApiException('Token login tidak ditemukan.');
    }

    return StoredSession(
      baseUrl: normalizedBaseUrl,
      token: token,
      userName: user['name']?.toString() ?? 'Project User',
      userEmail: user['email']?.toString() ?? email.trim(),
    );
  }

  Future<void> logout(StoredSession session) async {
    final client = ApiClient(baseUrl: session.baseUrl, token: session.token);
    await client.postWithoutBody('/api/v1/auth/logout');
  }

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'/$'), '');

    if (trimmed.isEmpty) {
      throw ApiException('Base URL wajib diisi.');
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    return 'https://$trimmed';
  }
}

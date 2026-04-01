import 'package:shared_preferences/shared_preferences.dart';

import '../models/stored_session.dart';

class LocalSessionStore {
  static const _baseUrlKey = 'base_url';
  static const _tokenKey = 'token';
  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';

  Future<StoredSession?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_baseUrlKey);
    final token = prefs.getString(_tokenKey);
    final userName = prefs.getString(_nameKey);
    final userEmail = prefs.getString(_emailKey);

    if (baseUrl == null || token == null || userName == null || userEmail == null) {
      return null;
    }

    return StoredSession(
      baseUrl: baseUrl,
      token: token,
      userName: userName,
      userEmail: userEmail,
    );
  }

  Future<void> save(StoredSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, session.baseUrl);
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_nameKey, session.userName);
    await prefs.setString(_emailKey, session.userEmail);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
  }
}

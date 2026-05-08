import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles secure persistence of auth tokens and the "remember me" flag.
/// All keys are prefixed with `manzili_` to avoid collisions.
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'manzili_access_token';
  static const _keyRefreshToken = 'manzili_refresh_token';
  static const _keyUserRole = 'manzili_user_role';
  static const _keyRememberMe = 'manzili_remember_me';

  // ── Write ──────────────────────────────────────────────────────────────────

  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required int? userRole,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      if (userRole != null)
        _storage.write(key: _keyUserRole, value: userRole.toString()),
    ]);
  }

  static Future<void> saveRememberMe(bool value) async {
    await _storage.write(key: _keyRememberMe, value: value ? '1' : '0');
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  static Future<String?> readAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<String?> readRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  static Future<int?> readUserRole() async {
    final v = await _storage.read(key: _keyUserRole);
    return v != null ? int.tryParse(v) : null;
  }

  static Future<bool> readRememberMe() async {
    final v = await _storage.read(key: _keyRememberMe);
    return v == '1';
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserRole),
      // Intentionally keep _keyRememberMe so the checkbox stays as the user left it.
    ]);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

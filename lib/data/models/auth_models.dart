import 'package:manzili_mobile/core/network/json_parse.dart';

class RegisterRequest {
  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String email;
  final String password;
  final int role; // 1: buyer, 2: seller, 3: admin

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}

class LoginRequest {
  LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class TokenResponse {
  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final access = _stringField(json, const [
      'accessToken',
      'AccessToken',
      'access_token',
      'token',
      'jwt',
      'JwtToken',
      'jwtToken',
    ]);
    var refresh = _stringField(json, const [
      'refreshToken',
      'RefreshToken',
      'refresh_token',
      'refresh',
    ]);
    // Some APIs return only an access JWT; reuse for refresh so session code keeps working.
    if (access != null && (refresh == null || refresh.isEmpty)) {
      refresh = access;
    }
    if (access == null || refresh == null) {
      throw FormatException(
        'Missing tokens in login response keys=${json.keys.toList()}',
      );
    }
    return TokenResponse(accessToken: access, refreshToken: refresh);
  }

  static String? _stringField(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v == null) continue;
      if (v is String && v.isNotEmpty) return v;
      if (v is num || v is bool) return v.toString();
    }
    return null;
  }

  /// Unwraps `data` / `result` when the server embeds JSON as a string.
  static Map<String, dynamic> _normalizePayload(Map<String, dynamic> raw) {
    final out = Map<String, dynamic>.from(raw);
    for (final key in [
      'data',
      'Data',
      'result',
      'Result',
      'value',
      'Value',
    ]) {
      final v = out[key];
      if (v is String) {
        final parsed = tryParseJsonMap(v);
        if (parsed != null) {
          out[key] = parsed;
        }
      }
    }
    return out;
  }

  /// Tries root, [data], and recursively nested maps/lists (ASP.NET wrappers).
  static TokenResponse? tryDecode(Map<String, dynamic> raw) {
    final normalized = _normalizePayload(raw);

    final candidates = <Map<String, dynamic>>[];
    void collect(dynamic node, [int depth = 0]) {
      if (depth > 8) return;
      if (node is Map) {
        candidates.add(Map<String, dynamic>.from(node));
        for (final v in node.values) {
          collect(v, depth + 1);
        }
      } else if (node is List) {
        for (final e in node) {
          collect(e, depth + 1);
        }
      } else if (node is String) {
        final parsed = tryParseJsonMap(node);
        if (parsed != null) {
          collect(parsed, depth + 1);
        }
      }
    }

    collect(normalized);

    for (final m in candidates) {
      try {
        return TokenResponse.fromJson(m);
      } catch (_) {}
    }
    return null;
  }
}

class RefreshTokenRequest {
  RefreshTokenRequest({
    required this.refreshToken,
  });

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}


import 'dart:convert';

/// Parses JWT payload (no crypto verification — only for non-secure hints like UI role).
Map<String, dynamic>? decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  var payload = parts[1];
  switch (payload.length % 4) {
    case 2:
      payload += '==';
      break;
    case 3:
      payload += '=';
      break;
  }
  try {
    final jsonStr = utf8.decode(base64Url.decode(payload));
    final map = jsonDecode(jsonStr);
    if (map is Map<String, dynamic>) return map;
    return null;
  } catch (_) {
    return null;
  }
}

/// Returns user role: 1 = buyer, 2 = seller, 3 = admin. Unknown → null.
int? parseRoleClaim(Map<String, dynamic> payload) {
  const claimKeys = [
    'role',
    'Role',
    'roleId',
    'RoleId',
    'userRole',
    'UserRole',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
  ];
  for (final key in claimKeys) {
    final v = payload[key];
    if (v == null) continue;
    if (v is List) {
      for (final item in v) {
        final n = _roleToInt(item);
        if (n != null) return n;
      }
      continue;
    }
    final n = _roleToInt(v);
    if (n != null) return n;
  }
  return null;
}

int? _roleToInt(Object? v) {
  if (v is int) {
    if (v >= 1 && v <= 3) return v;
    return null;
  }
  if (v is String) {
    final n = int.tryParse(v);
    if (n != null && n >= 1 && n <= 3) return n;
    final lower = v.toLowerCase();
    if (lower.contains('admin')) return 3;
    if (lower.contains('seller') || lower.contains('bazaar')) return 2;
    if (lower.contains('buyer') || lower.contains('customer')) return 1;
  }
  return null;
}

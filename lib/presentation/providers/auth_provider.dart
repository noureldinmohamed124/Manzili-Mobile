import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/core/network/json_parse.dart';
import 'package:manzili_mobile/core/constants/demo_role_store.dart';
import 'package:manzili_mobile/core/utils/jwt_payload.dart';
import 'package:manzili_mobile/data/models/auth_models.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final Dio _dio = DioClient.instance.dio;

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _accessToken;
  String? _refreshToken;
  String? _errorMessage;
  /// From JWT: 1 = buyer, 2 = seller, 3 = admin (null if not in token).
  int? _userRole;

  AuthStatus get status => _status;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get errorMessage => _errorMessage;
  int? get userRole => _userRole;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// First screen after successful login/signup flow.
  String get postLoginRoute {
    switch (_userRole) {
      case 2:
        return '/seller';
      case 3:
        return '/admin';
      case 1:
      default:
        return '/home';
    }
  }

  void _applyClaimsFromAccessToken(String? token) {
    _userRole = null;
    if (token == null || token.isEmpty) return;
    final payload = decodeJwtPayload(token);
    if (payload == null) return;
    _userRole = parseRoleClaim(payload);
  }

  /// Registers a new user.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required int role,
  }) async {
    _errorMessage = null;
    notifyListeners();

    // Register must not send a stale Bearer token; some APIs return success without tokens.
    DioClient.instance.setAccessToken(null);

    final body = RegisterRequest(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    ).toJson();

    try {
      Response response;
      try {
        response = await _dio.post(ApiConstants.register, data: body);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        try {
          response = await _dio.post(ApiConstants.registerLegacy, data: body);
        } on DioException catch (e2) {
          if (e2.response?.statusCode != 404) rethrow;
          response = await _dio.post(ApiConstants.registerApiLegacy, data: body);
        }
      }

      final data = tryParseJsonMap(response.data);
      if (data == null) {
        _errorMessage = 'السيرفر ردّ بشكل غريب';
        return false;
      }
      final success = data['success'] == true;
      if (!success) {
        _errorMessage = data['message']?.toString() ?? 'التسجيل متمش';
      }
      if (success) {
        // Showcase fallback: remember chosen role for this email.
        DemoRoleStore.setRoleForEmail(email, role);
      }
      return success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        _errorMessage = 'الإيميل ده مسجل قبل كده';
      } else {
        _errorMessage = _messageFromDio(e);
      }
      return false;
    } catch (e) {
      _errorMessage = 'حصل خطأ غير متوقع';
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Logs in the user and stores tokens in memory.
  Future<bool> login({
    required String email,
    required String password,
    int? uiRoleFallback,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    // Showcase shortcut: static admin account (REMOVE AFTER SHOWCASE).
    if (email.trim().toLowerCase() == 'wasfyadmin@gmail.com' &&
        password == 'wasfy1234') {
      _userRole = 3;
      _accessToken = createDemoJwt({'role': 3, 'email': email});
      _refreshToken = 'demo-refresh';
      DioClient.instance.setAccessToken(_accessToken);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    // Showcase shortcut: static seller account (REMOVE AFTER SHOWCASE).
    if (email.trim().toLowerCase() == 'sellertest@gmail.com' &&
        password == 'sellertest1234') {
      _userRole = 2;
      _accessToken = createDemoJwt({'role': 2, 'email': email});
      _refreshToken = 'demo-refresh';
      DioClient.instance.setAccessToken(_accessToken);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    // Critical: login must be anonymous. A leftover Bearer token often makes the server
    // return { success: true, message: "..." } without new tokens in the body.
    DioClient.instance.setAccessToken(null);

    final body = LoginRequest(email: email, password: password).toJson();

    try {
      Response response;
      try {
        response = await _dio.post(ApiConstants.login, data: body);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        try {
          response = await _dio.post(ApiConstants.loginLegacy, data: body);
        } on DioException catch (e2) {
          if (e2.response?.statusCode != 404) rethrow;
          response = await _dio.post(ApiConstants.loginApiLegacy, data: body);
        }
      }

      final map = tryParseJsonMap(response.data);
      if (map == null) {
        _errorMessage = 'السيرفر ماردش بيانات صحيحة';
        _status = AuthStatus.unauthenticated;
        return false;
      }

      final tokens = TokenResponse.tryDecode(map);
      if (tokens != null) {
        _accessToken = tokens.accessToken;
        _refreshToken = tokens.refreshToken;
        DioClient.instance.setAccessToken(_accessToken);
        _applyClaimsFromAccessToken(_accessToken);
        
        // If the token decoding gave a role (e.g. from response body), prefer that if JWT doesn't have it
        if (_userRole == null && tokens.role != null) {
          _userRole = tokens.role;
        }

        // If backend token has no role claim, fall back to locally-known role.
        _userRole ??= DemoRoleStore.getRoleForEmail(email);
        // Keep old optional fallback for debugging/testing.
        if (_userRole == null && uiRoleFallback != null) _userRole = uiRoleFallback;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        return true;
      }

      if (map['success'] == true) {
        if (kDebugMode) {
          debugPrint(
            'Auth login: success=true but tokens not parsed. keys=${map.keys.toList()}',
          );
        }
        _errorMessage =
            'مش لاقي توكنات الدخول في رد السيرفر. كلم الدعم أو جرّب تاني.';
        _status = AuthStatus.unauthenticated;
        return false;
      }

      if (map['success'] == false) {
        _errorMessage = map['message']?.toString() ?? 'تسجيل الدخول فشل';
        _status = AuthStatus.unauthenticated;
        return false;
      }

      _errorMessage = 'رد السيرفر ناقص التوكنات';
      _status = AuthStatus.unauthenticated;
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = _extractServerMessage(e) ?? 'الإيميل أو الباسورد غلط';
      } else {
        _errorMessage = _messageFromDio(e);
      }
      _status = AuthStatus.unauthenticated;
      return false;
    } catch (e, st) {
      debugPrint('login parse: $e\n$st');
      _errorMessage = e is FormatException
          ? 'السيرفر ردّ بشكل مش متوقع'
          : 'حصل خطأ غير متوقع';
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Uses the stored refresh token to obtain a new access token.
  Future<bool> refreshTokens() async {
    if (_refreshToken == null) {
      _errorMessage = 'مفيش توكن تجديد';
      notifyListeners();
      return false;
    }

    try {
      final body =
          RefreshTokenRequest(refreshToken: _refreshToken!).toJson();

      Response response;
      try {
        response = await _dio.post(ApiConstants.refresh, data: body);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        try {
          response = await _dio.post(ApiConstants.refreshLegacy, data: body);
        } on DioException catch (e2) {
          if (e2.response?.statusCode != 404) rethrow;
          response = await _dio.post(ApiConstants.refreshApiLegacy, data: body);
        }
      }

      final map = tryParseJsonMap(response.data);
      if (map == null) {
        _errorMessage = 'السيرفر ماردش بيانات';
        notifyListeners();
        return false;
      }

      final tokens = TokenResponse.tryDecode(map);
      if (tokens == null) {
        _errorMessage = map['message']?.toString() ?? 'تجديد الجلسة فشل';
        notifyListeners();
        return false;
      }

      _accessToken = tokens.accessToken;
      _refreshToken = tokens.refreshToken;

      DioClient.instance.setAccessToken(_accessToken);
      _applyClaimsFromAccessToken(_accessToken);

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage =
            _extractServerMessage(e) ?? 'جلسة الدخول خلصت، سجّل دخول تاني';
      } else {
        _errorMessage = _messageFromDio(e);
      }
      _status = AuthStatus.unauthenticated;
      _accessToken = null;
      _refreshToken = null;
      _userRole = null;
      DioClient.instance.setAccessToken(null);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حصل خطأ غير متوقع';
      _status = AuthStatus.unauthenticated;
      _accessToken = null;
      _refreshToken = null;
      _userRole = null;
      DioClient.instance.setAccessToken(null);
      notifyListeners();
      return false;
    }
  }

  String _messageFromDio(DioException e) {
    final server = _extractServerMessage(e);
    if (server != null && server.isNotEmpty) {
      return server;
    }
    return _mapDioError(e);
  }

  /// ASP.NET ProblemDetails + plain string bodies.
  String? _extractServerMessage(DioException e) {
    final parsed = tryParseJsonMap(e.response?.data);
    if (parsed != null) {
      final errors = parsed['errors'];
      if (errors is Map) {
        final parts = <String>[];
        for (final v in errors.values) {
          if (v is List) {
            for (final item in v) {
              parts.add(item.toString());
            }
          } else if (v != null) {
            parts.add(v.toString());
          }
        }
        if (parts.isNotEmpty) {
          return parts.join(' ');
        }
      }
      final msg = parsed['message'];
      if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
      final title = parsed['title'];
      if (title is String && title.trim().isNotEmpty) {
        final t = title.trim();
        if (!t.toLowerCase().contains('validation errors')) {
          return t;
        }
      }
    }
    final data = e.response?.data;
    if (data is String) {
      final s = data.trim();
      if (s.isNotEmpty && s.length < 300) {
        return s;
      }
    }
    return null;
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _accessToken = null;
    _refreshToken = null;
    _errorMessage = null;
    _userRole = null;
    DioClient.instance.setAccessToken(null);
    notifyListeners();
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'مشكلة في النت، جرّب تاني';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) return 'البيانات مش صح';
        if (statusCode == 401) return 'محتاج تسجّل دخول';
        if (statusCode == 403) return 'مش مسموحلك بالخطوة دي';
        if (statusCode == 404) return 'المطلوب مش موجود';
        if (statusCode == 409) return 'الإيميل مسجل قبل كده';
        if (statusCode == 500) return 'حصل خطأ في السيرفر، جرّب بعدين';
        return 'مشكلة من السيرفر ($statusCode)';
      case DioExceptionType.cancel:
        return 'اتلغى الطلب';
      case DioExceptionType.unknown:
      default:
        return 'حصل حاجة غلط، جرّب تاني';
    }
  }
}


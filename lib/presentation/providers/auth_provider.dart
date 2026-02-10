import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
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

  AuthStatus get status => _status;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Registers a new user.
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required int role,
  }) async {
    _errorMessage = null;
    notifyListeners();

    final body = RegisterRequest(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    ).toJson();

    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: body,
      );

      // Expecting: { "success": true, "message": "User Registered Successfully" }
      final data = response.data as Map<String, dynamic>;
      final success = data['success'] == true;
      if (!success) {
        _errorMessage = data['message']?.toString() ?? 'Registration failed';
      }
      return success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        _errorMessage = 'Email already exists';
      } else {
        _errorMessage = _mapDioError(e);
      }
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Logs in the user and stores tokens in memory.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final body = LoginRequest(email: email, password: password).toJson();

    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: body,
      );

      final tokenResponse =
          TokenResponse.fromJson(response.data as Map<String, dynamic>);

      _accessToken = tokenResponse.accessToken;
      _refreshToken = tokenResponse.refreshToken;

      DioClient.instance.setAccessToken(_accessToken);

      _status = AuthStatus.authenticated;
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Invalid email or password';
      } else {
        _errorMessage = _mapDioError(e);
      }
      _status = AuthStatus.unauthenticated;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      notifyListeners();
    }
  }

  /// Uses the stored refresh token to obtain a new access token.
  Future<bool> refreshTokens() async {
    if (_refreshToken == null) {
      _errorMessage = 'No refresh token available';
      notifyListeners();
      return false;
    }

    try {
      final body =
          RefreshTokenRequest(refreshToken: _refreshToken!).toJson();

      final response = await _dio.post(
        ApiConstants.refresh,
        data: body,
      );

      final tokenResponse =
          TokenResponse.fromJson(response.data as Map<String, dynamic>);

      _accessToken = tokenResponse.accessToken;
      _refreshToken = tokenResponse.refreshToken;

      DioClient.instance.setAccessToken(_accessToken);

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _errorMessage = 'Invalid refresh token';
      } else {
        _errorMessage = _mapDioError(e);
      }
      _status = AuthStatus.unauthenticated;
      _accessToken = null;
      _refreshToken = null;
      DioClient.instance.setAccessToken(null);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
      _status = AuthStatus.unauthenticated;
      _accessToken = null;
      _refreshToken = null;
      DioClient.instance.setAccessToken(null);
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _status = AuthStatus.unauthenticated;
    _accessToken = null;
    _refreshToken = null;
    _errorMessage = null;
    DioClient.instance.setAccessToken(null);
    notifyListeners();
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) return 'Bad request';
        if (statusCode == 401) return 'Unauthorized';
        if (statusCode == 409) return 'Conflict';
        return 'Server error ($statusCode)';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
      default:
        return 'Something went wrong';
    }
  }
}


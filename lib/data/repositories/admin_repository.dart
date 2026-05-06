import 'package:dio/dio.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/core/network/json_parse.dart';
import 'package:manzili_mobile/data/models/admin_models.dart';
import 'package:manzili_mobile/data/models/auth_models.dart'; // Using User model if exists or create a new one

class AdminRepository {
  AdminRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<(Map<String, dynamic>?, String?)> getUserDetails(int userId) async {
    try {
      Response res;
      try {
        res = await _dio.get(ApiConstants.adminUserDetails(userId));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.adminUserDetailsLegacy(userId));
      }
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      if (raw['success'] != true) {
        return (null, raw['message']?.toString() ?? 'المستخدم مش موجود');
      }
      return (raw['data'] as Map<String, dynamic>?, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> unblockUser(int userId) async {
    try {
      Response res;
      try {
        res = await _dio.patch(ApiConstants.adminUnblockUser(userId));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.patch(ApiConstants.adminUnblockUserLegacy(userId));
      }
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (false, 'السيرفر ماردش بيانات');
      if (raw['success'] != true) {
        return (false, raw['message']?.toString() ?? 'العملية فشلت');
      }
      return (true, null);
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> blockUser(int userId, String reason, DateTime blockedUntil) async {
    try {
      Response res;
      final dataBody = {
        'reason': reason,
        'blockedUntil': blockedUntil.toIso8601String(),
      };
      try {
        res = await _dio.patch(
          ApiConstants.adminBlockUser(userId),
          data: dataBody,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.patch(
          ApiConstants.adminBlockUserLegacy(userId),
          data: dataBody,
        );
      }
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (false, 'السيرفر ماردش بيانات');
      if (raw['success'] != true) {
        return (false, raw['message']?.toString() ?? 'العملية فشلت');
      }
      return (true, null);
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(AdminUsersResponse?, String?)> getUsers({
    int page = 1,
    int pageSize = 10,
    String? role,
    bool? isBlocked,
    String? search,
  }) async {
    try {
      Response res;
      final queryParameters = {
        'page': page,
        'pageSize': pageSize,
        if (role != null) 'role': role,
        if (isBlocked != null) 'isBlocked': isBlocked,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      try {
        res = await _dio.get(
          ApiConstants.adminUsers,
          queryParameters: queryParameters,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(
          ApiConstants.adminUsersLegacy,
          queryParameters: queryParameters,
        );
      }
      
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final data = raw['data'];
      return (AdminUsersResponse.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(AdminDashboardStats?, String?)> getDashboardStats() async {
    try {
      Response res;
      try {
        res = await _dio.get(ApiConstants.adminDashboard);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.adminDashboardLegacy);
      }
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      // If the response wraps in data:
      final data = raw.containsKey('data') ? raw['data'] : raw;
      return (AdminDashboardStats.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(AdminFinancialsResponse?, String?)> getFinancials({
    int page = 1,
    int pageSize = 10,
    DateTime? from,
    DateTime? to,
    int? buyerId,
    int? providerId,
  }) async {
    try {
      Response res;
      final queryParameters = {
        'page': page,
        'pageSize': pageSize,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        if (buyerId != null) 'buyerId': buyerId,
        if (providerId != null) 'providerId': providerId,
      };

      try {
        res = await _dio.get(
          ApiConstants.adminFinancials,
          queryParameters: queryParameters,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(
          ApiConstants.adminFinancialsLegacy,
          queryParameters: queryParameters,
        );
      }

      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final data = raw['data'];
      return (AdminFinancialsResponse.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(AdminOrdersResponse?, String?)> getOrders({
    int page = 1,
    int pageSize = 10,
    String? status,
    int? buyerId,
    int? providerId,
  }) async {
    try {
      Response res;
      final queryParameters = {
        'page': page,
        'pageSize': pageSize,
        if (status != null && status.isNotEmpty) 'status': status,
        if (buyerId != null) 'buyerId': buyerId,
        if (providerId != null) 'providerId': providerId,
      };

      try {
        res = await _dio.get(
          ApiConstants.adminOrders,
          queryParameters: queryParameters,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(
          ApiConstants.adminOrdersLegacy,
          queryParameters: queryParameters,
        );
      }

      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final data = raw['data'];
      return (AdminOrdersResponse.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(AdminServicesResponse?, String?)> getServices({
    int page = 1,
    int pageSize = 10,
    int? providerId,
    String? status,
    String? search,
  }) async {
    try {
      Response res;
      final queryParameters = {
        'page': page,
        'pageSize': pageSize,
        if (providerId != null) 'providerId': providerId,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      try {
        res = await _dio.get(
          ApiConstants.adminServices,
          queryParameters: queryParameters,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(
          ApiConstants.adminServicesLegacy,
          queryParameters: queryParameters,
        );
      }

      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final data = raw['data'];
      return (AdminServicesResponse.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  String _mapDioError(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return 'محتاج تسجّل دخول أولاً';
    if (code == 403) return 'غير مصرح لك (أدمن فقط)';
    if (code == 404) return 'البيانات مش موجودة';
    if (e.response?.data is Map) {
      final m = e.response!.data as Map;
      final msg = m['message']?.toString() ?? m['title']?.toString();
      
      if (m.containsKey('errors')) {
        return 'Validation: ${m['errors']}';
      }
      if (msg != null && msg.isNotEmpty) return msg;
    }
    
    final rawData = e.response?.data?.toString();
    if (rawData != null && rawData.isNotEmpty && rawData.length < 200) {
      return 'Error $code: $rawData';
    } else if (rawData != null && rawData.isNotEmpty) {
      return 'Error $code: ${rawData.substring(0, 200)}...';
    }
    
    return 'مشكلة في الاتصال أو السيرفر مش جاهز. Code: $code';
  }
}

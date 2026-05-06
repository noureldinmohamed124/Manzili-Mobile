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
      final res = await _dio.get(ApiConstants.adminUserDetails(userId));
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
      final res = await _dio.post(ApiConstants.adminUnblockUser(userId));
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
      final res = await _dio.post(
        ApiConstants.adminBlockUser(userId),
        data: {
          'reason': reason,
          'blockedUntil': blockedUntil.toIso8601String(),
        },
      );
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
      final res = await _dio.get(
        ApiConstants.adminUsers,
        queryParameters: {
          'Page': page,
          'PageSize': pageSize,
          if (role != null) 'Role': role,
          if (isBlocked != null) 'IsBlocked': isBlocked,
          if (search != null && search.isNotEmpty) 'Search': search,
        },
      );
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
      final res = await _dio.get(ApiConstants.adminDashboard);
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
      final res = await _dio.get(
        ApiConstants.adminFinancials,
        queryParameters: {
          'Page': page,
          'PageSize': pageSize,
          if (from != null) 'From': from.toIso8601String(),
          if (to != null) 'To': to.toIso8601String(),
          if (buyerId != null) 'BuyerId': buyerId,
          if (providerId != null) 'ProviderId': providerId,
        },
      );
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
      final res = await _dio.get(
        ApiConstants.adminOrders,
        queryParameters: {
          'Page': page,
          'PageSize': pageSize,
          if (status != null && status.isNotEmpty) 'Status': status,
          if (buyerId != null) 'BuyerId': buyerId,
          if (providerId != null) 'ProviderId': providerId,
        },
      );
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
      final res = await _dio.get(
        ApiConstants.adminServices,
        queryParameters: {
          'Page': page,
          'PageSize': pageSize,
          if (providerId != null) 'ProviderId': providerId,
          if (status != null && status.isNotEmpty) 'Status': status,
          if (search != null && search.isNotEmpty) 'Search': search,
        },
      );
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
    if (code == 401) return 'محتاج تسجّل دخول كمدير';
    if (code == 403) return 'مش مسموحلك تدخل هنا';
    if (code == 404) return 'المستخدم مش موجود';
    if (e.response?.data is Map) {
      final m = e.response!.data as Map;
      final msg = m['message']?.toString() ?? m['title']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'مشكلة في الاتصال أو السيرفر مش جاهز';
  }
}

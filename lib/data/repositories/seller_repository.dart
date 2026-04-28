import 'package:dio/dio.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/core/network/json_parse.dart';
import 'package:manzili_mobile/data/models/seller_models.dart';

class SellerRepository {
  SellerRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<(List<SellerServiceListItem>, String?)> getSellerServices({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final query = <String, dynamic>{
        // Backend spec uses PascalCase, but ASP.NET usually accepts either.
        'Status': status,
        'Page': page,
        'PageSize': pageSize,
      }..removeWhere((k, v) => v == null || (v is String && v.isEmpty));

      final res = await _dio.get(ApiConstants.sellerServices, queryParameters: query);
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (<SellerServiceListItem>[], 'السيرفر ماردش بيانات');
      final parsed = SellerServicesListResponse.fromJson(raw);
      return (parsed.items, null);
    } on DioException catch (e) {
      return (<SellerServiceListItem>[], _mapDioError(e));
    } catch (_) {
      return (<SellerServiceListItem>[], 'حصل خطأ غير متوقع');
    }
  }

  Future<(SellerServiceDetails?, String?)> getSellerServiceById(int id) async {
    try {
      final res = await _dio.get(ApiConstants.sellerServiceById(id));
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final wrapper = SellerServiceDetailsResponse.fromJson(raw);
      if (wrapper.success != true) {
        return (null, wrapper.message ?? 'مش لاقي الخدمة دي');
      }
      if (wrapper.data == null) return (null, 'بيانات الخدمة ناقصة');
      return (wrapper.data, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(SellerDashboardStats?, String?)> getDashboardStats() async {
    try {
      final res = await _dio.get(ApiConstants.sellerDashboard);
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final parsed = SellerDashboardStats.fromJson(raw);
      return (parsed, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  String _mapDioError(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return 'محتاج تسجّل دخول كبائع';
    if (code == 403) return 'مش مسموحلك تدخل هنا';
    if (code == 404) return 'البيانات مش موجودة';
    if (e.response?.data is Map) {
      final m = e.response!.data as Map;
      final msg = m['message']?.toString() ?? m['title']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'مشكلة في الاتصال أو السيرفر مش جاهز';
  }
}


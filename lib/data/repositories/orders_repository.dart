import 'package:dio/dio.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/data/models/order_models.dart';

class OrdersRepository {
  OrdersRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Returns server message on failure; `null` on success.
  Future<String?> requestService(OrderRequestBody body) async {
    try {
      final res = await _dio.postUri(
        ApiConstants.orderRequestUri,
        data: body.toJson(),
      );
      final data = res.data;
      if (data == null) return 'مفيش رد من السيرفر';
      final ok = data['success'] == true;
      if (!ok) {
        return data['message']?.toString() ?? 'الطلب ماتمش';
      }
      return null;
    } on DioException catch (e) {
      return _mapDioError(e);
    } catch (_) {
      return 'حصل خطأ غير متوقع';
    }
  }

  Future<(PaginatedOrdersResponse?, String?)> getOrders({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final res = await _dio.get(
        ApiConstants.orders,
        queryParameters: queryParams,
      );

      final raw = res.data;
      if (raw == null) return (null, 'مفيش بيانات من السيرفر');

      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      final parsed = PaginatedOrdersResponse.fromJson(dataJson);
      return (parsed, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ في معالجة البيانات');
    }
  }

  Future<(PaymentSummaryData?, String?)> getPaymentSummary() async {
    try {
      final res = await _dio.get(ApiConstants.orderPaymentSummary);

      final raw = res.data;
      if (raw == null) return (null, 'مفيش بيانات من السيرفر');

      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      final parsed = PaymentSummaryData.fromJson(dataJson);
      return (parsed, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ في معالجة البيانات');
    }
  }

  String _mapDioError(DioException e) {
    if (e.response?.statusCode == 401) return 'محتاج تسجّل دخول الأول';
    if (e.response?.data is Map) {
      final m = e.response!.data as Map;
      
      // Handle ASP.NET validation errors (400 Bad Request)
      if (m.containsKey('errors') && m['errors'] is Map) {
        final errors = m['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstErrorList = errors.values.first;
          if (firstErrorList is List && firstErrorList.isNotEmpty) {
            return firstErrorList.first.toString();
          }
        }
      }

      final msg = m['message']?.toString() ?? m['title']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'مشكلة في الاتصال أو السيرفر مش جاهز';
  }
}

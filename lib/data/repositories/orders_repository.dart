import 'package:dio/dio.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/core/network/json_parse.dart';
import 'package:manzili_mobile/data/models/order_models.dart';

class OrdersRepository {
  OrdersRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Returns server message on failure; `null` on success.
  Future<String?> requestService(OrderRequestBody body) async {
    try {
      // New API returns { requestId, totalPrice, requestDate } (no wrapper).
      // We try the new URI first, then fall back to legacy /api path on 404.
      try {
        final res = await _dio.postUri(ApiConstants.orderRequestUri, data: body.toJson());
        final raw = tryParseJsonMap(res.data);
        if (raw == null) return null; // Some servers may return empty on success.
        if (raw['success'] == false) {
          return raw['message']?.toString() ?? 'الطلب ماتمش';
        }
        return null;
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        final res = await _dio.postUri(ApiConstants.orderRequestUriLegacy, data: body.toJson());
        final raw = tryParseJsonMap(res.data);
        if (raw == null) return 'مفيش رد من السيرفر';
        final ok = raw['success'] == true || raw.containsKey('requestId');
        if (!ok) return raw['message']?.toString() ?? 'الطلب ماتمش';
        return null;
      }
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

      Response res;
      try {
        res = await _dio.get(ApiConstants.orders, queryParameters: queryParams);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.ordersLegacy, queryParameters: queryParams);
      }

      final raw = res.data;
      if (raw == null) return (null, 'مفيش بيانات من السيرفر');

      final parsedRaw = tryParseJsonMap(raw);
      if (parsedRaw == null) return (null, 'الرد مش صحيح');

      final dataJson = parsedRaw['data'] as Map<String, dynamic>? ?? parsedRaw;
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
      Response res;
      try {
        res = await _dio.get(ApiConstants.orderPaymentSummary);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.orderPaymentSummaryLegacy);
      }

      final raw = res.data;
      if (raw == null) return (null, 'مفيش بيانات من السيرفر');

      final parsedRaw = tryParseJsonMap(raw);
      if (parsedRaw == null) return (null, 'الرد مش صحيح');

      // New response is direct object; legacy might wrap in {data}.
      final dataJson = parsedRaw['data'] as Map<String, dynamic>? ?? parsedRaw;
      final parsed = PaymentSummaryData.fromJson(dataJson);
      return (parsed, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ في معالجة البيانات');
    }
  }

  Future<(Map<String, dynamic>?, String?)> submitPaymentProof({
    required List<int> orderIds,
    required String paymentScreenshot,
    String? notes,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.submitPaymentProof,
        data: {
          'OrderIds': orderIds,
          'PaymentScreenshot': paymentScreenshot,
          'Notes': notes,
        },
      );
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      return (raw, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
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

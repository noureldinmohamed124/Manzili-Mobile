import 'package:dio/dio.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/core/network/json_parse.dart';
import 'package:manzili_mobile/data/models/order_models.dart';

class OrdersRepository {
  OrdersRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Returns `(orderId, null)` on success, `(null, errorMessage)` on failure.
  /// The API response contains `requestId` which is the new order's ID.
  Future<(int?, String?)> requestService(OrderRequestBody body) async {
    try {
      try {
        final res = await _dio.postUri(ApiConstants.orderRequestUri, data: body.toJson());
        final raw = tryParseJsonMap(res.data);
        if (raw == null) return (null, null); // empty body = success, no ID
        if (raw['success'] == false) {
          return (null, raw['message']?.toString() ?? 'الطلب ماتمش');
        }
        // Try to extract the order/request ID from the response
        final id = (raw['requestId'] as num?)?.toInt() ??
            (raw['orderId'] as num?)?.toInt() ??
            (raw['id'] as num?)?.toInt() ??
            (raw['data'] is Map ? (raw['data']['requestId'] as num?)?.toInt() : null) ??
            (raw['data'] is Map ? (raw['data']['id'] as num?)?.toInt() : null);
        return (id, null);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        final res = await _dio.postUri(ApiConstants.orderRequestUriLegacy, data: body.toJson());
        final raw = tryParseJsonMap(res.data);
        if (raw == null) return (null, 'مفيش رد من السيرفر');
        final ok = raw['success'] == true || raw.containsKey('requestId');
        if (!ok) return (null, raw['message']?.toString() ?? 'الطلب ماتمش');
        final id = (raw['requestId'] as num?)?.toInt() ??
            (raw['orderId'] as num?)?.toInt() ??
            (raw['id'] as num?)?.toInt();
        return (id, null);
      }
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
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
    required String paymentScreenshotPath,
    String? notes,
  }) async {
    try {
      final formData = FormData();
      for (var i = 0; i < orderIds.length; i++) {
        formData.fields.add(MapEntry('OrderIds[$i]', orderIds[i].toString()));
      }
      
      formData.files.add(MapEntry(
        'PaymentScreenshot',
        await MultipartFile.fromFile(paymentScreenshotPath),
      ));

      if (notes != null && notes.isNotEmpty) {
        formData.fields.add(MapEntry('Notes', notes));
      }

      final res = await _dio.post(
        ApiConstants.submitPaymentProof,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
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

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
      final code = e.response?.statusCode;
      if (code == 401) {
        return 'محتاج تسجّل دخول عشان تكمّل الطلب';
      }
      if (e.response?.data is Map) {
        final m = e.response!.data as Map;
        final msg = m['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      return 'حصلت مشكلة في الاتصال (${code ?? '؟'})';
    } catch (_) {
      return 'حصل خطأ غير متوقع';
    }
  }
}

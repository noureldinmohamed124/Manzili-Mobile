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

      var res = await _dio.get(ApiConstants.sellerServices, queryParameters: query);
      
      // Fallback if the server uses /api/seller/services
      if (res.statusCode == 404) {
        res = await _dio.get('/api/seller/services', queryParameters: query);
      }
      
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (<SellerServiceListItem>[], 'السيرفر ماردش بيانات');
      final parsed = SellerServicesListResponse.fromJson(raw);
      return (parsed.items, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final res = await _dio.get('/api/seller/services', queryParameters: {
            'Status': status,
            'Page': page,
            'PageSize': pageSize,
          }..removeWhere((k, v) => v == null || (v is String && v.isEmpty)));
          final raw = tryParseJsonMap(res.data);
          if (raw == null) return (<SellerServiceListItem>[], 'السيرفر ماردش بيانات');
          final parsed = SellerServicesListResponse.fromJson(raw);
          return (parsed.items, null);
        } catch (_) {
          return (<SellerServiceListItem>[], _mapDioError(e));
        }
      }
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
      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      final parsed = SellerDashboardStats.fromJson(dataJson);
      return (parsed, null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> createService(CreateServiceRequest request, List<String> imagePaths) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        'description': request.description,
        'categoryId': request.categoryId,
        'basePrice': request.basePrice,
      });

      // Add options as JSON string or array, depending on backend requirement
      for (var i = 0; i < request.optionGroups.length; i++) {
        final group = request.optionGroups[i];
        formData.fields.add(MapEntry('optionGroups[$i].name', group.name));
        formData.fields.add(MapEntry('optionGroups[$i].isRequired', group.isRequired.toString()));
        for (var j = 0; j < group.options.length; j++) {
          final opt = group.options[j];
          formData.fields.add(MapEntry('optionGroups[$i].options[$j].name', opt.name));
          formData.fields.add(MapEntry('optionGroups[$i].options[$j].price', opt.price.toString()));
        }
      }

      for (var path in imagePaths) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(path),
        ));
      }

      final res = await _dio.post(
        ApiConstants.sellerServices,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) {
        return (true, null);
      }
      return (false, raw?['message']?.toString() ?? 'فشل إنشاء الخدمة');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> repriceOrder(int orderId, double newPrice, String reason) async {
    try {
      final res = await _dio.post(
        ApiConstants.sellerOrderReprice(orderId),
        data: {'newPrice': newPrice, 'reason': reason},
      );
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل تسعير الطلب');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> rejectOrder(int orderId, String reason) async {
    try {
      final res = await _dio.post(
        ApiConstants.sellerOrderReject(orderId),
        data: {'reason': reason},
      );
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل رفض الطلب');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> approveOrder(int orderId) async {
    try {
      final res = await _dio.post(
        ApiConstants.sellerOrderApprove(orderId),
        data: {},
      );
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل الموافقة على الطلب');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(SellerOrderListResponse?, String?)> getSellerOrders({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.sellerOrders,
        queryParameters: {
          'Page': page,
          'PageSize': pageSize,
          if (status != null && status.isNotEmpty) 'Status': status,
        },
      );
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final data = raw['data'] ?? raw;
      return (SellerOrderListResponse.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(SellerOrderDetails?, String?)> getSellerOrderById(int orderId) async {
    try {
      final res = await _dio.get(ApiConstants.sellerOrderById(orderId));
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      if (raw['success'] == false) return (null, raw['message']?.toString() ?? 'الطلب غير موجود');
      final data = raw['data'] ?? raw;
      return (SellerOrderDetails.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> updateOrderStatus(int orderId, String status) async {
    try {
      final res = await _dio.put(
        ApiConstants.sellerOrderStatus(orderId),
        data: {'status': status},
      );
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل تحديث حالة الطلب');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> updateService(int serviceId, CreateServiceRequest request, List<String> imagePaths) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        'description': request.description,
        'categoryId': request.categoryId,
        'basePrice': request.basePrice,
      });

      for (var i = 0; i < request.optionGroups.length; i++) {
        final group = request.optionGroups[i];
        formData.fields.add(MapEntry('optionGroups[$i].name', group.name));
        formData.fields.add(MapEntry('optionGroups[$i].isRequired', group.isRequired.toString()));
        for (var j = 0; j < group.options.length; j++) {
          final opt = group.options[j];
          formData.fields.add(MapEntry('optionGroups[$i].options[$j].name', opt.name));
          formData.fields.add(MapEntry('optionGroups[$i].options[$j].price', opt.price.toString()));
        }
      }

      for (var path in imagePaths) {
        if (!path.startsWith('http')) {
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(path),
          ));
        }
      }

      final res = await _dio.put(
        ApiConstants.sellerServiceById(serviceId),
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل تحديث الخدمة');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> deleteService(int serviceId) async {
    try {
      final res = await _dio.delete(ApiConstants.sellerServiceById(serviceId));
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل حذف الخدمة');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
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


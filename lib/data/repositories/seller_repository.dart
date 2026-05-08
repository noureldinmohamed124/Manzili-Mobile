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
      Response res;
      // Backend requires a JSON body with Content-Type: application/json.
      // Status must be sent as an integer enum value (Active=2, Draft=1, Blocked=0).
      // String values like "Blocked" cause a 400 validation error.
      int? statusInt;
      if (status != null) {
        switch (status.toLowerCase()) {
          case 'active': statusInt = 2; break;
          case 'draft': statusInt = 1; break;
          case 'blocked': statusInt = 0; break;
        }
      }

      final body = <String, dynamic>{
        'Page': page,
        'PageSize': pageSize,
        if (statusInt != null) 'Status': statusInt,
      };
      final jsonOptions = Options(
        headers: {'Content-Type': 'application/json'},
      );

      try {
        res = await _dio.get(
          ApiConstants.sellerServices,
          data: body,
          options: jsonOptions,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(
          ApiConstants.sellerServicesLegacy,
          data: body,
          options: jsonOptions,
        );
      }
      
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (<SellerServiceListItem>[], 'السيرفر ماردش بيانات');
      final parsed = SellerServicesListResponse.fromJson(raw);
      return (parsed.items, null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (<SellerServiceListItem>[], null);
      }
      return (<SellerServiceListItem>[], _mapDioError(e));
    } catch (_) {
      return (<SellerServiceListItem>[], 'حصل خطأ غير متوقع');
    }
  }

  Future<(SellerServiceDetails?, String?)> getSellerServiceById(int id) async {
    try {
      Response res;
      try {
        res = await _dio.get(ApiConstants.sellerServiceById(id));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.sellerServiceByIdLegacy(id));
      }
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
      Response res;
      try {
        res = await _dio.get(ApiConstants.sellerDashboard);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.sellerDashboardLegacy);
      }
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
      FormData createFormData() {
        final form = FormData.fromMap({
          'title': request.title,
          'description': request.description,
          'categoryId': request.categoryId,
          'basePrice': request.basePrice,
        });

        for (var i = 0; i < request.optionGroups.length; i++) {
          final group = request.optionGroups[i];
          form.fields.add(MapEntry('optionGroups[$i].name', group.name));
          form.fields.add(MapEntry('optionGroups[$i].isRequired', group.isRequired.toString()));
          for (var j = 0; j < group.options.length; j++) {
            final opt = group.options[j];
            form.fields.add(MapEntry('optionGroups[$i].options[$j].name', opt.name));
            form.fields.add(MapEntry('optionGroups[$i].options[$j].price', opt.price.toString()));
          }
        }
        return form;
      }

      var formData = createFormData();
      for (var path in imagePaths) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
      }

      Response res;
      final options = Options(headers: {'Content-Type': 'multipart/form-data'});
      try {
        res = await _dio.post(
          ApiConstants.sellerServices,
          data: formData,
          options: options,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        
        // Recreate FormData for retry because Dio streams can only be read once
        formData = createFormData();
        for (var path in imagePaths) {
          formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
        }
        
        res = await _dio.post(
          ApiConstants.sellerServicesLegacy,
          data: formData,
          options: options,
        );
      }

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
      Response res;
      final data = {'newPrice': newPrice, 'reason': reason};
      try {
        res = await _dio.post(
          ApiConstants.sellerOrderReprice(orderId),
          data: data,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.post(
          ApiConstants.sellerOrderRepriceLegacy(orderId),
          data: data,
        );
      }
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
      Response res;
      final data = {'reason': reason};
      try {
        res = await _dio.post(
          ApiConstants.sellerOrderReject(orderId),
          data: data,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.post(
          ApiConstants.sellerOrderRejectLegacy(orderId),
          data: data,
        );
      }
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
      Response res;
      try {
        res = await _dio.post(
          ApiConstants.sellerOrderApprove(orderId),
          data: {},
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.post(
          ApiConstants.sellerOrderApproveLegacy(orderId),
          data: {},
        );
      }
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
      Response res;
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      try {
        res = await _dio.get(
          ApiConstants.sellerOrders,
          queryParameters: queryParams,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(
          ApiConstants.sellerOrdersLegacy,
          queryParameters: queryParams,
        );
      }
      final raw = tryParseJsonMap(res.data);
      if (raw == null) return (null, 'السيرفر ماردش بيانات');
      final data = raw['data'] ?? raw;
      return (SellerOrderListResponse.fromJson(data is Map<String, dynamic> ? data : raw), null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (SellerOrderListResponse(items: [], totalCount: 0, page: page, pageSize: pageSize), null);
      }
      return (null, _mapDioError(e));
    } catch (_) {
      return (null, 'حصل خطأ غير متوقع');
    }
  }

  Future<(SellerOrderDetails?, String?)> getSellerOrderById(int orderId) async {
    try {
      Response res;
      try {
        res = await _dio.get(ApiConstants.sellerOrderById(orderId));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.get(ApiConstants.sellerOrderByIdLegacy(orderId));
      }
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
      Response res;
      final data = {'status': status};
      try {
        // Must use PATCH — PUT returns 405
        res = await _dio.patch(
          ApiConstants.sellerOrderStatus(orderId),
          data: data,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.patch(
          ApiConstants.sellerOrderStatusLegacy(orderId),
          data: data,
        );
      }
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

      // New images from local paths
      for (var path in imagePaths) {
        if (!path.startsWith('http')) {
          formData.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
        }
      }

      Response res;
      final options = Options(headers: {'Content-Type': 'multipart/form-data'});
      try {
        res = await _dio.put(
          ApiConstants.sellerServiceById(serviceId),
          data: formData,
          options: options,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.put(
          ApiConstants.sellerServiceByIdLegacy(serviceId),
          data: formData,
          options: options,
        );
      }
      final raw = tryParseJsonMap(res.data);
      if (raw?['success'] == true) return (true, null);
      return (false, raw?['message']?.toString() ?? 'فشل تحديث الخدمة');
    } on DioException catch (e) {
      return (false, _mapDioError(e));
    } catch (_) {
      return (false, 'حصل خطأ غير متوقع');
    }
  }

  Future<(bool, String?)> deleteService(int serviceId) async {    try {
      Response res;
      try {
        res = await _dio.delete(ApiConstants.sellerServiceById(serviceId));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        res = await _dio.delete(ApiConstants.sellerServiceByIdLegacy(serviceId));
      }
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
      
      // If it's a validation error, append the errors
      if (m.containsKey('errors')) {
        final errors = m['errors'];
        return 'Validation: $errors';
      }
      
      if (msg != null && msg.isNotEmpty) return msg;
    }
    
    // If it's not a map, or doesn't have the expected keys, return the raw data!
    final rawData = e.response?.data?.toString();
    if (rawData != null && rawData.isNotEmpty && rawData.length < 200) {
      return 'Error $code: $rawData';
    } else if (rawData != null && rawData.isNotEmpty) {
      return 'Error $code: ${rawData.substring(0, 200)}...';
    }
    
    return 'مشكلة في الاتصال أو السيرفر مش جاهز. Code: $code';
  }
}


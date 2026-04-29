import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/core/constants/demo_data.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/data/models/service_models.dart';
import 'package:manzili_mobile/data/models/category_models.dart';

class ServicesProvider extends ChangeNotifier {
  final Dio _dio = DioClient.instance.dio;

  List<ServiceItem> _services = [];
  List<ServiceItem> _featuredServices = [];
  List<ServiceItem> _recommendedServices = [];
  List<ServiceItem> _mostPurchasedServices = [];
  List<CategoryModel> _categories = [];
  HomeServicesBuckets? _homeBuckets;
  ServiceItem? _currentServiceDetails;
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 1;

  List<ServiceItem> get services => _services;
  List<ServiceItem> get featuredServices => _featuredServices;
  List<ServiceItem> get recommendedServices => _recommendedServices;
  List<ServiceItem> get mostPurchasedServices => _mostPurchasedServices;
  List<CategoryModel> get categories => _categories;
  HomeServicesBuckets? get homeBuckets => _homeBuckets;
  ServiceItem? get currentServiceDetails => _currentServiceDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;

  /// Loads home sections when [GET /api/services/home/{no}] exists; otherwise callers use fallbacks.
  Future<void> fetchHomeBuckets(int no) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Response<Map<String, dynamic>> response;
      try {
        response = await _dio.get<Map<String, dynamic>>(
          ApiConstants.homeServices(no),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        response = await _dio.get<Map<String, dynamic>>(
          ApiConstants.homeServicesLegacy(no),
        );
      }

      final raw = response.data;
      if (raw == null) {
        _homeBuckets = null;
        return;
      }

      final data = raw['data'] is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>
          : raw;
      _homeBuckets = HomeServicesBuckets.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _homeBuckets = null;
        _errorMessage = null;
      } else {
        _homeBuckets = null;
        _errorMessage = _mapDioError(e);
      }
    } catch (_) {
      _homeBuckets = null;
      _errorMessage = 'مش قدرنا نحمّل أقسام الرئيسية';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all categories.
  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.categories);
      if (response.data == null) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return;
      }
      
      final raw = response.data as Map<String, dynamic>?;
      if (raw == null || raw['data'] == null || raw['data']['items'] == null) {
        _errorMessage = 'الرد مش صحيح';
        return;
      }
      
      final itemsList = raw['data']['items'] as List<dynamic>;
      _categories = itemsList.map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      _categories = [];
    } catch (_) {
      _errorMessage = 'حصل خطأ غير متوقع';
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches paginated list of services (camelCase query names per API spec).
  Future<void> fetchServices({
    int page = 1,
    int pageSize = 10,
    int? categoryId,
    bool? isRecommended,
    bool? topDiscounts,
    bool? mostPurchased,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (categoryId != null) {
        queryParameters['categoryId'] = categoryId;
      }
      if (isRecommended != null) {
        queryParameters['isRecommended'] = isRecommended;
      }
      if (topDiscounts != null) {
        queryParameters['topDiscounts'] = topDiscounts;
      }
      if (mostPurchased != null) {
        queryParameters['mostPurchased'] = mostPurchased;
      }

      Response response;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        try {
          response = await _dio.get(
            ApiConstants.serviceByName(searchQuery),
            queryParameters: queryParameters,
          );
        } on DioException catch (e) {
          if (e.response?.statusCode != 404) rethrow;
          response = await _dio.get(
            ApiConstants.serviceByNameLegacy(searchQuery),
            queryParameters: queryParameters,
          );
        }
      } else {
        try {
          response = await _dio.get(
            ApiConstants.services,
            queryParameters: queryParameters,
          );
        } on DioException catch (e) {
          if (e.response?.statusCode != 404) rethrow;
          response = await _dio.get(
            ApiConstants.servicesLegacy,
            queryParameters: queryParameters,
          );
        }
      }

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'الرد مش صحيح';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);

      _services = data.items;
      _currentPage = data.page;
      _pageSize = data.pageSize;
      _totalPages = data.totalPages;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      _services = [];
      _currentPage = 1;
      _pageSize = pageSize;
      _totalPages = 1;
    } catch (_) {
      _errorMessage = 'حصل خطأ غير متوقع';
      _services = [];
      _currentPage = 1;
      _pageSize = pageSize;
      _totalPages = 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Strong offers / discounts section (does not overwrite main [services] list).
  Future<void> fetchFeaturedServices({
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: <String, dynamic>{
          'page': page,
          'pageSize': pageSize,
          'topDiscounts': true,
        },
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'الرد مش صحيح';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);
      _featuredServices = data.items;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      _featuredServices = [];
    } catch (_) {
      _errorMessage = 'حصل خطأ غير متوقع';
      _featuredServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recommended strip.
  Future<void> fetchRecommendedServices({
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: <String, dynamic>{
          'page': page,
          'pageSize': pageSize,
          'isRecommended': true,
        },
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'الرد مش صحيح';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);
      _recommendedServices = data.items;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      _recommendedServices = [];
    } catch (_) {
      _errorMessage = 'حصل خطأ غير متوقع';
      _recommendedServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMostPurchasedServices({
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: <String, dynamic>{
          'page': page,
          'pageSize': pageSize,
          'mostPurchased': true,
        },
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'الرد مش صحيح';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);
      _mostPurchasedServices = data.items;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      _mostPurchasedServices = [];
    } catch (_) {
      _errorMessage = 'حصل خطأ غير متوقع';
      _mostPurchasedServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches a single service by its ID with full details.
  Future<ServiceItem?> getServiceById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Response response;
      try {
        response = await _dio.get(ApiConstants.serviceById(id));
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        response = await _dio.get(ApiConstants.serviceByIdLegacy(id));
      }

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return null;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'الرد مش صحيح';
        return null;
      }

      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      if (dataJson.isEmpty) {
        _errorMessage = 'مش لاقي الخدمة دي';
        return null;
      }

      final item = ServiceItem.fromJson(dataJson);
      _currentServiceDetails = item;

      final index = _services.indexWhere((s) => s.id == item.id);
      if (index >= 0) {
        _services[index] = item;
      } else {
        _services.add(item);
      }
      return item;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      return null;
    } catch (e) {
      _errorMessage = 'حصل خطأ غير متوقع';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GET /api/services/name/{name} with query params per spec.
  Future<ServiceItem?> getServiceByName(
    String name, {
    String? keyword,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Response response;
      try {
        response = await _dio.get(
          ApiConstants.serviceByName(name),
          queryParameters: <String, dynamic>{
            if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
            'pageNumber': pageNumber,
            'pageSize': pageSize,
          },
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        response = await _dio.get(
          ApiConstants.serviceByNameLegacy(name),
          queryParameters: <String, dynamic>{
            if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
            'pageNumber': pageNumber,
            'pageSize': pageSize,
          },
        );
      }

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'السيرفر ماردش بيانات';
        return null;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'الرد مش صحيح';
        return null;
      }

      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      if (dataJson.isEmpty) {
        _errorMessage = 'مش لاقي الخدمة دي';
        return null;
      }

      final item = ServiceItem.fromJson(dataJson);
      _currentServiceDetails = item;

      final index = _services.indexWhere((s) => s.id == item.id);
      if (index >= 0) {
        _services[index] = item;
      } else {
        _services.add(item);
      }
      return item;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
      return null;
    } catch (e) {
      _errorMessage = 'حصل خطأ غير متوقع';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Client filter on the last loaded [services] list (works when API has no text search).
  List<ServiceItem> filterServicesLocally(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<ServiceItem>.from(_services);
    return _services
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.providerName.toLowerCase().contains(q))
        .toList();
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'مشكلة في النت، جرّب تاني';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) return 'البيانات مش صح';
        if (statusCode == 401) return 'محتاج تسجّل دخول';
        if (statusCode == 403) return 'مش مسموح بالخطوة دي';
        if (statusCode == 404) return 'مش لاقي اللي بتدور عليه';
        return 'مشكلة من السيرفر ($statusCode)';
      case DioExceptionType.cancel:
        return 'اتلغى الطلب';
      case DioExceptionType.unknown:
      default:
        return 'حصل حاجة غلط، جرّب تاني';
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:manzili_mobile/core/network/api_constants.dart';
import 'package:manzili_mobile/core/network/dio_client.dart';
import 'package:manzili_mobile/data/models/service_models.dart';

class ServicesProvider extends ChangeNotifier {
  final Dio _dio = DioClient.instance.dio;

  List<ServiceItem> _services = [];
  List<ServiceItem> _featuredServices = [];
  List<ServiceItem> _recommendedServices = [];
  ServiceItem? _currentServiceDetails;
  bool _isLoading = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalPages = 1;

  List<ServiceItem> get services => _services;
  List<ServiceItem> get featuredServices => _featuredServices;
  List<ServiceItem> get recommendedServices => _recommendedServices;
  ServiceItem? get currentServiceDetails => _currentServiceDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _totalPages;

  /// Fetches paginated list of services.
  Future<void> fetchServices({
    int page = 1,
    int pageSize = 10,
    int? categoryId,
    bool? isFeatured,
    bool? isRecommended,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }
      if (isFeatured != null) {
        queryParameters['is_featured'] = isFeatured;
      }
      if (isRecommended != null) {
        queryParameters['is_recommended'] = isRecommended;
      }

      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: queryParameters,
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'Empty response from server';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'Invalid response format';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);

      _services = data.items;
      _currentPage = data.page;
      _pageSize = data.pageSize;
      _totalPages = data.totalPages;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches featured services list (e.g. for Home view).
  Future<void> fetchFeaturedServices({
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'is_featured': true,
      };

      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: queryParameters,
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'Empty response from server';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'Invalid response format';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);
      _featuredServices = data.items;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches recommended services list (e.g. for Home view).
  Future<void> fetchRecommendedServices({
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'is_recommended': true,
      };

      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: queryParameters,
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'Empty response from server';
        return;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'Invalid response format';
        return;
      }

      final data = PaginatedServicesResponse.fromJson(raw);
      _recommendedServices = data.items;
    } on DioException catch (e) {
      _errorMessage = _mapDioError(e);
    } catch (e) {
      _errorMessage = 'Unexpected error occurred';
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
      final response = await _dio.get(
        ApiConstants.serviceById(id),
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'Empty response from server';
        return null;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'Invalid response format';
        return null;
      }

      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      if (dataJson.isEmpty) {
        _errorMessage = 'Service not found';
        return null;
      }

      final item = ServiceItem.fromJson(dataJson);
      _currentServiceDetails = item;

      // Optionally update local cache
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
      _errorMessage = 'Unexpected error occurred';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches a single service by its name with full details.
  Future<ServiceItem?> getServiceByName(String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(
        ApiConstants.serviceByName(name),
      );

      if (response.data == null || response.data.toString().isEmpty) {
        _errorMessage = 'Empty response from server';
        return null;
      }

      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        _errorMessage = 'Invalid response format';
        return null;
      }

      final dataJson = raw['data'] as Map<String, dynamic>? ?? raw;
      if (dataJson.isEmpty) {
        _errorMessage = 'Service not found';
        return null;
      }

      final item = ServiceItem.fromJson(dataJson);
      _currentServiceDetails = item;

      // Optionally update local cache
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
      _errorMessage = 'Unexpected error occurred';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) return 'Bad request';
        if (statusCode == 401) return 'Unauthorized';
        return 'Server error ($statusCode)';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
      default:
        return 'Something went wrong';
    }
  }
}

